-- Rode no Supabase: SQL Editor > New query > Run
create table public.admins (email text primary key);
insert into public.admins values ('voce@seuemail.com');  -- TROQUE pelo seu e-mail de login

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  unit text default '',
  min_qty integer not null default 0 check (min_qty >= 0),
  active boolean not null default true,
  created_at timestamptz default now()
);
create table public.moves (
  id uuid primary key default gen_random_uuid(),
  pid uuid not null references public.products(id),
  type text not null check (type in ('in','out')),
  qty integer not null check (qty > 0),
  by_name text not null,
  uid uuid default auth.uid(),
  at bigint not null,
  note text default ''
);
create index on public.moves (pid);
create index on public.moves (at desc);

alter table public.admins   enable row level security;
alter table public.products enable row level security;
alter table public.moves    enable row level security;

create function public.is_admin() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email')) $$;

create policy admins_self  on public.admins   for select to authenticated using (lower(email) = lower(auth.jwt() ->> 'email'));
create policy prod_read    on public.products for select to authenticated using (true);
create policy prod_insert  on public.products for insert to authenticated with check (public.is_admin());
create policy prod_update  on public.products for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy moves_read   on public.moves    for select to authenticated using (true);
create policy moves_insert on public.moves    for insert to authenticated with check (uid = auth.uid());
-- sem policy de update/delete em moves: o histórico não pode ser alterado nem apagado

alter publication supabase_realtime add table public.products, public.moves;
