-- Abroady: campus network for the iOS app
-- Universities, verified ambassadors, university-linked campus events, RSVPs,
-- destination cohorts with group chat, and the moderation tools App Review requires
-- for user-generated content (report, block, auto-hide, terms acceptance).

-- ---------------------------------------------------------------------------
-- 1. Universities (home campuses and study-abroad partner sites)
-- ---------------------------------------------------------------------------
create table public.universities (
  id           uuid primary key default gen_random_uuid(),
  name         text not null unique,
  short_name   text not null,
  city         text,
  country      text,
  country_code text check (char_length(country_code) = 2),
  email_domain text,                       -- used to mark students as verified
  kind         text not null default 'home' check (kind in ('home', 'partner', 'both')),
  created_at   timestamptz not null default now()
);
alter table public.universities enable row level security;
create policy "universities: public read" on public.universities for select to anon, authenticated using (true);

insert into public.universities (name, short_name, city, country, country_code, email_domain, kind) values
  ('University of North Carolina at Chapel Hill', 'UNC', 'Chapel Hill', 'United States', 'US', 'unc.edu', 'home'),
  ('UNSW Sydney', 'UNSW', 'Sydney', 'Australia', 'AU', 'unsw.edu.au', 'partner'),
  ('Korea University', 'Korea U', 'Seoul', 'South Korea', 'KR', 'korea.ac.kr', 'partner'),
  ('University of Granada', 'UGR', 'Granada', 'Spain', 'ES', 'ugr.es', 'partner'),
  ('University of Limerick', 'UL', 'Limerick', 'Ireland', 'IE', 'ul.ie', 'partner'),
  ('University of Stirling', 'Stirling', 'Stirling', 'United Kingdom', 'GB', 'stir.ac.uk', 'partner'),
  ('Veritas University', 'Veritas', 'San José', 'Costa Rica', 'CR', null, 'partner');

-- ---------------------------------------------------------------------------
-- 2. Profiles: university links, role, verification, terms
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column university_id     uuid references public.universities (id) on delete set null,
  add column destination_id    uuid references public.universities (id) on delete set null,
  add column role              text not null default 'student' check (role in ('student', 'ambassador', 'admin')),
  add column verified_student  boolean not null default false,
  add column terms_accepted_at timestamptz;

-- Users may edit their own profile but never their role or verification.
revoke insert, update on public.profiles from anon, authenticated;
grant update (name, country, year, term, destination, international, discoverable, language,
              university_id, destination_id, terms_accepted_at, updated_at)
  on public.profiles to authenticated;

create or replace function public.is_staff(p_roles text[] default array['ambassador', 'admin'])
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = any (p_roles));
$$;

-- Sign-up trigger: profile + progress + verified flag from the university email domain
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_uni uuid := nullif(new.raw_user_meta_data ->> 'university_id', '')::uuid;
  v_domain text := lower(split_part(new.email, '@', 2));
begin
  if v_uni is null then
    select id into v_uni from public.universities u
    where u.email_domain is not null and (v_domain = u.email_domain or v_domain like '%.' || u.email_domain)
    limit 1;
  end if;

  insert into public.profiles (id, name, country, year, term, international, consent_version, language,
                               university_id, destination_id, verified_student, terms_accepted_at)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'country',
    nullif(new.raw_user_meta_data ->> 'year', ''),
    new.raw_user_meta_data ->> 'term',
    coalesce((new.raw_user_meta_data ->> 'international')::boolean, false),
    new.raw_user_meta_data ->> 'consent_version',
    nullif(new.raw_user_meta_data ->> 'language', ''),
    v_uni,
    nullif(new.raw_user_meta_data ->> 'destination_id', '')::uuid,
    exists (select 1 from public.universities u
            where u.email_domain is not null and (v_domain = u.email_domain or v_domain like '%.' || u.email_domain)),
    case when (new.raw_user_meta_data ->> 'terms_accepted')::boolean then now() end
  );
  insert into public.user_progress (user_id) values (new.id);
  return new;
end $$;

-- ---------------------------------------------------------------------------
-- 3. Ambassadors (verified by Abroady/university staff) + questions to them
-- ---------------------------------------------------------------------------
create table public.ambassadors (
  id                 uuid primary key default gen_random_uuid(),
  user_id            uuid unique references auth.users (id) on delete set null,
  name               text not null check (char_length(name) between 1 and 80),
  university_id      uuid not null references public.universities (id),   -- where they help (campus or abroad site)
  home_university_id uuid references public.universities (id),
  term               text check (char_length(term) <= 40),
  major              text check (char_length(major) <= 80),
  languages          text[] not null default '{}',
  bio                text check (char_length(bio) <= 600),
  verified           boolean not null default false,
  active             boolean not null default true,
  created_at         timestamptz not null default now()
);
alter table public.ambassadors enable row level security;
create policy "ambassadors: public read verified" on public.ambassadors
  for select to anon, authenticated using (verified and active);

