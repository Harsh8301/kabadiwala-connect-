-- Kabadiwala Connect: core schema for cross-device sync (auth, profiles, lots,
-- offers, handovers, price board, dataset export audit).
--
-- Run this once against a new Supabase project (SQL Editor, or
-- `supabase db push` with the CLI). Structure: all types, then all tables,
-- then all functions, then all RLS policies, then triggers — deliberately in
-- that order so no statement ever forward-references an object that doesn't
-- exist yet (policies/functions are validated at creation time). Do not
-- hand-edit after it has been applied to a live project; add a new migration
-- file instead.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

create type public.user_role as enum (
  'collector',
  'aggregator',
  'recycler',
  'middleman',
  'admin'
);

-- Labels intentionally match Dart's `LotStatus` enum `.name` values (camelCase)
-- verbatim, so the app can read/write `status` with no translation layer.
create type public.lot_status as enum (
  'draft',
  'pendingSync',
  'lotCreated',
  'recyclerSelected',
  'pickupRequested',
  'handoverPending',
  'received',
  'paymentPending',
  'paid',
  'completed',
  'rejected',
  'disputed',
  'sorted',
  'processed',
  'recoveredDownstream'
);

create type public.payment_method as enum ('cash', 'upi');
create type public.payment_status as enum ('pending', 'paid');
create type public.offer_status as enum ('pending', 'accepted', 'rejected', 'expired', 'withdrawn');

-- ---------------------------------------------------------------------------
-- Tables (all created before any RLS policy, so cross-table policy
-- references below always resolve)
-- ---------------------------------------------------------------------------

-- Profiles: one row per auth.users identity, covers every role.
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null default 'collector',
  full_name text not null default '',
  phone text not null default '',
  language text not null default 'en',
  operating_location text not null default '',
  -- Recycler/middleman-specific (blank for collector/aggregator/admin)
  facility_name text not null default '',
  facility_location text not null default '',
  authorization_number text not null default '',
  materials_accepted text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is 'One row per authenticated user; role decides which app surface they see.';

