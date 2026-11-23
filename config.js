/* ==========================================================================
   ABROADY — config.js
   Paste your Supabase project URL and publishable (anon) key here.
   Supabase dashboard → Project Settings → API.
   The publishable key is safe in the browser: Row Level Security
   (supabase/migrations) decides what it can read and write.

   Leave both empty and the site keeps working in prototype mode
   (accounts in this browser only, forms emailed through Formspree).
   ========================================================================== */
window.ABROADY_CONFIG = {
  SUPABASE_URL: "",
  SUPABASE_ANON_KEY: "",
  // Also email every form to the founder inbox via Formspree (free tier: 50/month).
  FORMSPREE_COPY: true,
};
