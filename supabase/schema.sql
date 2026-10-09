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
  reminder_at timestamptz,
  reminder_sent boolean not null default false,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.activities add column if not exists reminder_at timestamptz;
alter table public.activities add column if not exists reminder_sent boolean not null default false;

create table if not exists public.user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  default_cycle_length integer not null default 28 check (default_cycle_length between 21 and 45),
  default_period_length integer not null default 5 check (default_period_length between 1 and 14),
  updated_at timestamptz not null default now()
);

create table if not exists public.cycles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  start_date date not null,
  end_date date,
  cycle_length integer check (cycle_length is null or cycle_length > 0),
  created_at timestamptz not null default now(),
  check (end_date is null or end_date >= start_date)
);

-- Último día de sangrado del periodo (end_date es el cierre del ciclo completo, cuando inicia el siguiente).
alter table public.cycles add column if not exists period_end_date date;
alter table public.cycles drop constraint if exists cycles_period_end_check;
alter table public.cycles add constraint cycles_period_end_check check (period_end_date is null or (period_end_date >= start_date and period_end_date <= start_date + 13));

create table if not exists public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  flow_intensity text not null default 'none' check (flow_intensity in ('none', 'light', 'medium', 'heavy')),
  symptoms text[] not null default '{}',
  mood text[] not null default '{}',
  had_sex boolean not null default false,
  protection_used boolean,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, date)
);

alter table public.daily_logs add column if not exists had_sex boolean not null default false;
alter table public.daily_logs add column if not exists protection_used boolean;
alter table public.daily_logs drop constraint if exists daily_logs_sex_protection_check;
alter table public.daily_logs add constraint daily_logs_sex_protection_check check ((had_sex = false and protection_used is null) or had_sex = true);

-- Señales de ovulación: prueba de LH, moco cervical y temperatura basal (°C).
alter table public.daily_logs add column if not exists lh_test text not null default 'none';
alter table public.daily_logs drop constraint if exists daily_logs_lh_test_check;
alter table public.daily_logs add constraint daily_logs_lh_test_check check (lh_test in ('none', 'negative', 'positive'));
alter table public.daily_logs add column if not exists cervical_mucus text not null default 'none';
alter table public.daily_logs drop constraint if exists daily_logs_cervical_mucus_check;
alter table public.daily_logs add constraint daily_logs_cervical_mucus_check check (cervical_mucus in ('none', 'dry', 'sticky', 'creamy', 'watery', 'eggwhite'));
alter table public.daily_logs add column if not exists bbt numeric(4,2);
alter table public.daily_logs drop constraint if exists daily_logs_bbt_check;
alter table public.daily_logs add constraint daily_logs_bbt_check check (bbt is null or bbt between 34 and 40);
-- Dolor de ovulación (molestia en un lado del vientre a mitad del ciclo): señal débil, solo se usa si no hay otra.
alter table public.daily_logs add column if not exists ovulation_pain boolean not null default false;

