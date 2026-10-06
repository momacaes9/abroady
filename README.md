# Abroady — website

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
