-- Coronado Tram — initial schema
-- Recreated after the original project was lost. Mirrors what the
-- client code in index.html / schedule.html / meetings.html /
-- travelogue.html already expects.

create extension if not exists pgcrypto;

-- ── Community board posts ──────────────────────────────────────────
create table if not exists posts (
  id uuid primary key,
  author text not null,
  type text not null,
  text text not null,
  date text not null,
  reactions jsonb not null default '{"❤️":0,"💡":0,"🤣":0,"👀":0}'::jsonb,
  vote_options jsonb,
  image_data text,
  created_at timestamptz not null default now()
);
alter table posts enable row level security;
create policy "public read"   on posts for select using (true);
create policy "public insert" on posts for insert with check (true);
create policy "public update" on posts for update using (true);

-- ── Cart reservations & meeting entries on the schedule page ───────
create table if not exists reservations (
  id uuid primary key,
  type text not null,               -- 'cart' | 'meeting'
  title text not null,
  author text not null,
  res_date date not null,
  time_start text,
  time_end text,
  notes text,
  created_at timestamptz not null default now()
);
alter table reservations enable row level security;
create policy "public read"   on reservations for select using (true);
create policy "public insert" on reservations for insert with check (true);
create policy "public delete" on reservations for delete using (true);

-- ── Scheduled meetings ───────────────────────────────────────────────
create table if not exists meetings (
  id uuid primary key,
  title text not null,
  meeting_date date not null,
  meeting_time text,
  attendees text,
  notes text,
  created_at timestamptz not null default now()
);
alter table meetings enable row level security;
create policy "public read"   on meetings for select using (true);
create policy "public insert" on meetings for insert with check (true);

-- ── Travelogue entries ──────────────────────────────────────────────
create table if not exists travelogue (
  id uuid primary key,
  author text not null,
  event_title text not null,
  event_date date,
  description text,
  media_type text not null,          -- 'photo' | 'video'
  image_data text,
  video_url text,
  embed_url text,
  created_at timestamptz not null default now()
);
alter table travelogue enable row level security;
create policy "public read"   on travelogue for select using (true);
create policy "public insert" on travelogue for insert with check (true);

-- ── Realtime: broadcast changes on all four tables ──────────────────
alter publication supabase_realtime add table posts, reservations, meetings, travelogue;
