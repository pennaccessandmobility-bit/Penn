-- Penn Access and Mobility
-- 001_schema.sql
-- Complete schema. Run this FIRST on a fresh Supabase project.
-- Plain ASCII only. Safe to re-run.

create extension if not exists pgcrypto;

-- ============================================================
-- PEOPLE AND COMPANY
-- ============================================================

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  role text default 'office',            -- office | tech
  created_at timestamptz default now()
);

create table if not exists company_settings (
  key text primary key,
  value text,
  updated_at timestamptz default now()
);

create table if not exists crew (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text,
  phone text,
  role text default 'tech',
  worker_type text default 'unknown',    -- employee | subcontractor | unknown
  hourly_cost numeric default 0,         -- what they cost you
  bill_rate numeric default 0,           -- what you charge for their time
  active boolean default true,
  sort_order int default 0,
  notes text,
  created_at timestamptz default now()
);

create table if not exists customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text default 'residential',   -- residential | agency | commercial
  agency text,
  contact_name text,
  phone text,
  email text,
  address text,
  city text,
  state text default 'PA',
  zip text,
  notes text,
  active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists system_lists (
  id uuid primary key default gen_random_uuid(),
  list_name text not null,
  value text not null,
  sort_order int default 0,
  active boolean default true
);

-- ============================================================
-- ESTIMATING
-- ============================================================