create table public.ambassador_applications (
  id            bigint generated always as identity primary key,
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  university_id uuid references public.universities (id),
  term          text check (char_length(term) <= 40),
  why           text not null check (char_length(why) between 1 and 1000),
  status        text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at    timestamptz not null default now()
);
alter table public.ambassador_applications enable row level security;
create policy "applications: insert own" on public.ambassador_applications
  for insert to authenticated with check (user_id = auth.uid() and status = 'pending');
create policy "applications: read own" on public.ambassador_applications
  for select to authenticated using (user_id = auth.uid());

create table public.ambassador_questions (
  id            bigint generated always as identity primary key,
  ambassador_id uuid not null references public.ambassadors (id) on delete cascade,
  asker_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  body          text not null check (char_length(body) between 1 and 1000),
  answer        text check (char_length(answer) <= 2000),
  answered_at   timestamptz,
  created_at    timestamptz not null default now()
);
alter table public.ambassador_questions enable row level security;
create policy "questions: ask" on public.ambassador_questions
  for insert to authenticated with check (asker_id = auth.uid() and answer is null);
create policy "questions: read mine or my inbox" on public.ambassador_questions
  for select to authenticated using (
    asker_id = auth.uid()
    or exists (select 1 from public.ambassadors a where a.id = ambassador_id and a.user_id = auth.uid()));
create policy "questions: ambassador answers" on public.ambassador_questions
  for update to authenticated using (
    exists (select 1 from public.ambassadors a where a.id = ambassador_id and a.user_id = auth.uid()));
revoke update on public.ambassador_questions from anon, authenticated;
grant update (answer, answered_at) on public.ambassador_questions to authenticated;

-- ---------------------------------------------------------------------------
-- 4. Campus events linked to a university, approved before going public
-- ---------------------------------------------------------------------------
create table public.events (
  id            uuid primary key default gen_random_uuid(),
  university_id uuid not null references public.universities (id) on delete cascade,
  title         text not null check (char_length(title) between 1 and 120),
  description   text check (char_length(description) <= 2000),
  starts_at     timestamptz not null,
  ends_at       timestamptz,
  location      text check (char_length(location) <= 200),
  host_name     text check (char_length(host_name) <= 120),
  host_type     text not null default 'club' check (host_type in ('university', 'club', 'ambassador', 'abroady')),
  url           text check (url ~* '^https://'),
  audience      text not null default 'all' check (audience in ('all', 'international', 'first_year', 'study_abroad')),
  verified      boolean not null default false,
  created_by    uuid default auth.uid() references auth.users (id) on delete set null,
  created_at    timestamptz not null default now(),
  check (ends_at is null or ends_at >= starts_at)
);
alter table public.events enable row level security;
create policy "events: public read approved" on public.events
  for select to anon, authenticated using (verified or created_by = auth.uid());
create policy "events: ambassadors submit" on public.events
  for insert to authenticated with check (created_by = auth.uid() and not verified and public.is_staff());

create table public.event_rsvps (
  event_id   uuid not null references public.events (id) on delete cascade,
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (event_id, user_id)
);
alter table public.event_rsvps enable row level security;
create policy "rsvps: read own"   on public.event_rsvps for select to authenticated using (user_id = auth.uid());
create policy "rsvps: insert own" on public.event_rsvps for insert to authenticated with check (user_id = auth.uid());
create policy "rsvps: delete own" on public.event_rsvps for delete to authenticated using (user_id = auth.uid());

-- Public "N going" counts without exposing who
create view public.event_going with (security_invoker = false) as
  select e.id as event_id, count(r.user_id)::int as going
  from public.events e left join public.event_rsvps r on r.event_id = e.id
  where e.verified
  group by e.id;
grant select on public.event_going to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 5. Cohorts: everyone going to the same destination in the same term
-- ---------------------------------------------------------------------------
create table public.cohorts (
  id             uuid primary key default gen_random_uuid(),
  destination_id uuid not null references public.universities (id) on delete cascade,
  term           text not null check (char_length(term) between 1 and 40),
  created_at     timestamptz not null default now(),
  unique (destination_id, term)
);
alter table public.cohorts enable row level security;
create policy "cohorts: read" on public.cohorts for select to authenticated using (true);