-- Módulo Emprende (fase 1): banco de ideas, votos, proyectos y presupuesto de arranque
create table if not exists public.ideas (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 120),
  description text not null default '',
  status text not null default 'activa' check (status in ('activa', 'descartada', 'proyecto')),
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.idea_votes (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid not null references public.ideas(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade default auth.uid(),
  interest smallint not null check (interest between 1 and 5),
  investment smallint not null check (investment between 1 and 5),
  time_needed smallint not null check (time_needed between 1 and 5),
  risk smallint not null check (risk between 1 and 5),
  updated_at timestamptz not null default now(),
  unique (idea_id, user_id)
);

create table if not exists public.ventures (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid references public.ideas(id) on delete set null,
  plan_id uuid references public.plans(id) on delete set null,
  name text not null check (char_length(name) between 1 and 120),
  pitch text not null default '',
  audience text not null default '',
  value_prop text not null default '',
  roles text not null default '',
  stage text not null default 'validar' check (stage in ('validar', 'lanzar', 'primer_cliente', 'ganancias')),
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.venture_budget_items (
  id uuid primary key default gen_random_uuid(),
  venture_id uuid not null references public.ventures(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  category text not null default 'otro' check (category in ('equipo', 'permisos', 'marketing', 'insumos', 'otro')),
  amount numeric(12,2) not null check (amount >= 0),
  funded_by text not null default 'ambos' check (funded_by in ('ambos', 'luis', 'isabel')),
  paid boolean not null default false,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

-- Módulo Emprende (fase 2): tablero de tareas por proyecto
create table if not exists public.venture_tasks (
  id uuid primary key default gen_random_uuid(),
  venture_id uuid not null references public.ventures(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  notes text not null default '',
  status text not null default 'pendiente' check (status in ('pendiente', 'en_proceso', 'hecha')),
  assignee text not null default 'ambos' check (assignee in ('ambos', 'luis', 'isabel')),
  due_date date,
  completed_at timestamptz,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

-- Fase 3: sincronización de tareas con Google Calendar (cada evento vive en el calendario de quien lo sincronizó)
alter table public.venture_tasks add column if not exists google_event_id text;
alter table public.venture_tasks add column if not exists google_synced_by uuid references auth.users(id) on delete set null;

-- Módulo Emprende (fase 3): finanzas del negocio y revisión semanal
create table if not exists public.venture_transactions (
  id uuid primary key default gen_random_uuid(),
  venture_id uuid not null references public.ventures(id) on delete cascade,
  kind text not null check (kind in ('ingreso', 'gasto')),
  concept text not null check (char_length(concept) between 1 and 120),
  amount numeric(12,2) not null check (amount > 0),
  date date not null default current_date,
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.venture_reviews (
  id uuid primary key default gen_random_uuid(),
  venture_id uuid not null references public.ventures(id) on delete cascade,
  week_start date not null,
  achieved text not null default '',
  blockers text not null default '',
  priority text not null default '',
  created_by uuid not null references auth.users(id) default auth.uid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (venture_id, week_start)
);

alter table public.plans enable row level security;
alter table public.contributions enable row level security;
alter table public.activities enable row level security;
alter table public.user_preferences enable row level security;
alter table public.cycles enable row level security;
alter table public.daily_logs enable row level security;
alter table public.ideas enable row level security;
alter table public.idea_votes enable row level security;
alter table public.ventures enable row level security;
alter table public.venture_budget_items enable row level security;
alter table public.venture_tasks enable row level security;
alter table public.venture_transactions enable row level security;
alter table public.venture_reviews enable row level security;

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

drop policy if exists "users can read own preferences" on public.user_preferences;
create policy "users can read own preferences" on public.user_preferences for select to authenticated using (user_id = auth.uid());
drop policy if exists "users can create own preferences" on public.user_preferences;
create policy "users can create own preferences" on public.user_preferences for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "users can update own preferences" on public.user_preferences;
create policy "users can update own preferences" on public.user_preferences for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "users can read own cycles" on public.cycles;
drop policy if exists "users can read shared cycles" on public.cycles;
create policy "users can read shared cycles" on public.cycles for select to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can create own cycles" on public.cycles;
drop policy if exists "users can create shared cycles" on public.cycles;
create policy "users can create shared cycles" on public.cycles for insert to authenticated with check (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid) and user_id in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can update own cycles" on public.cycles;
drop policy if exists "users can update shared cycles" on public.cycles;
create policy "users can update shared cycles" on public.cycles for update to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid)) with check (user_id in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can delete shared cycles" on public.cycles;
create policy "users can delete shared cycles" on public.cycles for delete to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));

drop policy if exists "users can read own daily logs" on public.daily_logs;
drop policy if exists "users can read shared daily logs" on public.daily_logs;
create policy "users can read shared daily logs" on public.daily_logs for select to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can create own daily logs" on public.daily_logs;
drop policy if exists "users can create shared daily logs" on public.daily_logs;
create policy "users can create shared daily logs" on public.daily_logs for insert to authenticated with check (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid) and user_id in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can update own daily logs" on public.daily_logs;
drop policy if exists "users can update shared daily logs" on public.daily_logs;
create policy "users can update shared daily logs" on public.daily_logs for update to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid)) with check (user_id in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));
drop policy if exists "users can delete own daily logs" on public.daily_logs;
drop policy if exists "users can delete shared daily logs" on public.daily_logs;
create policy "users can delete shared daily logs" on public.daily_logs for delete to authenticated using (auth.uid() in ('6388329a-d2dd-497e-b10d-37707c18463b'::uuid, '7bb8cd1b-65f1-4bed-b38e-38d3e07f4930'::uuid));

drop policy if exists "authenticated users can read ideas" on public.ideas;
create policy "authenticated users can read ideas" on public.ideas for select to authenticated using (true);
drop policy if exists "authenticated users can create ideas" on public.ideas;
create policy "authenticated users can create ideas" on public.ideas for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "authenticated users can update ideas" on public.ideas;
create policy "authenticated users can update ideas" on public.ideas for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete ideas" on public.ideas;
create policy "authenticated users can delete ideas" on public.ideas for delete to authenticated using (true);

drop policy if exists "authenticated users can read idea votes" on public.idea_votes;
create policy "authenticated users can read idea votes" on public.idea_votes for select to authenticated using (true);
drop policy if exists "users can create own idea votes" on public.idea_votes;
create policy "users can create own idea votes" on public.idea_votes for insert to authenticated with check (user_id = auth.uid());
drop policy if exists "users can update own idea votes" on public.idea_votes;
create policy "users can update own idea votes" on public.idea_votes for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "users can delete own idea votes" on public.idea_votes;
create policy "users can delete own idea votes" on public.idea_votes for delete to authenticated using (user_id = auth.uid());

drop policy if exists "authenticated users can read ventures" on public.ventures;
create policy "authenticated users can read ventures" on public.ventures for select to authenticated using (true);
drop policy if exists "authenticated users can create ventures" on public.ventures;
create policy "authenticated users can create ventures" on public.ventures for insert to authenticated with check (created_by = auth.uid());
drop policy if exists "authenticated users can update ventures" on public.ventures;
create policy "authenticated users can update ventures" on public.ventures for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete ventures" on public.ventures;
create policy "authenticated users can delete ventures" on public.ventures for delete to authenticated using (true);

drop policy if exists "authenticated users can read venture budget items" on public.venture_budget_items;
create policy "authenticated users can read venture budget items" on public.venture_budget_items for select to authenticated using (true);
drop policy if exists "authenticated users can create venture budget items" on public.venture_budget_items;
create policy "authenticated users can create venture budget items" on public.venture_budget_items for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.ventures where id = venture_id));
drop policy if exists "authenticated users can update venture budget items" on public.venture_budget_items;
create policy "authenticated users can update venture budget items" on public.venture_budget_items for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete venture budget items" on public.venture_budget_items;
create policy "authenticated users can delete venture budget items" on public.venture_budget_items for delete to authenticated using (true);

