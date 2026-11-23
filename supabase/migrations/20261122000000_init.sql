-- Abroady: initial schema
-- Real accounts (Supabase Auth), synced progress, and every site form stored in Postgres.
-- Row Level Security is ON for every table: the public (anon) key can only do what the policies below allow.

-- ---------------------------------------------------------------------------
-- 1. Profiles: one row per auth user
-- ---------------------------------------------------------------------------
create table public.profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  name            text not null check (char_length(name) between 1 and 120),
  country         text check (char_length(country) <= 80),
  year            text check (year in ('1', '2', '3')),
  term            text check (char_length(term) <= 40),
  destination     text check (char_length(destination) <= 80),
  international   boolean not null default false,
  discoverable    boolean not null default true,   -- show me to peers going to the same term
  consent_version text,
  language        text check (language in ('en', 'pt', 'es')),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
alter table public.profiles enable row level security;

create policy "profiles: read own"   on public.profiles for select using (auth.uid() = id);
create policy "profiles: insert own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles: update own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Create the profile automatically from the sign-up metadata, so it exists even
-- when email confirmation is on and the client has no session yet.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, name, country, year, term, international, consent_version, language)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'name', ''), split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'country',
    nullif(new.raw_user_meta_data ->> 'year', ''),
    new.raw_user_meta_data ->> 'term',
    coalesce((new.raw_user_meta_data ->> 'international')::boolean, false),
    new.raw_user_meta_data ->> 'consent_version',
    nullif(new.raw_user_meta_data ->> 'language', '')
  );
  insert into public.user_progress (user_id) values (new.id);
  return new;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Progress: checklist + joined clubs, synced across devices
-- ---------------------------------------------------------------------------
create table public.user_progress (
  user_id      uuid primary key references auth.users (id) on delete cascade,
  checklist    text[] not null default '{}',
  joined_clubs text[] not null default '{}',
  updated_at   timestamptz not null default now()
);
alter table public.user_progress enable row level security;

create policy "progress: read own"   on public.user_progress for select using (auth.uid() = user_id);
create policy "progress: insert own" on public.user_progress for insert with check (auth.uid() = user_id);
create policy "progress: update own" on public.user_progress for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 3. Public forms: anyone may INSERT, nobody may read through the API
--    (Monica reads them in the Supabase dashboard / SQL editor)
-- ---------------------------------------------------------------------------
create table public.early_access (
  id            bigint generated always as identity primary key,
  name          text not null check (char_length(name) between 1 and 120),
  email         text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  university    text check (char_length(university) <= 120),
  year          text check (char_length(year) <= 40),
  destination   text check (char_length(destination) <= 80),
  international boolean not null default false,
  language      text,
  source        text check (char_length(source) <= 200),
  created_at    timestamptz not null default now()
);

create table public.contact_messages (
  id         bigint generated always as identity primary key,
  name       text not null check (char_length(name) between 1 and 120),
  email      text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  reason     text check (char_length(reason) <= 60),
  message    text not null check (char_length(message) between 1 and 2000),
  language   text,
  created_at timestamptz not null default now()
);

create table public.event_subscribers (
  id         bigint generated always as identity primary key,
  email      text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  language   text,
  created_at timestamptz not null default now()
);

create table public.reviews (
  id         bigint generated always as identity primary key,
  name       text not null check (char_length(name) between 1 and 80),
  role       text check (char_length(role) <= 80),
  email      text not null check (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  rating     smallint not null check (rating between 1 and 5),
  text       text not null check (char_length(text) between 1 and 600),
  status     text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  language   text,
  created_at timestamptz not null default now()
);

alter table public.early_access      enable row level security;
alter table public.contact_messages  enable row level security;
alter table public.event_subscribers enable row level security;
alter table public.reviews           enable row level security;

create policy "early_access: anyone can join"     on public.early_access      for insert to anon, authenticated with check (true);
create policy "contact: anyone can write"         on public.contact_messages  for insert to anon, authenticated with check (true);
create policy "events: anyone can subscribe"      on public.event_subscribers for insert to anon, authenticated with check (true);
create policy "reviews: anyone can submit"        on public.reviews           for insert to anon, authenticated with check (status = 'pending');

-- Approved reviews are public, but never expose the reviewer's email
create view public.approved_reviews with (security_invoker = false) as
  select id, name, role, rating, text, created_at
  from public.reviews
  where status = 'approved';
grant select on public.approved_reviews to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 4. Peer match: real students with the same term, first name + initial only
-- ---------------------------------------------------------------------------
create or replace function public.match_peers(p_term text, p_destination text default null)
returns table (id uuid, display_name text, year text, country text, term text, destination text, international boolean)
language sql stable security definer set search_path = '' as $$
  select p.id,
         split_part(p.name, ' ', 1) || coalesce(' ' || left(nullif(split_part(p.name, ' ', 2), ''), 1) || '.', ''),
         p.year, p.country, p.term, p.destination, p.international
  from public.profiles p
  where auth.uid() is not null           -- only logged-in students can see peers
    and p.discoverable
    and p.id <> auth.uid()
    and p.term = p_term
    and (p_destination is null or p.destination = p_destination)
  order by p.created_at desc
  limit 50;
$$;
revoke all on function public.match_peers(text, text) from public, anon;
grant execute on function public.match_peers(text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Right to delete: a user can remove their own account and all their data
-- ---------------------------------------------------------------------------
create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  delete from auth.users where id = auth.uid();   -- cascades to profiles + user_progress
end $$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Traction dashboard (dashboard / service role only, not exposed to anon)
-- ---------------------------------------------------------------------------
create view public.traction with (security_invoker = true) as
  select
    (select count(*) from public.profiles)                                         as accounts,
    (select count(*) from public.profiles where international)                     as international_accounts,
    (select count(*) from public.early_access)                                     as early_access_signups,
    (select count(distinct lower(email)) from public.early_access)                 as early_access_unique_emails,
    (select count(*) from public.event_subscribers)                                as event_subscribers,
    (select count(*) from public.reviews)                                          as reviews_submitted,
    (select round(avg(rating), 2) from public.reviews where status = 'approved')   as avg_rating,
    (select count(*) from public.profiles where created_at > now() - interval '7 days') as accounts_last_7_days;
revoke all on public.traction from anon, authenticated;
