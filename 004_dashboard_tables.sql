-- Penn Access and Mobility
-- 004_dashboard_tables.sql
-- Adds the two tables the dashboard reads but 001_schema.sql did not create.
-- Without these you get 404s in the browser console and empty dashboard panels.
-- Run AFTER 001. Safe to re-run.

-- Materials needed for a job. This is the start of procurement:
-- status moves needed -> to_order -> ordered -> received, or needed -> grabbed.
create table if not exists materials (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id) on delete cascade,
  bid_line_item_id uuid references bid_line_items(id) on delete set null,
  name text not null,
  qty numeric default 1,
  unit text default 'each',
  status text default 'needed',
  -- needed | to_order | ordered | received | grabbed
  vendor text,
  est_cost numeric default 0,
  actual_cost numeric default 0,
  expense_id uuid references expenses(id) on delete set null,
  ordered_date date,
  expected_date date,
  received_date date,
  needed_by date,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_materials_job on materials(job_id);
create index if not exists idx_materials_status on materials(status);

-- Scheduled visits and milestones for a job.
create table if not exists schedule_events (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id) on delete cascade,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  title text,
  event_date date,
  event_time text,
  event_type text default 'work',
  -- work | measure | delivery | inspection | followup
  crew_id uuid references crew(id) on delete set null,
  crew_name text,
  notes text,
  created_at timestamptz default now()
);

create index if not exists idx_sched_job on schedule_events(job_id);
create index if not exists idx_sched_date on schedule_events(event_date);

alter table materials enable row level security;
drop policy if exists p_materials on materials;
create policy p_materials on materials for all to authenticated using (true) with check (true);

alter table schedule_events enable row level security;
drop policy if exists p_schedule_events on schedule_events;
create policy p_schedule_events on schedule_events for all to authenticated using (true) with check (true);
