/* ==========================================================================
   ABROADY — script.js  (app logic, vanilla JavaScript)

   Sections:
     0. CONFIG       — your Formspree address lives here
     1. HELPERS      — storage, toasts, escaping
     2. LANGUAGE     — EN / PT / ES switching
     3. ACCOUNTS     — create account, log in, saved progress per user
     4. NAVIGATION   — which page (view) is showing
     5. ORIENTATION  — checklist + progress
     6. CLUBS        — search & filters
     7. PEER MATCH   — matches + demo chat
     8. COMMUNITY    — channels + planned events
     9. EARLY ACCESS — coming-soon roadmap
    10. REVIEWS      — list + rating summary
    11. FORMS        — every form sends to Formspree (lands in your email)
    12. PROFILE      — edit, log out, delete
    13. CONSENT      — cookie / privacy banner shown on scroll
    14. START        — runs everything
   ========================================================================== */

/* ==========================================================================
   0. CONFIG
   ========================================================================== */
// Every form (early access, contact, reviews, events, new accounts) is sent here.
// Formspree emails each submission to you and keeps a copy in your Formspree inbox.
const FORMSPREE_ENDPOINT = "https://formspree.io/f/xbglevpe";
const POLICY_VERSION = "2026-10-01"; // change this date when you update the policies → banner asks again

/* ==========================================================================
   1. HELPERS
   ========================================================================== */
const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

// Browser storage can be blocked (private mode, strict settings). try/catch keeps the app working.
const store = {
  get(key, fallback) {
    try { const v = localStorage.getItem("abroady:" + key); return v === null ? fallback : JSON.parse(v); }
    catch { return fallback; }
  },
  set(key, value) { try { localStorage.setItem("abroady:" + key, JSON.stringify(value)); } catch { /* ignore */ } },
  remove(key) { try { localStorage.removeItem("abroady:" + key); } catch { /* ignore */ } },
};

