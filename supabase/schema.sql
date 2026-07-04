-- KNOT — run this whole file in Supabase SQL Editor.

create table couples (
  id uuid primary key default gen_random_uuid(),
  user_a uuid references auth.users not null,
  user_b uuid references auth.users,
  invite_code text unique not null,
  created_at timestamptz default now()
);

create table drops (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid references couples not null,
  sender uuid references auth.users not null,
  image_url text not null,
  created_at timestamptz default now()
);

create table messages (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid references couples not null,
  sender uuid references auth.users not null,
  body text not null,
  created_at timestamptz default now()
);

create table countdowns (
  id uuid primary key default gen_random_uuid(),
  couple_id uuid references couples not null,
  title text not null,
  date date not null,
  created_at timestamptz default now()
);

-- RLS: only the two members of a couple can see its data.
alter table couples enable row level security;
alter table drops enable row level security;
alter table messages enable row level security;
alter table countdowns enable row level security;

create policy "members read couple" on couples for select
  using (auth.uid() = user_a or auth.uid() = user_b);
create policy "create couple" on couples for insert
  with check (auth.uid() = user_a);

create or replace function is_member(cid uuid) returns boolean
language sql security definer as $$
  select exists (
    select 1 from couples
    where id = cid and (user_a = auth.uid() or user_b = auth.uid())
  );
$$;

create policy "members drops" on drops for all
  using (is_member(couple_id)) with check (is_member(couple_id) and sender = auth.uid());
create policy "members messages" on messages for all
  using (is_member(couple_id)) with check (is_member(couple_id) and sender = auth.uid());
create policy "members countdowns" on countdowns for all
  using (is_member(couple_id)) with check (is_member(couple_id));

-- Join by invite code (bypasses RLS safely).
create or replace function join_couple(p_code text) returns boolean
language plpgsql security definer as $$
declare c couples%rowtype;
begin
  select * into c from couples where invite_code = p_code and user_b is null;
  if not found or c.user_a = auth.uid() then return false; end if;
  update couples set user_b = auth.uid() where id = c.id;
  return true;
end;
$$;

-- Realtime
alter publication supabase_realtime add table couples, drops, messages, countdowns;

-- Storage: create a PUBLIC bucket named "drops" in the dashboard,
-- then add this policy:
create policy "members upload" on storage.objects for insert
  with check (bucket_id = 'drops' and auth.role() = 'authenticated');
