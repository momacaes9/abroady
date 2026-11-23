# App Store submission checklist (Abroady)

The common rejection reasons, what this codebase already does about each, and what is still on you.
✅ = handled in code · ☐ = you need to do it before submitting.

## Accounts & money
- ☐ **Apple Developer Program**: $99/year. Enroll as an *Individual* (your name shows as the seller) or as an *Organization* (needs a legal entity and a D-U-N-S number; this is where an LLC matters). Talk to UNC ISSS before running a business on an F-1.
- ☐ **Xcode 26+ / iOS 26 SDK**: required for uploads since Apr 28, 2026. Install Xcode from the Mac App Store (this Mac currently has only Command Line Tools).

## Guideline 2.1: Completeness (the #1 rejection)
- ✅ Demo mode is labeled "Demo" everywhere and only runs without backend keys.
- ☐ Ship with **Supabase keys set** in `Config.swift`. A build in demo mode **will** be rejected as placeholder content.
- ☐ **Real content on day one**: at least 5–10 approved real UNC events and 2–3 verified ambassadors (you can be the first one, for UNSW Spring 2027).
- ☐ **Reviewer account** in App Review notes: a confirmed email/password that is already in a cohort with a few messages. Explain that chat is cohort-based.
- ☐ Test every link (privacy, terms, support mail, event URLs) on a real device. No crashes on launch with airplane mode on.

## Guideline 1.2: User-generated content (chat, questions)
- ✅ Community rules (EULA) must be accepted before posting; zero-tolerance wording.
- ✅ Report message / ambassador, with reasons; block user; auto-hide after 3 reports.
- ✅ Content filter for objectionable text.
- ✅ Contact info in the app (Profile → Contact support).
- ☐ **Actually act on reports within 24 hours** (check the `reports` table daily) and say so in the review notes.

## Guideline 5.1.1: Privacy & accounts
- ✅ Browsing (Explore, Events, Ambassadors, Checklist) works **without an account**; login only for RSVP, questions and chat.
- ✅ **In-app account deletion** (Profile → Delete account) removes the auth user and cascades all data.
- ✅ Privacy policy + terms linked in the app.
- ✅ `PrivacyInfo.xcprivacy` declares name, email and user content (app functionality, not tracking) and the UserDefaults API reason.
- ☐ Privacy policy URL in App Store Connect + **App Privacy "nutrition label"** answers matching the manifest (Name, Email, Other user content; linked to user; not used for tracking).
- ☐ Update `privacy.html` to mention the iOS app, Supabase as processor, chat messages, and deletion.

## Guideline 4.2 / 4.3: Minimum functionality & spam
- ✅ Native SwiftUI (not a website wrapper): tabs, offline checklist, Keychain session, pull-to-refresh, share sheet.
- ✅ Distinct from travel-buddy apps: university-linked cohorts, verified ambassadors, approved campus events.
- ☐ Description + screenshots should lead with that difference, not "meet travelers".

## Guideline 4.8: Sign in with Apple
- ✅ Not required: the app only uses its own email/password accounts. If you add Google/Instagram login later, you must add Sign in with Apple too.

## Metadata
- ☐ App name, subtitle (≤30 chars, e.g. "Your study-abroad cohort"), keywords, category **Education**.
- ☐ Screenshots: 6.9" iPhone (required). The app is iPhone-only for v1, so no iPad screenshots needed.
- ☐ Age rating questionnaire: answer **Yes** to user-generated content and messaging. Expect a higher rating; that's fine.
- ☐ Support URL (e.g. `https://abroady.netlify.app/#about`) and marketing URL.
- ☐ Replace the app icon with a high-resolution version of the logo (current one is upscaled from 240 px).
- ✅ `ITSAppUsesNonExemptEncryption = NO` (only HTTPS), so no export-compliance prompt on each upload.

## Before pressing Submit
1. Archive in Xcode (Product → Archive) → Distribute → App Store Connect.
2. Test the uploaded build with **TestFlight** on 5–10 real students first (it also gives you traction numbers for the 1789 reapplication).
3. Submit; first reviews usually take 1–3 days. If rejected, reply in Resolution Center point by point, citing the guideline and what changed.

Sources: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/), [SDK requirement](https://developer.apple.com/news/upcoming-requirements/?id=04282026a), [RevenueCat rejection guide](https://www.revenuecat.com/blog/growth/the-ultimate-guide-to-app-store-rejections).