// Turn user text into safe HTML (prevents broken layouts and script injection).
function escapeHTML(str) {
  return String(str ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

// Highlight search matches with <mark>.
function highlight(text, query) {
  const safe = escapeHTML(text);
  if (!query) return safe;
  const pattern = escapeHTML(query).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return safe.replace(new RegExp(`(${pattern})`, "gi"), "<mark>$1</mark>");
}

// Fill {placeholders}: fmt("Hi {name}", {name: "Ana"}) → "Hi Ana"
const fmt = (str, vars = {}) => str.replace(/\{(\w+)\}/g, (_, k) => vars[k] ?? "");

let toastTimer;
function toast(message) {
  const el = $("#toast");
  el.textContent = message;
  el.classList.add("is-visible");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => el.classList.remove("is-visible"), 2600);
}

const initialsOf = (name) => String(name || "?").trim().split(/\s+/).map((w) => w[0]).slice(0, 2).join("").toUpperCase();
const isEmail = (v) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(String(v).trim());

/* ==========================================================================
   2. LANGUAGE
   ========================================================================== */
const SUPPORTED = ["en", "pt", "es"];
const EN = {};      // English text captured from index.html on load
const EN_PH = {};   // English placeholders
let lang = "en";

// Pick a value from a {en, pt, es} object (or return plain strings as-is).
function tr(value) {
  if (value == null) return "";
  if (typeof value === "string" || Array.isArray(value)) return value;
  return value[lang] ?? value.en;
}
// Text from JS_STRINGS (i18n.js)
function T(key, vars) { return fmt((JS_STRINGS[lang] && JS_STRINGS[lang][key]) || JS_STRINGS.en[key] || key, vars); }

function captureEnglish() {
  $$("[data-i18n]").forEach((el) => { if (!(el.dataset.i18n in EN)) EN[el.dataset.i18n] = el.innerHTML; });
  $$("[data-i18n-ph]").forEach((el) => { EN_PH[el.dataset.i18nPh] = el.getAttribute("placeholder"); });
}

function applyTranslations() {
  const dict = TRANSLATIONS[lang] || {};
  $$("[data-i18n]").forEach((el) => {
    const key = el.dataset.i18n;
    el.innerHTML = lang === "en" ? EN[key] : (dict[key] ?? EN[key]);
  });
  $$("[data-i18n-ph]").forEach((el) => {
    const key = el.dataset.i18nPh;
    el.setAttribute("placeholder", lang === "en" ? EN_PH[key] : (dict[key] ?? EN_PH[key]));
  });
  document.documentElement.lang = lang === "pt" ? "pt-BR" : lang;
}

function setLanguage(newLang) {
  lang = SUPPORTED.includes(newLang) ? newLang : "en";
  store.set("lang", lang);
  $("#lang-select").value = lang;
  applyTranslations();
  // Re-draw every part of the page that JavaScript builds
  Object.keys(conversations).forEach((k) => delete conversations[k]); // demo chats restart in the new language
  closeChat(true);
  renderAll();
}

function initLanguage() {
  captureEnglish();
  const saved = store.get("lang", null);
  const browser = (navigator.language || "en").slice(0, 2);
  lang = saved || (SUPPORTED.includes(browser) ? browser : "en");
  $("#lang-select").value = lang;
  $("#lang-select").addEventListener("change", (e) => setLanguage(e.target.value));
  applyTranslations();
}

/* ==========================================================================
   3. ACCOUNTS (prototype: saved in this browser only)
   Passwords are never stored in plain text: we store a salted SHA-256 hash.
   👉 For real accounts across devices, the next step is a service such as
      Firebase Authentication or Supabase Auth.
   ========================================================================== */
const getUsers = () => store.get("users", {});
const saveUsers = (users) => store.set("users", users);
const currentEmail = () => store.get("session", null);
const currentUser = () => { const e = currentEmail(); return e ? getUsers()[e] || null : null; };

// Each user (or the guest) gets their own saved checklist / clubs
const userKey = (name) => `data:${currentEmail() || "guest"}:${name}`;

async function hashPassword(password, salt) {
  const text = salt + ":" + password;
  if (window.crypto?.subtle) {
    const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
    return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");
  }
  // Fallback for very old browsers (not cryptographically strong)
  let h = 0; for (const ch of text) h = (h * 31 + ch.charCodeAt(0)) | 0; return "x" + h;
}
const newSalt = () => Math.random().toString(36).slice(2) + Date.now().toString(36);

// Copy guest progress into a brand-new account so nothing is lost
function adoptGuestData(email) {
  ["checklist", "joined"].forEach((name) => {
    const guest = store.get(`data:guest:${name}`, null);
    if (guest && !store.get(`data:${email}:${name}`, null)) store.set(`data:${email}:${name}`, guest);
  });
}

function onAuthChange() {
  loadUserData();
  updateAccountUI();
  renderAll();
}

function updateAccountUI() {
  const user = currentUser();
  const avatar = $("#account-avatar");
  const label = $("#account-label");
  if (user) {
    avatar.hidden = false;
    avatar.textContent = initialsOf(user.name);
    label.textContent = user.name.split(" ")[0];
    label.removeAttribute("data-i18n");
  } else {
    avatar.hidden = true;
    label.setAttribute("data-i18n", "nav.login");
    label.innerHTML = lang === "en" ? EN["nav.login"] : TRANSLATIONS[lang]["nav.login"];
  }
  $("#auth-card").hidden = !!user;
  $("#profile-card").hidden = !user;
  if (user) renderProfile();

  // Peer Match sidebar
  $("#me-avatar").textContent = user ? initialsOf(user.name) : "?";
  const meName = $("#me-name"), meMeta = $("#me-meta");
  if (user) {
    meName.removeAttribute("data-i18n"); meMeta.removeAttribute("data-i18n");
    meName.textContent = user.name;
    meMeta.textContent = `${T("year" + (user.year || 1))} · ${tr(termLabel(user.term))}`;
  } else {
    meName.setAttribute("data-i18n", "match.you"); meMeta.setAttribute("data-i18n", "match.guest");
    applyTranslations();
  }
}

const termLabel = (term) => (TRANSLATIONS[lang] && TRANSLATIONS[lang]["term." + term]) || (term === "Not sure" ? (TRANSLATIONS[lang]?.["dest.unsure"] || "Not sure yet") : term);

function initAuth() {
  // Switch between "Log in" and "Create account"
  $$("[data-auth]").forEach((btn) => btn.addEventListener("click", () => {
    $$("[data-auth]").forEach((b) => b.classList.toggle("is-active", b === btn));
    $("#login-form").hidden = btn.dataset.auth !== "login";
    $("#signup-form").hidden = btn.dataset.auth !== "signup";
  }));

  // CREATE ACCOUNT
  $("#signup-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = e.target, msg = $(".form-msg", f);
    const email = f.email.value.trim().toLowerCase();
    if (!f.name.value.trim() || !email) return showMsg(msg, T("errRequired"));
    if (!isEmail(email)) return showMsg(msg, T("errEmail"));
    if (f.password.value.length < 8) return showMsg(msg, T("errPassword"));
    if (!f.consent.checked) return showMsg(msg, T("errConsent"));
    const users = getUsers();
    if (users[email]) return showMsg(msg, T("errExists"));

    const salt = newSalt();
    users[email] = {
      name: f.name.value.trim(), email, country: f.country.value.trim(), year: f.year.value, term: f.term.value,
      international: f.international.checked, salt, hash: await hashPassword(f.password.value, salt),
      createdAt: new Date().toISOString(), consentVersion: POLICY_VERSION,
    };
    saveUsers(users);
    adoptGuestData(email);
    store.set("session", email);
    showMsg(msg, "");
    f.reset();
    toast(T("welcome", { name: users[email].name.split(" ")[0] }));
    onAuthChange();

    // Let the founder know someone signed up (password is NEVER sent)
    sendToFormspree({
      _subject: `🎓 New Abroady account: ${users[email].name}`,
      "Form": "New account (prototype)", "Name": users[email].name, "email": email,
      "Home country": users[email].country || "—", "Year": T("year" + users[email].year), "Term abroad": users[email].term,
      "International student": users[email].international ? "Yes" : "No",
    }).catch(() => { /* silent: the account works even offline */ });
  });

  // LOG IN
  $("#login-form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const f = e.target, msg = $(".form-msg", f);
    const email = f.email.value.trim().toLowerCase();
    const user = getUsers()[email];
    if (!user || (await hashPassword(f.password.value, user.salt)) !== user.hash) return showMsg(msg, T("errLogin"));
    store.set("session", email);
    showMsg(msg, "");
    f.reset();
    toast(T("welcomeBack", { name: user.name.split(" ")[0] }));
    onAuthChange();
  });
}

