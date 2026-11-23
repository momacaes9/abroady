# Abroady — Funding Plan

_Last updated: Nov 22, 2026. Figures and deadlines come from the linked sources; re-check them before applying._

## 1. Why the fall 1789 application didn't land, and the fix

The [1789 Student Venture Fund](https://innovate.unc.edu/1789-student-venture-fund) scores three things:

| Criterion | What judges look for | Where Abroady stood (fall) | Fix before spring |
|---|---|---|---|
| **Proof of concept** | Customer discovery, market research, progress toward a prototype | Strong market data, live prototype, but **no user numbers** | Real sign-ups + survey results from Supabase (`traction` view) |
| **Idea** | Revenue potential or social impact, clear theory of change | SDG 4/10 story, no revenue model | One slide: free for students → paid tier for universities/program providers |
| **Team / founder** | Commitment + ties to UNC's innovation ecosystem | Solo founder | Add 1–2 co-founders/advisors; cite Pitch Fest, E-@Ccelerator, Spring Forward cohort |

Funding goes where money is "instrumental to progress": the application needs **a budget for 3- and 6-month goals, with third-party cost quotes**, and proof of what was done with $0.

**Reapply:** a team not funded in the fall can reapply in the spring. Spring cycle **opens Jan 1, closes Feb 15**; decisions ~5 weeks later.

## 2. Traction targets before Feb 15

All of these are counted automatically in Supabase (`select * from traction;`):

- [ ] 150+ early-access sign-ups (UNC first-years + internationals, Spring Forward / Global Launch cohorts)
- [ ] 40+ real accounts with a study-abroad term
- [ ] 30+ survey responses / customer interviews (pain: scattered info, finding peers)
- [ ] 1 verified cohort page: UNSW Sydney, Spring 2027 (founder's own cohort)
- [ ] 1 letter of support or meeting with UNC Study Abroad / BRASA / an international student org
- [ ] Track sources with `?ref=` links (e.g. `abroady.netlify.app/?ref=brasa`), saved in `early_access.source`

## 3. Draft 6-month budget (ask: ~$1,500)

| Item | Cost | Why it's instrumental |
|---|---|---|
| Custom domain (1 yr) | ~$15 | Trust for university partners |
| Supabase Pro (if free tier limits are hit) | $25/mo × 6 | Real accounts, auth emails, backups |
| Transactional email (Resend/Postmark) | ~$0–20/mo | Confirmation + cohort emails beyond free caps |
| Flyers / tabling at orientation + Spring Forward info sessions | ~$300 | Customer acquisition at the source |
| Incentives for 30 customer interviews ($10 gift cards) | $300 | Proof of concept |
| Apple Developer Program (iOS version) | $99 | Native app for cohorts abroad |
| Contingency | ~$200 | |

Replace estimates with real quotes before submitting.

## 4. Other funding to stack

| Source | Amount | Notes |
|---|---|---|
| [1789 Student Venture Fund](https://innovate.unc.edu/1789-student-venture-fund) | No min/max (historically $100–$2,500) | Spring: Jan 1 – Feb 15 |
| [Dreamers-Who-Do Award](https://innovate.unc.edu/resources/get-funding) | Not stated | Projects, events, competition travel |
| [Davis Projects for Peace](https://innovate.unc.edu/resources/get-funding) | $10,000 | Summer grassroots project; UNC is a Davis UWC school |
| [Robert E. Bryan Fellowship](https://innovate.unc.edu/resources/get-funding) | Up to $1,500 | Social change; applications mid-October (next cycle Oct 2027) |
| [Do Something Awards](https://innovate.unc.edu/resources/get-funding) | $10k finalists / $100k grand prize | Age 25 and under |
| [NC IDEA Seed Grant](https://innovate.unc.edu/resources/get-funding) | Up to $50,000 | NC high-growth startups; later stage, needs traction |
| Shuford minor awards (JNO $5k, LeighDeux $2.5k) | $2.5k–$5k | Requires the entrepreneurship minor |

## 5. LLC / Rho: when and how

- [Rho](https://www.rho.co/grow/free-incorporation) can form an **LLC or Delaware C-corp** and open the business account in the same flow; the incorporation fee is reimbursed if $10,000 is deposited within 90 days. Rho is a fintech; accounts are held at partner banks.
- **Not needed yet.** None of the student grants above require an entity. Form one when there is money to receive as a business, a contract to sign, or revenue.
- **Visa check first (important):** as an F-1 student, *owning* a company is generally allowed, but *working* for it (operating, earning) can count as unauthorized employment unless covered by CPT/OPT. Talk to **UNC ISSS** and a startup attorney (e.g. UNC School of Law clinics, Innovate Carolina's venture services) **before** forming the LLC. This is not legal advice.
- If/when ready: a single-member LLC is simplest for grants; a Delaware C-corp is what VCs expect. Decide with the attorney.
