/* ==========================================================================
   ABROADY — backend.js
   Thin wrapper around Supabase. Every function is safe to call when Supabase
   is not configured: `backend.enabled` is false and callers fall back to the
   local prototype behaviour.
   ========================================================================== */
(function () {
  const cfg = window.ABROADY_CONFIG || {};
  const ready = !!(cfg.SUPABASE_URL && cfg.SUPABASE_ANON_KEY && window.supabase);
  const sb = ready ? window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY) : null;

  // Convert a Supabase row into the shape the UI already uses.
  const toUser = (authUser, profile) => ({
    id: authUser.id,
    email: authUser.email,
    name: profile?.name || authUser.user_metadata?.name || authUser.email.split("@")[0],
    country: profile?.country || "",
    year: profile?.year || "1",
    term: profile?.term || "Spring 2028",
    destination: profile?.destination || "",
    international: !!profile?.international,
    discoverable: profile?.discoverable ?? true,
  });

  async function fail(promise) {
    const { data, error } = await promise;
    if (error) throw error;
    return data;
  }

  const backend = {
    enabled: ready,
    client: sb,

    /* ---------- auth ---------- */
    async signUp({ email, password, name, country, year, term, international, consentVersion, language }) {
      const data = await fail(sb.auth.signUp({
        email, password,
        options: {
          emailRedirectTo: location.origin + location.pathname + "#account",
          data: { name, country, year, term, international, consent_version: consentVersion, language },
        },
      }));
      // data.session is null when "Confirm email" is on in Supabase Auth settings
      return { needsConfirmation: !data.session, user: data.user };
    },

    async signIn(email, password) {
      return fail(sb.auth.signInWithPassword({ email, password }));
    },

    async signOut() { await sb.auth.signOut(); },

    async currentUser() {
      const { data: { session } } = await sb.auth.getSession();
      if (!session) return null;
      const { data: profile } = await sb.from("profiles").select("*").eq("id", session.user.id).maybeSingle();
      return toUser(session.user, profile);
    },

    onAuthChange(callback) {
      sb.auth.onAuthStateChange((event) => {
        // Defer so Supabase finishes its own work before we query again
        if (["SIGNED_IN", "SIGNED_OUT", "USER_UPDATED"].includes(event)) setTimeout(callback, 0);
      });
    },

    async updateProfile(id, fields) {
      return fail(sb.from("profiles").update({ ...fields, updated_at: new Date().toISOString() }).eq("id", id));
    },

    async deleteAccount() {
      await fail(sb.rpc("delete_my_account"));
      await sb.auth.signOut();
    },

    /* ---------- progress ---------- */
    async loadProgress(userId) {
      const { data } = await sb.from("user_progress").select("checklist, joined_clubs").eq("user_id", userId).maybeSingle();
      return data ? { checklist: data.checklist || [], joined: data.joined_clubs || [] } : null;
    },

    async saveProgress(userId, { checklist, joined }) {
      return fail(sb.from("user_progress").upsert({
        user_id: userId, checklist, joined_clubs: joined, updated_at: new Date().toISOString(),
      }));
    },

    /* ---------- forms ---------- */
    async insert(table, row) {
      // No .select(): anon users can insert but not read these tables back
      return fail(sb.from(table).insert(row));
    },

    async approvedReviews() {
      const { data, error } = await sb.from("approved_reviews").select("name, role, rating, text").order("created_at", { ascending: false }).limit(30);
      return error ? [] : data;
    },

    /* ---------- peer match ---------- */
    async matchPeers(term, destination = null) {
      const { data, error } = await sb.rpc("match_peers", { p_term: term, p_destination: destination });
      return error ? [] : data;
    },
  };

  window.backend = backend;
})();