drop policy if exists "authenticated users can read venture tasks" on public.venture_tasks;
create policy "authenticated users can read venture tasks" on public.venture_tasks for select to authenticated using (true);
drop policy if exists "authenticated users can create venture tasks" on public.venture_tasks;
create policy "authenticated users can create venture tasks" on public.venture_tasks for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.ventures where id = venture_id));
drop policy if exists "authenticated users can update venture tasks" on public.venture_tasks;
create policy "authenticated users can update venture tasks" on public.venture_tasks for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete venture tasks" on public.venture_tasks;
create policy "authenticated users can delete venture tasks" on public.venture_tasks for delete to authenticated using (true);

drop policy if exists "authenticated users can read venture transactions" on public.venture_transactions;
create policy "authenticated users can read venture transactions" on public.venture_transactions for select to authenticated using (true);
drop policy if exists "authenticated users can create venture transactions" on public.venture_transactions;
create policy "authenticated users can create venture transactions" on public.venture_transactions for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.ventures where id = venture_id));
drop policy if exists "authenticated users can update venture transactions" on public.venture_transactions;
create policy "authenticated users can update venture transactions" on public.venture_transactions for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete venture transactions" on public.venture_transactions;
create policy "authenticated users can delete venture transactions" on public.venture_transactions for delete to authenticated using (true);

drop policy if exists "authenticated users can read venture reviews" on public.venture_reviews;
create policy "authenticated users can read venture reviews" on public.venture_reviews for select to authenticated using (true);
drop policy if exists "authenticated users can create venture reviews" on public.venture_reviews;
create policy "authenticated users can create venture reviews" on public.venture_reviews for insert to authenticated with check (created_by = auth.uid() and exists (select 1 from public.ventures where id = venture_id));
drop policy if exists "authenticated users can update venture reviews" on public.venture_reviews;
create policy "authenticated users can update venture reviews" on public.venture_reviews for update to authenticated using (true) with check (true);
drop policy if exists "authenticated users can delete venture reviews" on public.venture_reviews;
create policy "authenticated users can delete venture reviews" on public.venture_reviews for delete to authenticated using (true);

alter table public.plans replica identity full;
alter table public.contributions replica identity full;
alter table public.activities replica identity full;
alter table public.user_preferences replica identity full;
alter table public.cycles replica identity full;
alter table public.daily_logs replica identity full;
alter table public.ideas replica identity full;
alter table public.idea_votes replica identity full;
alter table public.ventures replica identity full;
alter table public.venture_budget_items replica identity full;
alter table public.venture_tasks replica identity full;
alter table public.venture_transactions replica identity full;
alter table public.venture_reviews replica identity full;

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

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'user_preferences'
  ) then alter publication supabase_realtime add table public.user_preferences; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'cycles'
  ) then alter publication supabase_realtime add table public.cycles; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'daily_logs'
  ) then alter publication supabase_realtime add table public.daily_logs; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'ideas'
  ) then alter publication supabase_realtime add table public.ideas; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'idea_votes'
  ) then alter publication supabase_realtime add table public.idea_votes; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'ventures'
  ) then alter publication supabase_realtime add table public.ventures; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'venture_budget_items'
  ) then alter publication supabase_realtime add table public.venture_budget_items; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'venture_tasks'
  ) then alter publication supabase_realtime add table public.venture_tasks; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'venture_transactions'
  ) then alter publication supabase_realtime add table public.venture_transactions; end if;

  if not exists (
    select 1 from pg_publication_rel pr join pg_class c on c.oid = pr.prrelid join pg_namespace n on n.oid = c.relnamespace join pg_publication p on p.oid = pr.prpubid
    where p.pubname = 'supabase_realtime' and n.nspname = 'public' and c.relname = 'venture_reviews'
  ) then alter publication supabase_realtime add table public.venture_reviews; end if;
end
$$;