/* ==========================================================================
   4. NAVIGATION
   The address bar hash (#home, #clubs…) decides which view is visible,
   so the Back button works and every page has its own shareable link.
   ========================================================================== */
const VIEWS = ["home", "orientation", "clubs", "match", "community", "about", "early", "account"];

function showView(name) {
  if (name === "reviews") { showView("home"); $("#reviews").scrollIntoView(); return; }
  if (!VIEWS.includes(name)) name = "home";
  $$(".view").forEach((v) => v.classList.toggle("is-active", v.dataset.view === name));
  $$(".tab[data-tab]").forEach((t) => {
    const active = t.dataset.tab === name;
    t.classList.toggle("is-active", active);
    active ? t.setAttribute("aria-current", "page") : t.removeAttribute("aria-current");
  });
  // On phones, Community/About/Early/Account live under "More"
  $("#more-btn").classList.toggle("is-active", ["community", "about", "early", "account"].includes(name));
  $("#account-btn").classList.toggle("is-active", name === "account");
  window.scrollTo(0, 0);
  closeChat(true);
}

function initNavigation() {
  window.addEventListener("hashchange", () => showView(location.hash.slice(1)));
  showView(location.hash.slice(1));

  // Phone "More" sheet
  const sheet = $("#more-sheet"), moreBtn = $("#more-btn");
  moreBtn.addEventListener("click", () => { sheet.hidden = false; moreBtn.setAttribute("aria-expanded", "true"); });
  $$("[data-close-sheet]").forEach((el) => el.addEventListener("click", () => { sheet.hidden = true; moreBtn.setAttribute("aria-expanded", "false"); }));
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") sheet.hidden = true; });
}

/* ==========================================================================
   5. ORIENTATION HUB
   ========================================================================== */
let doneTasks = new Set();
let joinedClubs = new Set();
function loadUserData() {
  doneTasks = new Set(store.get(userKey("checklist"), []));
  joinedClubs = new Set(store.get(userKey("joined"), []));
}
const totalTasks = () => CHECKLIST.reduce((s, g) => s + g.tasks.length, 0);
const checklistPct = () => Math.round((doneTasks.size / totalTasks()) * 100);

function renderChecklist() {
  $("#checklist-grid").innerHTML = CHECKLIST.map((group) => {
    const done = group.tasks.filter((t) => doneTasks.has(t.id)).length;
    return `
      <article class="panel check-card">
        <div class="check-card__head">
          <div class="feature__icon">${group.icon}</div>
          <div>
            <h3>${tr(group.title)}</h3>
            <span class="check-card__meta">${tr(group.when)} · ${T("groupDone", { d: done, t: group.tasks.length })}</span>
          </div>
        </div>
        <ul class="task-list">
          ${group.tasks.map((t) => `
            <li>
              <label class="task ${doneTasks.has(t.id) ? "is-done" : ""}">
                <input type="checkbox" data-task="${t.id}" ${doneTasks.has(t.id) ? "checked" : ""} />
                <span class="task__text"><strong>${tr(t.label)}</strong><small>${tr(t.hint)}</small></span>
              </label>
            </li>`).join("")}
        </ul>
      </article>`;
  }).join("");

  const pct = checklistPct();
  $("#progress-bar").style.width = pct + "%";
  $("#progress-label").textContent = pct + "%";
  $("#progress-count").textContent = T("tasksDone", { d: doneTasks.size, t: totalTasks() });
}

