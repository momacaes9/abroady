# Abroady — website
Abroady 🌍

Your global campus starts here. A trilingual (EN / PT / ES) web app that helps first-year and international students settle in, find their people, and plan to study abroad early.

🔗 Live: abroady.netlify.app  · Built by Monica Macaes, UNC-Chapel Hill '30

At most universities, study-abroad planning starts in junior year, and international students land with no map of campus life. Abroady puts orientation, community, and study-abroad planning in one place from day one, in the student's own language.

Features
Feature	What it does
International Orientation Hub	Step-by-step arrival checklist with saved progress per user
Smart Club Directory	Search and filter clubs by category, freshman-friendly, and international-friendly
Peer Match	Matches students by destination and term, with a match score and a cohort group chat (demo profiles)
Community	Channels and upcoming events, with event-invite sign-up
Accounts	Sign up / log in / edit profile / delete account, entirely client-side
Reviews	Rating summary and a review form; reviews are moderated before they go live
i18n	Full English, Portuguese, and Spanish switching with no page reload
Privacy-first	Consent banner, versioned privacy/cookie/terms pages, and right-to-delete
Architecture
form POST
Browser
index.htmlsingle-page views
script.jsapp logic
data.jscontent
i18n.jsEN · PT · ES
localStorageaccounts · progress
Formspree
Founder inbox
Netlify CDN+ security headers
Zero dependencies and zero build step. Vanilla HTML, CSS, and JavaScript (~3k lines), served as static files from Netlify's CDN.
Content is separated from logic. Clubs, checklist, peers, events, and the roadmap live in data.js, so content changes never touch app code.
i18n by key. Elements carry data-i18n keys that resolve against per-language dictionaries in i18n.js.
Security. _headers sets X-Content-Type-Options, X-Frame-Options, Referrer-Policy, and a restrictive Permissions-Policy. User text is HTML-escaped before rendering, and forms include a honeypot field to block spam.
Design decisions
Decision	Why	Trade-off
No backend; accounts in localStorage	Ship and validate demand in days at $0 cost	Accounts don't sync across devices
Passwords stored as salted SHA-256 hashes	Never keep plaintext, even locally	Not a replacement for server-side auth (bcrypt/argon2)
Formspree for all forms	Email delivery without running a server	Free tier is capped at 50 submissions per month
Vanilla JS over React	Fast load, nothing to build, easy to audit	Manual DOM updates as the app grows
Project structure
.
├── index.html                    # all views (home, hub, clubs, peers, community, profile…)
├── script.js                     # app logic, organized into 14 numbered sections
├── data.js                       # content: checklist, clubs, peers, events, roadmap
├── i18n.js                       # EN / PT / ES dictionaries
├── styles.css                    # design tokens at the top (colors, fonts)
├── privacy.html · cookies.html · terms.html
├── _headers                      # Netlify security headers
├── sitemap.xml · robots.txt · site.webmanifest
└── icons, favicon, og-image
Run locally
bash
git clone https://github.com/momacaes9/abroady.git && cd abroady
python -m http.server 8000      # then open http://localhost:8000
Deploy

Drag the folder onto Netlify Drop, or connect this repo for automatic deploys on every push to main.

Roadmap
 Real authentication and a database (Supabase or Firebase) to replace localStorage
 Peer matching on real profiles, with a documented scoring algorithm
 Automated tests and Lighthouse/accessibility checks in GitHub Actions
 University-specific orientation checklists beyond UNC
Status

Prototype / early access. Peer profiles and chat are demo data. Club data is illustrative.

Contact

Monica Macaes · momacaes@unc.edu
## Publish on Netlify (free, ~2 minutes)
1. Unzip this folder.
2. Go to https://app.netlify.com/drop and log in (free account).
3. Drag the whole unzipped **abroady** folder onto the page. You get a link like `https://random-name.netlify.app`.
4. Site configuration → Change site name → `abroady` (if free) so the link becomes `https://abroady.netlify.app`.
5. If your address is different, open `index.html`, `robots.txt` and `sitemap.xml` and replace `https://abroady.netlify.app` with your real address. Drag the folder again (Deploys → drag & drop) to update.

## Formspree (forms → your email)
Already connected to `https://formspree.io/f/xbglevpe` (top of `script.js`).
- Send one test from the live site (Early access form). Formspree may ask you to confirm the first submission by email.
- In Formspree → your form → Settings, you can add `abroady.netlify.app` under allowed domains.
- Free plan: 50 submissions per month.

## Logo in Google
Favicons, the share image and Google's logo data are already set up. To speed it up:
1. Open https://search.google.com/search-console, add your Netlify address (URL prefix) and verify with the HTML-tag option.
2. Submit `sitemap.xml`, then use "URL inspection → Request indexing".
Google usually shows the logo within days to a few weeks.

## Where to edit
- Text in English: `index.html`. Portuguese/Spanish: `i18n.js`.
- Clubs, checklist, peers, events, channels, coming-soon list, approved reviews: `data.js`.
- Your Instagram link: `CHANNELS` in `data.js` (paste the URL, set status to "live").
- Publish a review someone sent you: copy it into `APPROVED_REVIEWS` in `data.js`.
- Your photo: add `monica.jpg` and follow the comment in the About section of `index.html`.
- Colors and fonts: top of `styles.css`.
- Policies: `privacy.html`, `cookies.html`, `terms.html`.

## Files
index.html · styles.css · data.js · i18n.js · script.js · privacy.html · cookies.html · terms.html ·
logo.png · favicon.ico · favicon-48x48.png · favicon-96x96.png · apple-touch-icon.png · icon-192.png · icon-512.png ·
og-image.png · site.webmanifest · robots.txt · sitemap.xml · _headers