-- Lots: the digital lot a seller creates; buyer is the assigned
-- recycler/middleman/aggregator once matched.
create table public.lots (
  id uuid primary key default gen_random_uuid(),
  lot_code text not null unique,
  seller_id uuid not null references public.profiles (id),
  buyer_id uuid references public.profiles (id),
  status public.lot_status not null default 'lotCreated',
  collection_lat double precision,
  collection_lng double precision,
  collection_label text not null default '',
  handover_lat double precision,
  handover_lng double precision,
  handover_label text not null default '',
  total_estimated_value numeric(12, 2) not null default 0,
  final_weight_kg numeric(10, 2),
  final_sale_value numeric(12, 2),
  payment_method public.payment_method,
  payment_status public.payment_status not null default 'pending',
  -- Two-sided handover: seller submits, buyer records measured weight and
  -- confirms; seller then accepts or disputes the final amount.
  seller_confirmed boolean not null default false,
  buyer_confirmed boolean not null default false,
  dispute_reason text,
  handover_reference text not null default '',
  image_url text,
  handover_image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index lots_seller_id_idx on public.lots (seller_id);
create index lots_buyer_id_idx on public.lots (buyer_id);
create index lots_status_idx on public.lots (status);

-- Lot materials: one row per material occurrence in a lot.
create table public.lot_materials (
  id uuid primary key default gen_random_uuid(),
  lot_id uuid not null references public.lots (id) on delete cascade,
  material_id text not null,
  category text not null default '',
  subcategory text not null default '',
  description text not null default '',
  quantity integer not null default 1,
  weight_kg numeric(10, 2) not null,
  condition text not null default '',
  source_type text not null default '',
  estimated_value numeric(12, 2) not null default 0,
  quoted_rate numeric(12, 2),
  image_url text
);

create index lot_materials_lot_id_idx on public.lot_materials (lot_id);

-- Offers: a buyer's real, addressable offer on a lot.
create table public.offers (
  id uuid primary key default gen_random_uuid(),
  lot_id uuid not null references public.lots (id) on delete cascade,
  buyer_id uuid not null references public.profiles (id),
  rate numeric(12, 2) not null,
  unit text not null default 'kg',
  valid_until timestamptz not null,
  pickup_terms text not null default '',
  status public.offer_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index offers_lot_id_idx on public.offers (lot_id);
create index offers_buyer_id_idx on public.offers (buyer_id);

-- Lot status history: append-only audit trail per lot.
create table public.lot_status_history (
  id uuid primary key default gen_random_uuid(),
  lot_id uuid not null references public.lots (id) on delete cascade,
  status public.lot_status not null,
  note text not null default '',
  actor_id uuid references public.profiles (id),
  at timestamptz not null default now()
);

create index lot_status_history_lot_id_idx on public.lot_status_history (lot_id);

-- Price board: shared reference data; any authenticated user can read, only
-- the owning recycler/middleman or an admin can write.
create table public.price_board (
  id uuid primary key default gen_random_uuid(),
  material_id text not null,
  location text not null,
  buying_price numeric(12, 2) not null,
  quoted_price numeric(12, 2) not null,
  market_min numeric(12, 2) not null,
  market_max numeric(12, 2) not null,
  unit text not null default 'kg',
  recycler_id uuid references public.profiles (id),
  updated_at timestamptz not null default now()
);

create index price_board_material_id_idx on public.price_board (material_id);

create table public.price_history (
  id uuid primary key default gen_random_uuid(),
  price_id uuid not null references public.price_board (id) on delete cascade,
  at timestamptz not null,
  value numeric(12, 2) not null
);

create index price_history_price_id_idx on public.price_history (price_id);

-- Dataset export audit log: who exported what, and how many rows. This is
-- what makes the dataset export "access-controlled" rather than a bare log
-- statement: every export is a row here, scoped by the exporting user's own
-- RLS-visible data unless they are admin.
create table public.dataset_export_log (
  id uuid primary key default gen_random_uuid(),
  requested_by uuid not null references public.profiles (id),
  requested_role public.user_role not null,
  dataset_keys text[] not null,
  row_counts jsonb not null,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Functions (created after the tables they query)
-- ---------------------------------------------------------------------------

-- SECURITY DEFINER so RLS policies that call these don't recurse into the
-- RLS-protected profiles table with the caller's own (possibly zero) access.
create function public.current_role()
returns public.user_role
language sql
security definer
set search_path = public
stable
as $$
  select role from public.profiles where id = auth.uid();
$$;

create function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((select role from public.profiles where id = auth.uid()) = 'admin', false);
$$;

-- Auto-create the profile row server-side on signup. This runs as a
-- SECURITY DEFINER trigger (not a client request), so it works even when
-- email confirmation is required and the client has no session yet — the
-- app passes role/phone/language as auth signUp() metadata, which lands in
-- raw_user_meta_data here.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, phone, language)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'collector'),
    coalesce(new.raw_user_meta_data ->> 'phone', ''),
    coalesce(new.raw_user_meta_data ->> 'language', 'en')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger lots_set_updated_at before update on public.lots
  for each row execute function public.set_updated_at();

create trigger offers_set_updated_at before update on public.offers
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- Row level security (every table; all referenced tables/functions above
-- already exist by this point)
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;

create policy "profiles_select_own_or_admin"
  on public.profiles for select
  using (id = auth.uid() or public.is_admin());

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (id = auth.uid());

create policy "profiles_update_own_or_admin"
  on public.profiles for update
  using (id = auth.uid() or public.is_admin());

alter table public.lots enable row level security;

create policy "lots_select_participant_or_admin"
  on public.lots for select
  using (
    seller_id = auth.uid()
    or buyer_id = auth.uid()
    or public.is_admin()
    or exists (select 1 from public.offers o where o.lot_id = lots.id and o.buyer_id = auth.uid())
  );

create policy "lots_insert_as_seller"
  on public.lots for insert
  with check (seller_id = auth.uid());

create policy "lots_update_participant_or_admin"
  on public.lots for update
  using (seller_id = auth.uid() or buyer_id = auth.uid() or public.is_admin());

alter table public.lot_materials enable row level security;

create policy "lot_materials_via_parent_lot"
  on public.lot_materials for all
  using (exists (
    select 1 from public.lots l
    where l.id = lot_materials.lot_id
      and (l.seller_id = auth.uid() or l.buyer_id = auth.uid() or public.is_admin())
  ))
  with check (exists (
    select 1 from public.lots l
    where l.id = lot_materials.lot_id
      and (l.seller_id = auth.uid() or l.buyer_id = auth.uid() or public.is_admin())
  ));

alter table public.offers enable row level security;

create policy "offers_select_participant_or_admin"
  on public.offers for select
  using (
    buyer_id = auth.uid()
    or public.is_admin()
    or exists (select 1 from public.lots l where l.id = offers.lot_id and l.seller_id = auth.uid())
  );

create policy "offers_insert_as_buyer"
  on public.offers for insert
  with check (
    buyer_id = auth.uid()
    and public.current_role() in ('recycler', 'middleman', 'aggregator')
  );

create policy "offers_update_participant_or_admin"
  on public.offers for update
  using (
    buyer_id = auth.uid()
    or public.is_admin()
    or exists (select 1 from public.lots l where l.id = offers.lot_id and l.seller_id = auth.uid())
  );

alter table public.lot_status_history enable row level security;

create policy "lot_status_history_via_parent_lot"
  on public.lot_status_history for select
  using (exists (
    select 1 from public.lots l
    where l.id = lot_status_history.lot_id
      and (l.seller_id = auth.uid() or l.buyer_id = auth.uid() or public.is_admin())
  ));

create policy "lot_status_history_insert_via_parent_lot"
  on public.lot_status_history for insert
  with check (exists (
    select 1 from public.lots l
    where l.id = lot_status_history.lot_id
      and (l.seller_id = auth.uid() or l.buyer_id = auth.uid() or public.is_admin())
  ));

alter table public.price_board enable row level security;

create policy "price_board_select_any_authenticated"
  on public.price_board for select
  using (auth.uid() is not null);

create policy "price_board_write_owner_or_admin"
  on public.price_board for all
  using (recycler_id = auth.uid() or public.is_admin())
  with check (recycler_id = auth.uid() or public.is_admin());

alter table public.price_history enable row level security;

create policy "price_history_select_any_authenticated"
  on public.price_history for select
  using (auth.uid() is not null);

create policy "price_history_write_via_price_board"
  on public.price_history for insert
  with check (exists (
    select 1 from public.price_board p
    where p.id = price_history.price_id
      and (p.recycler_id = auth.uid() or public.is_admin())
  ));

alter table public.dataset_export_log enable row level security;

create policy "dataset_export_log_select_own_or_admin"
  on public.dataset_export_log for select
  using (requested_by = auth.uid() or public.is_admin());

create policy "dataset_export_log_insert_own"
  on public.dataset_export_log for insert
  with check (requested_by = auth.uid());