function initChecklist() {
  $("#checklist-grid").addEventListener("change", (e) => {
    const id = e.target.dataset.task;
    if (!id) return;
    e.target.checked ? doneTasks.add(id) : doneTasks.delete(id);
    store.set(userKey("checklist"), [...doneTasks]);
    renderChecklist();
    if (doneTasks.size === totalTasks()) toast(T("allDone"));
  });
}

/* ==========================================================================
   6. CLUB DIRECTORY
   ========================================================================== */
const clubState = { query: "", category: "all", freshmanOnly: false };

function renderClubs() {
  const q = clubState.query.toLowerCase();
  const results = CLUBS.filter((c) => {
    const text = [c.name, tr(c.desc), c.desc.en, c.category, ...c.tags].join(" ").toLowerCase();
    return (!q || text.includes(q)) &&
           (clubState.category === "all" || c.category === clubState.category) &&
           (!clubState.freshmanOnly || c.freshman);
  });

  const catLabel = (cat) => (lang === "en" ? EN["cat." + cat] : TRANSLATIONS[lang]["cat." + cat]).replace(/^\S+\s/, "");
  $("#club-grid").innerHTML = results.map((c) => {
    const joined = joinedClubs.has(c.name);
    return `
      <article class="panel club">
        <div class="club__top">
          <div class="club__emoji">${c.emoji}</div>
          <div>
            <h3>${highlight(c.name, clubState.query)}</h3>
            <small>${catLabel(c.category)} · ${c.members} ${T("members")}</small>
          </div>
        </div>
        <p>${highlight(tr(c.desc), clubState.query)}</p>
        <div class="club__tags">
          ${c.freshman ? `<span class="tag tag--green">${T("freshman")}</span>` : ""}
          ${c.intl ? `<span class="tag tag--blue">${T("intl")}</span>` : ""}
          ${c.tags.map((t) => `<span class="tag">${highlight(t, clubState.query)}</span>`).join("")}
        </div>
        <div class="club__foot">
          <span>🗓️ ${tr(c.meets)}</span>
          <button class="btn btn--sm ${joined ? "btn--primary is-done" : "btn--ghost"}" data-join="${escapeHTML(c.name)}">${joined ? T("joined") : T("join")}</button>
        </div>
      </article>`;
  }).join("");

  $("#club-count").textContent = results.length === 1 ? T("clubFound") : T("clubsFound", { n: results.length });
  $("#club-empty").hidden = results.length > 0;
}

function initClubs() {
  $("#club-search").addEventListener("input", (e) => { clubState.query = e.target.value.trim(); renderClubs(); });
  $("#club-chips").addEventListener("click", (e) => {
    const chip = e.target.closest(".chip"); if (!chip) return;
    $$("#club-chips .chip").forEach((c) => c.classList.toggle("is-active", c === chip));
    clubState.category = chip.dataset.category;
    renderClubs();
  });
  $("#freshman-only").addEventListener("change", (e) => { clubState.freshmanOnly = e.target.checked; renderClubs(); });
  $("#club-grid").addEventListener("click", (e) => {
    const btn = e.target.closest("[data-join]"); if (!btn) return;
    const name = btn.dataset.join;
    if (joinedClubs.has(name)) { joinedClubs.delete(name); toast(T("leftToast", { name })); }
    else { joinedClubs.add(name); toast(T("joinedToast", { name })); }
    store.set(userKey("joined"), [...joinedClubs]);
    renderClubs();
  });
  $("#club-reset").addEventListener("click", () => {
    Object.assign(clubState, { query: "", category: "all", freshmanOnly: false });
    $("#club-search").value = ""; $("#freshman-only").checked = false;
    $$("#club-chips .chip").forEach((c) => c.classList.toggle("is-active", c.dataset.category === "all"));
    renderClubs();
  });
}

/* ==========================================================================
   7. PEER MATCH + DEMO CHAT
   ========================================================================== */
const conversations = {};
let activeChat = null;