create table if not exists price_list (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text default 'General',
  unit text default 'each',
  unit_cost numeric default 0,
  labor_hours numeric default 0,
  labor_rate numeric default 0,
  buy_link text,
  notes text,
  active boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

create table if not exists overhead_settings (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  overhead_type text default 'percent',  -- percent | flat | per_mile | per_trip
  amount numeric default 0,
  applies_to text default 'total',       -- total | labor | materials
  enabled boolean default true,
  sort_order int default 0
);

create table if not exists bids (
  id uuid primary key default gen_random_uuid(),
  submission_number text,
  title text,
  status text default 'Draft',           -- Draft | Sent | Won | Lost | Cancelled
  category text,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  customer_phone text,
  customer_address text,
  agency text,
  agency_address text,
  zoning_authority text,
  ic_name text,
  ic_phone text,
  ic_email text,
  project_manager text,
  bid_date date default current_date,
  expires_date date,
  follow_up_date date,
  won_date date,
  lost_date date,
  lost_reason text,
  lost_notes text,
  cancelled_date date,
  cancel_reason text,
  target_margin numeric default 35,
  estimated_margin numeric default 0,
  estimated_profit numeric default 0,
  subtotal_labor numeric default 0,
  subtotal_materials numeric default 0,
  subtotal_overhead numeric default 0,
  other_cost numeric default 0,
  total_cost numeric default 0,
  bid_price numeric default 0,
  miles_round_trip numeric default 0,
  trip_count int default 1,
  mileage numeric default 0,
  payment_terms text default 'Net 30',
  proposal_notes text,
  general_notes text,
  special_considerations text,
  job_id uuid,
  created_by text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_bids_status on bids(status);
create index if not exists idx_bids_customer on bids(customer_id);

create table if not exists bid_line_items (
  id uuid primary key default gen_random_uuid(),
  bid_id uuid references bids(id) on delete cascade,
  name text,
  category text,
  client_description text,
  area text,
  location_in_home text,
  measurement_notes text,
  unit text default 'each',
  quantity numeric default 1,
  price_mode text default 'catalog',
  price_value numeric default 0,
  catalog_hours_per_unit numeric default 0,
  book_hours numeric default 0,
  crew_assigned uuid,
  unit_material_cost numeric default 0,
  unit_labor_cost numeric default 0,
  total_material_cost numeric default 0,
  total_labor_cost numeric default 0,
  sub_materials numeric default 0,
  flat_subs numeric default 0,
  total_sub_cost numeric default 0,
  total_cost numeric default 0,
  buy_link text,
  photo_urls text,
  mockup_urls text,
  photo_source text,
  show_on_proposal boolean default true,
  sort_order int default 0,
  created_at timestamptz default now()
);

create index if not exists idx_bli_bid on bid_line_items(bid_id);

create table if not exists bid_intake_photos (
  id uuid primary key default gen_random_uuid(),
  bid_id uuid references bids(id) on delete cascade,
  photo_url text,
  caption text,
  created_at timestamptz default now()
);

create table if not exists bid_revisions (
  id uuid primary key default gen_random_uuid(),
  bid_id uuid references bids(id) on delete cascade,
  bid_price_at_time numeric default 0,
  line_items_snapshot jsonb,
  created_by text,
  created_at timestamptz default now()
);

create table if not exists bid_change_orders (
  id uuid primary key default gen_random_uuid(),
  bid_id uuid references bids(id) on delete cascade,
  description text,
  additional_cost numeric default 0,
  approved boolean default false,
  created_by text,
  created_at timestamptz default now()
);

create table if not exists agency_bid_rules (
  id uuid primary key default gen_random_uuid(),
  agency_name text not null,
  price_list_id uuid references price_list(id) on delete cascade,
  item_name text,
  created_at timestamptz default now()
);

-- ============================================================
-- JOBS: the lifecycle spine
-- Stage is a single forward-moving value.
-- Blockers are separate and can stack without changing the stage.
-- ============================================================

create table if not exists jobs (
  id uuid primary key default gen_random_uuid(),
  job_number text,
  title text,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  bid_id uuid references bids(id) on delete set null,
  agency text,
  category text,
  stage text default 'won',
  -- won | scheduled | in_progress | complete | invoiced | paid | cancelled
  blocked_by text[] default '{}',
  -- permit | materials | customer | subcontractor | weather | access
  proposal_status text,
  bid_amount numeric default 0,
  approval_date date,
  scheduled_date date,
  start_date date,
  complete_date date,
  scope_notes text,
  address text,
  status text default 'active',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_jobs_stage on jobs(stage);
create index if not exists idx_jobs_customer on jobs(customer_id);

create table if not exists job_stage_history (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id) on delete cascade,
  from_stage text,
  to_stage text,
  changed_by text,
  note text,
  created_at timestamptz default now()
);

create index if not exists idx_jsh_job on job_stage_history(job_id);

create table if not exists job_photos (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id) on delete cascade,
  photo_url text,
  phase text default 'before',           -- before | during | after
  caption text,
  created_at timestamptz default now()
);

create index if not exists idx_jp_job on job_photos(job_id);

-- ============================================================
-- TIME TRACKING
-- Rates snapshot onto the row at clock out so raising pay later
-- never rewrites past jobs or invoices.
-- ============================================================

create table if not exists work_types (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order int default 0,
  active boolean default true
);

create table if not exists crew_rates (
  id uuid primary key default gen_random_uuid(),
  crew_id uuid references crew(id) on delete cascade,
  work_type_id uuid references work_types(id) on delete cascade,
  customer_id uuid references customers(id) on delete cascade,
  cost_rate numeric,
  bill_rate numeric,
  created_at timestamptz default now()
);

create index if not exists idx_crew_rates_crew on crew_rates(crew_id);

create table if not exists time_entries (
  id uuid primary key default gen_random_uuid(),
  crew_id uuid references crew(id) on delete set null,
  crew_name text,
  job_id uuid references jobs(id) on delete set null,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  work_type_id uuid references work_types(id) on delete set null,
  work_type_name text,
  work_date date default current_date,
  clock_in timestamptz,
  clock_out timestamptz,
  hours numeric default 0,
  cost_rate numeric default 0,
  bill_rate numeric default 0,
  cost_total numeric default 0,
  bill_total numeric default 0,
  notes text,
  billed boolean default false,
  invoice_id uuid,
  created_at timestamptz default now()
);

create index if not exists idx_time_crew on time_entries(crew_id);
create index if not exists idx_time_date on time_entries(work_date);
create index if not exists idx_time_billed on time_entries(billed);

-- ============================================================
-- INVOICING
-- ============================================================

create table if not exists invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_no text,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  job_id uuid references jobs(id) on delete set null,
  job_title text,
  status text default 'draft',           -- draft | sent | paid | void
  issue_date date default current_date,
  due_date date,
  period_start date,
  period_end date,
  subtotal numeric default 0,
  tax_rate numeric default 0,
  tax_amount numeric default 0,
  total numeric default 0,
  amount_paid numeric default 0,
  notes text,
  terms text default 'Net 30',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_inv_customer on invoices(customer_id);
create index if not exists idx_inv_status on invoices(status);

create table if not exists invoice_lines (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id) on delete cascade,
  description text,
  qty numeric default 1,
  unit text default 'hour',
  rate numeric default 0,
  amount numeric default 0,
  source_type text,
  source_id uuid,
  sort_order int default 0
);

create index if not exists idx_invline_inv on invoice_lines(invoice_id);

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references invoices(id) on delete cascade,
  receipt_no text,
  amount numeric default 0,
  method text default 'check',
  reference text,
  paid_date date default current_date,
  notes text,
  created_at timestamptz default now()
);

