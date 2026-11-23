# Abroady for iOS

Native SwiftUI app (iOS 17+, iPhone) for first-year and international students:
**find your study-abroad cohort, meet verified ambassadors, and never miss a campus event.**
Shares the Supabase backend with the website (`../supabase/migrations`).

| Tab | What it does |
|---|---|
| **Explore** | Partner destinations (UNSW, Korea U, Granada, Limerick, Stirling, Veritas) → pick a term → cohort group chat |
| **Events** | Real campus events linked to a university, approved before going public. RSVP + "N going" |
| **Ambassadors** | Verified students at home campuses and abroad sites. Ask private questions; ambassadors answer from an in-app inbox |
| **Checklist** | F-1/J-1 arrival checklist (same as the website), synced across devices |
| **Profile** | Edit profile, become an ambassador, community rules, privacy/terms/support, log out, **delete account** |

**How it differs from TripBFF:** TripBFF matches solo travelers (18+). Abroady is tied to universities:
cohorts are built from the programs your university already runs, ambassadors are verified students from those
programs, and events come from campuses and clubs, not strangers.

## Run it

Requires a Mac with **Xcode 26+** (App Store uploads require the iOS 26 SDK since Apr 28, 2026).

```bash
brew install xcodegen          # once
cd ios
xcodegen generate              # creates Abroady.xcodeproj from project.yml
open Abroady.xcodeproj
```

In Xcode: **Signing & Capabilities → Team** → your Apple Developer team, then Run on a simulator.

- **No keys in `Abroady/App/Config.swift`** → demo mode with clearly labeled sample data (for development only).
- **Real backend:** paste the Supabase URL + publishable key (same as `../config.js`) into `Config.swift`, after running both SQL files in `../supabase/migrations` in order.

## Architecture

- **Zero third-party packages.** `SupabaseClient` is a small actor over `URLSession` (Auth + PostgREST + RPC); the session lives in the Keychain.
- `AppModel` (`@Observable`) holds state; views read it from the environment.
- Server-side safety: Row Level Security everywhere, display names and the Verified badge are stamped by a trigger (clients can't fake them), 3 reports auto-hide a message, users can't change their own role.
- Client-side safety: `ContentFilter` blocks slurs, explicit terms and common scams in EN/PT/ES before sending.

## Admin tasks (Supabase dashboard)

| Task | Where |
|---|---|
| Approve an event | `events` → set `verified = true` |
| Approve an ambassador | `ambassador_applications` → create a row in `ambassadors` (`verified = true`, `user_id`), set the user's `profiles.role = 'ambassador'` |
| Review reports (**within 24 h**, App Review checks this) | `reports` where `status = 'open'`; delete the message or the user, set `status` |
| See traction for pitches | `select * from traction;` |

Before submitting, read [APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md).