function renderMatches() {
  const dest = $("#f-destination").value, term = $("#f-term").value, year = $("#f-year").value;
  const results = PEERS
    .filter((p) => (dest === "any" || p.destination === dest) && (term === "any" || p.term === term) && (year === "any" || p.year === year))
    .sort((a, b) => b.score - a.score);

  $("#match-grid").innerHTML = results.map((p) => `
    <article class="panel peer">
      <span class="avatar" style="--h:${p.hue}">${p.initials}</span>
      <div class="peer__info">
        <h3>${p.name}</h3>
        <p class="peer__meta">${T("year" + p.year)} · ${tr(p.major)} · ${p.from}<br />→ ${p.destination}, ${termLabel(p.term)}</p>
        <div class="peer__tags">${tr(p.interests).map((i) => `<span class="tag">${i}</span>`).join("")}</div>
      </div>
      <div class="peer__side">
        <span class="score">${p.score}% <small>${T("match")}</small></span>
        <button class="btn btn--primary btn--sm" data-message="${p.id}">${T("message")}</button>
      </div>
    </article>`).join("");

  $("#match-count").textContent = results.length === 1 ? T("peerFound") : T("peersFound", { n: results.length });
  $("#match-empty").hidden = results.length > 0;
}

function renderChat() {
  const body = $("#chat-body");
  body.innerHTML = conversations[activeChat.id].map((m) => `
    <div class="bubble ${m.me ? "bubble--me" : "bubble--them"}">
      ${m.who && !m.me ? `<span class="bubble__who">${escapeHTML(m.who)}</span>` : ""}${escapeHTML(m.text)}
    </div>`).join("");
  body.scrollTop = body.scrollHeight;
}

function openChat(person, isGroup = false) {
  activeChat = { ...person, isGroup, replyIndex: 0 };
  if (!conversations[person.id]) {
    conversations[person.id] = isGroup
      ? tr(person.seed).map(([who, text]) => ({ who, text }))
      : [{ text: tr(person.opener) }];
  }
  const avatar = $("#chat-avatar");
  avatar.textContent = person.initials;
  avatar.style.setProperty("--h", person.hue);
  const nameEl = $("#chat-name");
  nameEl.removeAttribute("data-i18n");
  nameEl.textContent = person.name;
  $("#chat-meta").textContent = isGroup ? tr(person.meta) : `${T("year" + person.year)} · ${termLabel(person.term)} · ${person.score}% ${T("match")}`;
  $("#chat-input").disabled = false;
  $("#chat-send").disabled = false;
  $("#chat").classList.add("is-open");
  document.body.classList.add("chat-open");
  renderChat();
  if (window.innerWidth > 760) $("#chat-input").focus({ preventScroll: true });
  if (window.innerWidth > 760 && window.innerWidth <= 1100) $("#chat").scrollIntoView({ behavior: "smooth", block: "start" });
}

function closeChat(reset = false) {
  $("#chat").classList.remove("is-open");
  document.body.classList.remove("chat-open");
  if (reset) {
    activeChat = null;
    const nameEl = $("#chat-name");
    nameEl.setAttribute("data-i18n", "match.select");
    nameEl.innerHTML = lang === "en" ? EN["match.select"] : TRANSLATIONS[lang]["match.select"];
    $("#chat-meta").textContent = "";
    $("#chat-avatar").textContent = "?";
    $("#chat-body").innerHTML = `<p class="chat__placeholder">${lang === "en" ? EN["match.placeholder"] : TRANSLATIONS[lang]["match.placeholder"]}</p>`;
    $("#chat-input").disabled = true;
    $("#chat-send").disabled = true;
  }
}

function sendChatMessage(text) {
  const chat = activeChat;
  conversations[chat.id].push({ me: true, text });
  renderChat();
  const typing = document.createElement("div");
  typing.className = "typing";
  typing.textContent = chat.isGroup ? T("someoneTyping") : T("typing", { name: chat.name.split(" ")[0] });
  $("#chat-body").appendChild(typing);
  $("#chat-body").scrollTop = $("#chat-body").scrollHeight;

  setTimeout(() => {
    const replies = tr(chat.replies);
    const reply = replies[chat.replyIndex++ % replies.length];
    conversations[chat.id].push(chat.isGroup ? { who: reply[0], text: reply[1] } : { text: reply });
    if (activeChat === chat) renderChat();
  }, 1200);
}

function initMatch() {
  ["#f-destination", "#f-term", "#f-year"].forEach((s) => $(s).addEventListener("change", renderMatches));
  $("#match-grid").addEventListener("click", (e) => {
    const btn = e.target.closest("[data-message]"); if (!btn) return;
    openChat(PEERS.find((p) => p.id === btn.dataset.message));
  });
  $("#open-group").addEventListener("click", () => openChat(GROUP, true));
  $("#chat-form").addEventListener("submit", (e) => {
    e.preventDefault();
    const input = $("#chat-input"), text = input.value.trim();
    if (!text || !activeChat) return;
    input.value = "";
    sendChatMessage(text);
  });
  $("#chat-close").addEventListener("click", () => closeChat());
}