create table public.cohort_members (
  cohort_id uuid not null references public.cohorts (id) on delete cascade,
  user_id   uuid not null default auth.uid() references auth.users (id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (cohort_id, user_id)
);
alter table public.cohort_members enable row level security;
create policy "members: read own" on public.cohort_members for select to authenticated using (user_id = auth.uid());
create policy "members: leave"    on public.cohort_members for delete to authenticated using (user_id = auth.uid());

create or replace function public.is_cohort_member(p_cohort uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.cohort_members where cohort_id = p_cohort and user_id = auth.uid());
$$;

-- Join (or create) the cohort for a destination + term; returns the cohort id
create or replace function public.join_cohort(p_destination uuid, p_term text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  insert into public.cohorts (destination_id, term) values (p_destination, p_term)
    on conflict (destination_id, term) do nothing;
  select id into v_id from public.cohorts where destination_id = p_destination and term = p_term;
  insert into public.cohort_members (cohort_id, user_id) values (v_id, auth.uid())
    on conflict do nothing;
  update public.profiles set destination_id = p_destination, term = p_term, updated_at = now() where id = auth.uid();
  return v_id;
end $$;
revoke all on function public.join_cohort(uuid, text) from public, anon;
grant execute on function public.join_cohort(uuid, text) to authenticated;

create or replace function public.cohort_size(p_cohort uuid)
returns int language sql stable security definer set search_path = '' as $$
  select count(*)::int from public.cohort_members where cohort_id = p_cohort;
$$;
grant execute on function public.cohort_size(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Cohort messages + moderation (App Store guideline 1.2)
-- ---------------------------------------------------------------------------
create table public.messages (
  id           bigint generated always as identity primary key,
  cohort_id    uuid not null references public.cohorts (id) on delete cascade,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  display_name text not null default '',
  verified     boolean not null default false,
  body         text not null check (char_length(btrim(body)) between 1 and 1000),
  hidden       boolean not null default false,
  created_at   timestamptz not null default now()
);
create index messages_cohort_created on public.messages (cohort_id, created_at desc);
alter table public.messages enable row level security;
create policy "messages: members read" on public.messages
  for select to authenticated using (not hidden and public.is_cohort_member(cohort_id));
create policy "messages: members post after accepting terms" on public.messages
  for insert to authenticated with check (
    user_id = auth.uid()
    and public.is_cohort_member(cohort_id)
    and exists (select 1 from public.profiles p where p.id = auth.uid() and p.terms_accepted_at is not null));
create policy "messages: delete own" on public.messages
  for delete to authenticated using (user_id = auth.uid());

-- Name + badge come from the profile, never from the client
create or replace function public.stamp_message()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  select split_part(p.name, ' ', 1) || coalesce(' ' || left(nullif(split_part(p.name, ' ', 2), ''), 1) || '.', ''),
         p.verified_student
    into new.display_name, new.verified
  from public.profiles p where p.id = new.user_id;
  new.hidden := false;
  return new;
end $$;
create trigger messages_stamp before insert on public.messages
  for each row execute function public.stamp_message();

create table public.reports (
  id               bigint generated always as identity primary key,
  reporter_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  message_id       bigint references public.messages (id) on delete set null,
  reported_user_id uuid references auth.users (id) on delete set null,
  reason           text not null check (reason in ('spam', 'harassment', 'hate', 'sexual', 'scam', 'safety', 'other')),
  details          text check (char_length(details) <= 1000),
  status           text not null default 'open' check (status in ('open', 'actioned', 'dismissed')),
  created_at       timestamptz not null default now()
);
alter table public.reports enable row level security;
create policy "reports: file own" on public.reports
  for insert to authenticated with check (reporter_id = auth.uid() and status = 'open');

-- Three distinct reports hide a message until a moderator reviews it
create or replace function public.auto_hide_reported()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.message_id is not null and
     (select count(distinct reporter_id) from public.reports where message_id = new.message_id) >= 3 then
    update public.messages set hidden = true where id = new.message_id;
  end if;
  return new;
end $$;
create trigger reports_auto_hide after insert on public.reports
  for each row execute function public.auto_hide_reported();

create table public.blocks (
  blocker_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
alter table public.blocks enable row level security;
create policy "blocks: read own"   on public.blocks for select to authenticated using (blocker_id = auth.uid());
create policy "blocks: insert own" on public.blocks for insert to authenticated with check (blocker_id = auth.uid());
create policy "blocks: delete own" on public.blocks for delete to authenticated using (blocker_id = auth.uid());

-- ---------------------------------------------------------------------------
-- 7. Traction view, now including the campus network
-- ---------------------------------------------------------------------------
drop view public.traction;
create view public.traction with (security_invoker = true) as
  select
    (select count(*) from public.profiles)                                              as accounts,
    (select count(*) from public.profiles where international)                          as international_accounts,
    (select count(*) from public.profiles where verified_student)                       as verified_students,
    (select count(*) from public.early_access)                                          as early_access_signups,
    (select count(distinct lower(email)) from public.early_access)                      as early_access_unique_emails,
    (select count(*) from public.event_subscribers)                                     as event_subscribers,
    (select count(*) from public.reviews)                                               as reviews_submitted,
    (select round(avg(rating), 2) from public.reviews where status = 'approved')        as avg_rating,
    (select count(*) from public.profiles where created_at > now() - interval '7 days') as accounts_last_7_days,
    (select count(*) from public.cohort_members)                                        as cohort_members,
    (select count(*) from public.messages)                                              as messages_sent,
    (select count(*) from public.event_rsvps)                                           as event_rsvps,
    (select count(*) from public.ambassadors where verified)                            as verified_ambassadors;
revoke all on public.traction from anon, authenticated;
