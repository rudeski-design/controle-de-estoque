-- Rode no Supabase: SQL Editor > New query > Run (pode rodar várias vezes)
create table if not exists public.admins (email text primary key);
insert into public.admins values ('fernando@intconsultoria.ia.br')
  on conflict (email) do nothing;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  unit text default '',
  min_qty integer not null default 0 check (min_qty >= 0),
  active boolean not null default true,
  created_at timestamptz default now()
);

create table if not exists public.moves (
  id uuid primary key default gen_random_uuid(),
  pid uuid not null references public.products(id),
  type text not null check (type in ('in','out')),
  qty integer not null check (qty > 0),
  by_name text not null,
  uid uuid default auth.uid(),
  at bigint not null,
  note text default ''
);