/* ==========================================================================
   8. COMMUNITY
   ========================================================================== */
let eventAudience = "all";

function renderCommunity() {
  $("#channel-grid").innerHTML = CHANNELS.map((c) => {
    const live = c.status === "live" && c.url;
    return `
      <article class="panel channel">
        <div class="channel__icon">${c.icon}</div>
        <div class="channel__body">
          <h3>${escapeHTML(tr(c.name))}</h3>
          <small class="muted">${escapeHTML(tr(c.handle))}</small>
          <p>${tr(c.desc)}</p>
        </div>
        ${live
          ? `<a class="btn btn--primary btn--sm" href="${escapeHTML(c.url)}" target="_blank" rel="noopener">${T("chan.open")}</a>`
          : `<span class="status status--soon">${T("chan.soon")}</span>`}
      </article>`;
  }).join("");

  $("#event-grid").innerHTML = EVENTS
    .filter((ev) => eventAudience === "all" || ev.audience === eventAudience)
    .map((ev) => `
      <article class="panel event">
        <div class="event__top"><span class="event__icon">${ev.icon}</span><span class="status status--planned">${T("planned")}</span></div>
        <h3>${tr(ev.title)}</h3>
        <p>${tr(ev.desc)}</p>
        <div class="club__tags"><span class="tag tag--blue">${T("aud." + ev.audience)}</span><span class="tag">${T("fmt." + ev.format)}</span></div>
      </article>`).join("");
}

function initCommunity() {
  $("#event-chips").addEventListener("click", (e) => {
    const chip = e.target.closest(".chip"); if (!chip) return;
    $$("#event-chips .chip").forEach((c) => c.classList.toggle("is-active", c === chip));
    eventAudience = chip.dataset.aud;
    renderCommunity();
  });
}

/* ==========================================================================
   9. EARLY ACCESS — roadmap
   ========================================================================== */
function renderRoadmap() {
  $("#roadmap").innerHTML = ROADMAP.map((r) => `
    <article class="panel road road--${r.status}">
      <div class="road__top"><span class="road__icon">${r.icon}</span><span class="status status--${r.status}">${T("status." + r.status)}</span></div>
      <h3>${tr(r.title)}</h3>
      <p>${tr(r.desc)}</p>
    </article>`).join("");
}

/* ==========================================================================
   10. REVIEWS
   Approved reviews come from APPROVED_REVIEWS in data.js.
   A visitor's own just-sent review shows as "Pending approval" on their device only.
   ========================================================================== */
const stars = (n) => "★★★★★".slice(0, n) + "☆☆☆☆☆".slice(0, 5 - n);

function renderReviews() {
  const mine = store.get("myReviews", []);
  const approved = APPROVED_REVIEWS;
  const all = [...mine.map((r) => ({ ...r, pending: true })), ...approved];

  // Summary (average of approved reviews only)
  const summary = $("#rating-summary");
  if (approved.length) {
    const avg = approved.reduce((s, r) => s + r.rating, 0) / approved.length;
    summary.innerHTML = `<div class="rating-summary__num">${avg.toFixed(1)}</div>
      <div><div class="stars" aria-hidden="true">${stars(Math.round(avg))}</div>
      <small class="muted">${T("reviewsAvg", { avg: avg.toFixed(1) })} · ${approved.length === 1 ? T("reviewOne") : T("reviewsCount", { n: approved.length })}</small></div>`;
    summary.hidden = false;
  } else summary.hidden = true;

  $("#review-list").innerHTML = all.length
    ? all.map((r) => `
      <article class="panel review ${r.pending ? "review--pending" : ""}">
        <div class="review__top">
          <span class="avatar avatar--sm" style="--h:${(r.name.length * 47) % 360}">${escapeHTML(initialsOf(r.name))}</span>
          <div><strong>${escapeHTML(r.name)}</strong><br /><small class="muted">${escapeHTML(r.role || "")}</small></div>
          <span class="stars" aria-label="${r.rating}/5">${stars(r.rating)}</span>
        </div>
        <p>${escapeHTML(r.text)}</p>
        ${r.pending ? `<span class="status status--soon">${T("pending")}</span>` : ""}
      </article>`).join("")
    : `<div class="panel review review--empty"><div class="stars">☆☆☆☆☆</div><p>${T("reviewsNone")}</p></div>`;
}

