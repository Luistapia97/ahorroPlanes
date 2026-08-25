create extension if not exists pgcrypto;

create table if not exists public.plans (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 120),
  category text not null default 'otro',
  target_date date not null,
  target_cost numeric(12,2) not null check (target_cost >= 0),
  initial numeric(12,2) not null default 0 check (initial >= 0),
  description text not null default '',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.contributions (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans(id) on delete cascade,
  amount numeric(12,2) not null check (amount > 0),
  date date not null default current_date,
  note text not null default '',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 80),
  date date not null,
  time time,
  note text not null default '',
  color text not null default 'gold' check (color in ('gold', 'teal', 'coral', 'sage')),
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.plans enable row level security;
alter table public.contributions enable row level security;
alter table public.activities enable row level security;

drop policy if exists "authenticated users can read plans" on public.plans;
create policy "authenticated users can read plans" on public.plans for select to authenticated using (true);
drop policy if exists "authenticated users can create plans" on public.plans;
create policy "authenticated users can create plans" on public.plans for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "authenticated users can update plans" on public.plans;
create policy "authenticated users can update plans" on public.plans for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete plans" on public.plans;
create policy "authenticated users can delete plans" on public.plans for delete to authenticated using (true);

drop policy if exists "authenticated users can read contributions" on public.contributions;
create policy "authenticated users can read contributions" on public.contributions for select to authenticated using (true);
drop policy if exists "authenticated users can create contributions" on public.contributions;
create policy "authenticated users can create contributions" on public.contributions for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.plans where id = plan_id));
drop policy if exists "authenticated users can update contributions" on public.contributions;
create policy "authenticated users can update contributions" on public.contributions for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete contributions" on public.contributions;
create policy "authenticated users can delete contributions" on public.contributions for delete to authenticated using (true);

drop policy if exists "authenticated users can read activities" on public.activities;
create policy "authenticated users can read activities" on public.activities for select to authenticated using (true);
drop policy if exists "authenticated users can create activities" on public.activities;
create policy "authenticated users can create activities" on public.activities for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "authenticated users can update activities" on public.activities;
create policy "authenticated users can update activities" on public.activities for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete activities" on public.activities;
create policy "authenticated users can delete activities" on public.activities for delete to authenticated using (true);

alter table public.plans replica identity full;
alter table public.contributions replica identity full;
alter table public.activities replica identity full;

do $$
begin
  if not exists (
    select 1
    from pg_publication_rel pr
    join pg_class c on c.oid = pr.prrelid
    join pg_namespace n on n.oid = c.relnamespace
    join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime'
      and n.nspname = 'public'
      and c.relname = 'plans'
  ) then
    alter publication supabase_realtime add table public.plans;
  end if;

  if not exists (
    select 1
    from pg_publication_rel pr
    join pg_class c on c.oid = pr.prrelid
    join pg_namespace n on n.oid = c.relnamespace
    join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime'
      and n.nspname = 'public'
      and c.relname = 'contributions'
  ) then
    alter publication supabase_realtime add table public.contributions;
  end if;

  if not exists (
    select 1
    from pg_publication_rel pr
    join pg_class c on c.oid = pr.prrelid
    join pg_namespace n on n.oid = c.relnamespace
    join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime'
      and n.nspname = 'public'
      and c.relname = 'activities'
  ) then
    alter publication supabase_realtime add table public.activities;
  end if;
end
$$;