create index if not exists idx_pay_invoice on payments(invoice_id);

-- ============================================================
-- PAYEES AND 1099
-- Full SSN / EIN is deliberately NOT stored. Last four only.
-- Keep signed W-9s in a locked file or with your accountant.
-- ============================================================

create table if not exists payees (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  business_name text,
  entity_type text default 'individual',
  is_1099_eligible boolean default true,
  w9_on_file boolean default false,
  w9_date date,
  tin_last4 text,
  address text,
  city text,
  state text default 'PA',
  zip text,
  phone text,
  email text,
  trade text,
  crew_id uuid references crew(id) on delete set null,
  active boolean default true,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- EXPENSES AND RECEIPTS
-- ============================================================

create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  vendor text,
  expense_date date default current_date,
  amount numeric default 0,
  tax_paid numeric default 0,
  category text default 'Materials',
  is_material boolean default true,
  job_id uuid references jobs(id) on delete set null,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  payee_id uuid references payees(id) on delete set null,
  payee_name text,
  counts_toward_1099 boolean default false,
  description text,
  payment_method text default 'card',
  reference text,
  receipt_photo_url text,
  hard_copy_location text,
  has_hard_copy boolean default false,
  billable boolean default false,
  billed boolean default false,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_exp_date on expenses(expense_date);
create index if not exists idx_exp_job on expenses(job_id);
create index if not exists idx_exp_payee on expenses(payee_id);

create table if not exists tax_settings (
  id int primary key default 1,
  federal_rate numeric default 15.3,
  state_rate numeric default 3.07,
  local_rate numeric default 1.0,
  set_aside_rate numeric default 25.0,
  filing_note text,
  updated_at timestamptz default now(),
  constraint one_row check (id = 1)
);

-- ============================================================
-- TOOLS AND EQUIPMENT
-- ============================================================

create table if not exists tools_equipment (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text default 'Hand tool',
  status text default 'owned',           -- owned | need | want | replaced
  make_model text,
  serial_no text,
  qty int default 1,
  condition text default 'good',
  location text,
  assigned_crew_id uuid references crew(id) on delete set null,
  assigned_crew_name text,
  purchase_date date,
  purchase_price numeric default 0,
  est_price numeric default 0,
  vendor text,
  buy_link text,
  replaced_by_id uuid references tools_equipment(id) on delete set null,
  replaced_date date,
  priority int default 2,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_tools_status on tools_equipment(status);

-- ============================================================
-- COMPLIANCE AND PERMITS
-- ============================================================

create table if not exists compliance_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  kind text default 'license',
  -- license | insurance | registration | certification | tax | other
  issuer text,
  identifier text,
  holder_crew_id uuid references crew(id) on delete set null,
  holder_name text,
  issue_date date,
  expiration_date date,
  renewal_period text default 'annual',
  cost numeric default 0,
  status text default 'active',
  notes text,
  last_renewed date,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_comp_exp on compliance_items(expiration_date);

create table if not exists permits (
  id uuid primary key default gen_random_uuid(),
  job_id uuid references jobs(id) on delete set null,
  bid_id uuid references bids(id) on delete set null,
  customer_id uuid references customers(id) on delete set null,
  customer_name text,
  job_label text,
  permit_type text default 'Building',
  municipality text,
  authority text,
  permit_number text,
  status text default 'needed',
  -- needed | applied | approved | rejected | inspection_scheduled | passed | closed
  applied_date date,
  approved_date date,
  expiration_date date,
  inspection_date date,
  inspection_notes text,
  cost numeric default 0,
  document_url text,
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_permits_status on permits(status);
create index if not exists idx_permits_job on permits(job_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- Any signed in user can read and write. Tighten later if you
-- want techs restricted to their own time entries.
-- ============================================================

do $$
declare t text;
begin
  foreach t in array array[
    'profiles','company_settings','crew','customers','system_lists',
    'price_list','overhead_settings','bids','bid_line_items','bid_intake_photos',
    'bid_revisions','bid_change_orders','agency_bid_rules',
    'jobs','job_stage_history','job_photos',
    'work_types','crew_rates','time_entries',
    'invoices','invoice_lines','payments',
    'payees','expenses','tax_settings',
    'tools_equipment','compliance_items','permits'
  ]
  loop
    execute format('alter table %I enable row level security', t);
    execute format('drop policy if exists p_all on %I', t);
    execute format('create policy p_all on %I for all to authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- ============================================================
-- New signups get a profile row automatically
-- ============================================================

create or replace function handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, new.email, 'office')
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