/* ==========================================================================
   11. FORMS → FORMSPREE
   ========================================================================== */
async function sendToFormspree(fields) {
  const payload = {
    ...fields,
    "Language": lang.toUpperCase(),
    "Sent from": location.href.split("#")[0],
    "Sent at": new Date().toLocaleString("en-US", { dateStyle: "medium", timeStyle: "short" }),
  };
  const res = await fetch(FORMSPREE_ENDPOINT, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error("Formspree error " + res.status);
  return res.json();
}

function showMsg(el, text, ok = false) {
  el.textContent = text;
  el.classList.toggle("is-ok", ok);
}

/* Connects one form: validates, sends, shows success.
   build(form) returns the fields to email (or a string error message). */
function wireForm(formId, { build, okKey, after }) {
  const form = $("#" + formId);
  const msg = $(".form-msg", form);
  const button = $("button[type=submit]", form);

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (form._gotcha && form._gotcha.value) return; // spam bot filled the hidden field

    // Shared checks
    const emailField = form.email;
    for (const el of $$("[required]", form)) {
      if (el.type === "checkbox") continue;
      if (!el.value.trim()) return showMsg(msg, T("errRequired"));
    }
    if (emailField && !isEmail(emailField.value)) return showMsg(msg, T("errEmail"));
    if (form.consent && !form.consent.checked) return showMsg(msg, T("errConsent"));

    const fields = build(form);
    if (typeof fields === "string") return showMsg(msg, fields);

    const label = button.innerHTML;
    button.disabled = true;
    button.textContent = T("sending");
    showMsg(msg, "");
    try {
      await sendToFormspree(fields);
      showMsg(msg, T(okKey), true);
      after && after(form, fields);
      form.reset();
    } catch {
      showMsg(msg, T("errNetwork"));
    } finally {
      button.disabled = false;
      button.innerHTML = label;
    }
  });
}

