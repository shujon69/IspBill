-- ISP Bill Collection: Supabase database setup
-- Run this entire script in Supabase SQL Editor.
-- Then in Supabase Dashboard -> Authentication -> Providers -> Email,
-- disable "Confirm email" if you want admin/collector accounts to log in
-- immediately after they are created.

create extension if not exists pgcrypto;

create table if not exists public.companies (
  id uuid primary key,
  name text not null,
  address text default '',
  phone text default '',
  admin_name text default '',
  admin_email text not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_id uuid not null references public.companies(id) on delete cascade,
  role text not null check (role in ('admin','collector')),
  display_name text not null default '',
  username text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.company_data (
  company_id uuid primary key references public.companies(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists profiles_company_id_idx on public.profiles(company_id);
create index if not exists profiles_username_idx on public.profiles(username);

create or replace function public.is_company_member(p_company_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and company_id = p_company_id
  );
$$;

alter table public.companies enable row level security;
alter table public.profiles enable row level security;
alter table public.company_data enable row level security;

drop policy if exists "company members can read company" on public.companies;
create policy "company members can read company"
on public.companies for select
to authenticated
using (owner_id = auth.uid() or public.is_company_member(id));

drop policy if exists "owner can create company" on public.companies;
create policy "owner can create company"
on public.companies for insert
to authenticated
with check (owner_id = auth.uid());

drop policy if exists "company admins can update company" on public.companies;
create policy "company admins can update company"
on public.companies for update
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

drop policy if exists "members can read profiles" on public.profiles;
create policy "members can read profiles"
on public.profiles for select
to authenticated
using (id = auth.uid() or public.is_company_member(company_id));

drop policy if exists "users can create own profile" on public.profiles;
create policy "users can create own profile"
on public.profiles for insert
to authenticated
with check (id = auth.uid() or public.is_company_member(company_id));

drop policy if exists "members can update profiles" on public.profiles;
create policy "members can update profiles"
on public.profiles for update
to authenticated
using (id = auth.uid() or public.is_company_member(company_id))
with check (id = auth.uid() or public.is_company_member(company_id));

drop policy if exists "members can read company data" on public.company_data;
create policy "members can read company data"
on public.company_data for select
to authenticated
using (public.is_company_member(company_id));

drop policy if exists "members can insert company data" on public.company_data;
create policy "members can insert company data"
on public.company_data for insert
to authenticated
with check (public.is_company_member(company_id));

drop policy if exists "members can update company data" on public.company_data;
create policy "members can update company data"
on public.company_data for update
to authenticated
using (public.is_company_member(company_id))
with check (public.is_company_member(company_id));

-- Enable Realtime for instant Admin updates when a collector saves a payment.
-- If Supabase reports that company_data is already in this publication, you can ignore that message.
alter publication supabase_realtime add table public.company_data;