function initForms() {
  // Early access / get notified
  wireForm("early-form", {
    okKey: "okEarly",
    build: (f) => ({
      _subject: `🚀 Early access: ${f.name.value.trim()} (${f.destination.value})`,
      "Form": "Early access", "Name": f.name.value.trim(), "email": f.email.value.trim(),
      "University": f.university.value.trim() || "—", "Year": f.year.value, "Dream destination": f.destination.value,
      "International student": f.international.checked ? "Yes" : "No",
      "Accepted privacy policy": `Yes (v${POLICY_VERSION})`,
    }),
  });

  // Get in touch
  wireForm("contact-form", {
    okKey: "okContact",
    build: (f) => ({
      _subject: `✉️ New message from ${f.name.value.trim()} (${f.reason.value})`,
      "Form": "Get in touch", "Name": f.name.value.trim(), "email": f.email.value.trim(),
      "They are a": f.reason.value, "Message": f.message.value.trim(),
      "Accepted privacy policy": `Yes (v${POLICY_VERSION})`,
    }),
  });

  // Event updates
  wireForm("events-form", {
    okKey: "okEvents",
    build: (f) => ({
      _subject: "📣 New event-updates subscriber",
      "Form": "Community & events updates", "email": f.email.value.trim(),
      "Accepted privacy policy": `Yes (v${POLICY_VERSION})`,
    }),
  });

  // Reviews
  wireForm("review-form", {
    okKey: "okReview",
    build: (f) => {
      const rating = Number((f.querySelector("input[name=rating]:checked") || {}).value || 0);
      if (!rating) return T("errRating");
      return {
        _subject: `⭐ New Abroady review: ${rating}/5 from ${f.name.value.trim()}`,
        "Form": "Review", "Rating": `${stars(rating)} (${rating}/5)`, "Name": f.name.value.trim(),
        "About them": f.role.value.trim() || "—", "email": f.email.value.trim(), "Review": f.text.value.trim(),
        "Agreed to publication": "Yes",
        "To publish": "Copy this review into APPROVED_REVIEWS in data.js",
      };
    },
    after: (f, fields) => {
      const mine = store.get("myReviews", []);
      mine.unshift({ name: fields["Name"], role: fields["About them"] === "—" ? "" : fields["About them"], rating: Number(fields["Rating"].match(/\((\d)/)[1]), text: fields["Review"] });
      store.set("myReviews", mine.slice(0, 5));
      renderReviews();
    },
  });

  // Pre-fill name/email in forms when logged in
  document.addEventListener("focusin", (e) => {
    const user = currentUser();
    const form = e.target.closest("form");
    if (!user || !form || form.id === "login-form" || form.id === "signup-form" || form.id === "profile-form") return;
    if (form.name && form.name.tagName === "INPUT" && !form.name.value) form.name.value = user.name;
    if (form.email && !form.email.value) form.email.value = user.email;
  });
}

/* ==========================================================================
   12. PROFILE
   ========================================================================== */
function renderProfile() {
  const user = currentUser(); if (!user) return;
  $("#profile-avatar").textContent = initialsOf(user.name);
  $("#profile-title").textContent = T("hi", { name: user.name.split(" ")[0] });
  $("#profile-email").textContent = user.email;
  $("#stat-checklist").textContent = checklistPct() + "%";
  $("#stat-clubs").textContent = joinedClubs.size;
  $("#stat-term").textContent = termLabel(user.term);
  const f = $("#profile-form");
  f.name.value = user.name; f.country.value = user.country || ""; f.year.value = user.year || "1"; f.term.value = user.term || "Spring 2028";
}

function initProfile() {
  $("#profile-form").addEventListener("submit", (e) => {
    e.preventDefault();
    const f = e.target, users = getUsers(), email = currentEmail();
    if (!f.name.value.trim()) return showMsg($(".form-msg", f), T("errRequired"));
    Object.assign(users[email], { name: f.name.value.trim(), country: f.country.value.trim(), year: f.year.value, term: f.term.value });
    saveUsers(users);
    showMsg($(".form-msg", f), "");
    toast(T("saved"));
    updateAccountUI();
  });
  $("#logout-btn").addEventListener("click", () => { store.remove("session"); toast(T("loggedOut")); onAuthChange(); });
  $("#delete-btn").addEventListener("click", () => { $("#delete-confirm").hidden = false; });
  $("#delete-no").addEventListener("click", () => { $("#delete-confirm").hidden = true; });
  $("#delete-yes").addEventListener("click", () => {
    const email = currentEmail(), users = getUsers();
    delete users[email]; saveUsers(users);
    store.remove(`data:${email}:checklist`); store.remove(`data:${email}:joined`); store.remove("session");
    $("#delete-confirm").hidden = true;
    toast(T("deleted"));
    onAuthChange();
  });

  // About page: copy email
  $("#copy-email").addEventListener("click", async (e) => {
    const email = e.currentTarget.dataset.email;
    try { await navigator.clipboard.writeText(email); toast(T("copied")); }
    catch { toast(email); } // clipboard blocked: show the address instead
  });
}

/* ==========================================================================
   13. COOKIE / PRIVACY CONSENT
   The banner appears the first time the visitor scrolls down (or after 8 s).
   "Accept all"   → essential storage + Google Fonts
   "Essential only" → essential storage only, system fonts
   ========================================================================== */
function loadGoogleFonts() {
  if ($("#gfonts")) return;
  const link = document.createElement("link");
  link.id = "gfonts"; link.rel = "stylesheet";
  link.href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap";
  document.head.appendChild(link);
}

function initConsent() {
  const banner = $("#consent");
  const saved = store.get("consent", null);
  const valid = saved && saved.version === POLICY_VERSION;
  if (valid && saved.choice === "all") loadGoogleFonts();

  const show = () => { banner.hidden = false; requestAnimationFrame(() => banner.classList.add("is-visible")); };
  const choose = (choice) => {
    store.set("consent", { choice, version: POLICY_VERSION, date: new Date().toISOString() });
    if (choice === "all") loadGoogleFonts(); else { const l = $("#gfonts"); l && l.remove(); }
    banner.classList.remove("is-visible");
    setTimeout(() => (banner.hidden = true), 300);
    toast(T("consentSaved"));
  };

  if (!valid) {
    const onScroll = () => { if (window.scrollY > 120) { show(); cleanup(); } };
    const timer = setTimeout(() => { show(); cleanup(); }, 8000);
    const cleanup = () => { window.removeEventListener("scroll", onScroll); clearTimeout(timer); };
    window.addEventListener("scroll", onScroll, { passive: true });
  }
  $("#consent-all").addEventListener("click", () => choose("all"));
  $("#consent-essential").addEventListener("click", () => choose("essential"));
  $("#cookie-settings").addEventListener("click", show);
}

/* ==========================================================================
   14. START
   ========================================================================== */
function renderAll() {
  renderChecklist();
  renderClubs();
  renderMatches();
  renderCommunity();
  renderRoadmap();
  renderReviews();
  updateAccountUI();
}

// Scripts are at the end of <body>, so the HTML already exists here.
initLanguage();
loadUserData();
initNavigation();
initAuth();
initChecklist();
initClubs();
initMatch();
initCommunity();
initForms();
initProfile();
initConsent();
renderAll();
