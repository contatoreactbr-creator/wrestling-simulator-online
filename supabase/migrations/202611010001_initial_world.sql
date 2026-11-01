-- Wrestling Simulator Online
-- Fase 2: esquema inicial do universo compartilhado (Supabase/PostgreSQL).
-- Aplique em um projeto Supabase novo. Não contém dados reais licenciados.

create extension if not exists pgcrypto;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Manager',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_display_name_length check (char_length(display_name) between 2 and 40)
);

create table public.promotions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  country text not null,
  style text not null,
  promotion_type text not null check (promotion_type in ('player_created','real_system')),
  owner_user_id uuid references auth.users(id) on delete restrict,
  budget numeric(14,2) not null default 1000000 check (budget >= 0),
  popularity integer not null default 5 check (popularity between 0 and 100),
  created_at timestamptz not null default now(),
  constraint promotions_name_length check (char_length(name) between 2 and 60),
  constraint promotions_owner_rule check (
    (promotion_type = 'player_created' and owner_user_id is not null)
    or (promotion_type = 'real_system' and owner_user_id is null)
  )
);

create unique index promotions_one_player_company_idx
  on public.promotions(owner_user_id)
  where promotion_type = 'player_created';

create table public.wrestlers (
  id uuid primary key default gen_random_uuid(),
  ring_name text not null,
  nationality text not null,
  age integer not null check (age between 18 and 65),
  identity_source text not null check (identity_source in ('fictional_generated','real_reference')),
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint wrestlers_ring_name_length check (char_length(ring_name) between 2 and 70)
);

-- Os nomes fictícios são únicos globalmente. IDs UUID são permanentes.
create unique index wrestlers_fictional_name_unique_idx
  on public.wrestlers (lower(ring_name))
  where identity_source = 'fictional_generated';

create table public.wrestler_contracts (
  id uuid primary key default gen_random_uuid(),
  wrestler_id uuid not null references public.wrestlers(id) on delete restrict,
  promotion_id uuid not null references public.promotions(id) on delete restrict,
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  weekly_salary numeric(12,2) not null default 0 check (weekly_salary >= 0),
  contract_status text not null default 'active'
    check (contract_status in ('active','released','expired')),
  created_at timestamptz not null default now(),
  constraint wrestler_contract_dates check (ended_at is null or ended_at >= started_at)
);

create unique index wrestler_one_active_contract_idx
  on public.wrestler_contracts(wrestler_id)
  where contract_status = 'active' and ended_at is null;

create index wrestler_contracts_promotion_idx
  on public.wrestler_contracts(promotion_id);

create table public.world_clock (
  singleton_id integer primary key default 1 check (singleton_id = 1),
  current_turn integer not null default 1 check (current_turn >= 1),
  clock_status text not null default 'setup'
    check (clock_status in ('setup','running','paused')),
  turn_started_at timestamptz,
  turn_closes_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint world_clock_dates check (
    turn_closes_at is null or turn_started_at is null or turn_closes_at > turn_started_at
  )
);

insert into public.world_clock(singleton_id, current_turn, clock_status)
values (1, 1, 'setup')
on conflict (singleton_id) do nothing;

create table public.turn_submissions (
  id uuid primary key default gen_random_uuid(),
  turn_number integer not null check (turn_number >= 1),
  user_id uuid not null references auth.users(id) on delete cascade,
  promotion_id uuid not null references public.promotions(id) on delete restrict,
  orders jsonb not null default '{}'::jsonb,
  submitted_at timestamptz not null default now(),
  unique (turn_number, user_id)
);

create index turn_submissions_promotion_turn_idx
  on public.turn_submissions(promotion_id, turn_number);

-- Cria o perfil automaticamente no cadastro pelo Supabase Auth.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles(id, display_name)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''), 'Manager')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Fundação da empresa e criação transacional de 12 talentos fictícios.
-- Se qualquer etapa falhar, toda a operação é revertida.
create or replace function public.found_player_promotion(
  p_name text,
  p_country text,
  p_style text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_promotion_id uuid;
  v_wrestler_id uuid;
  v_first text;
  v_last text;
  v_ring_name text;
  v_attempt integer;
  v_i integer;
  v_first_names text[] := array[
    'Alex','Bruno','Caio','Dante','Ethan','Felipe','Gabriel','Hugo','Ian','Javier',
    'Kai','Leon','Lucas','Marcos','Mateo','Nathan','Oliver','Pablo','Rafael','Ryan',
    'Samuel','Theo','Victor','Yuri','Adrian','Breno','Cesar','Diego','Enzo','Fabio'
  ];
  v_last_names text[] := array[
    'Almeida','Barros','Costa','Duarte','Esteves','Ferreira','Garcia','Henrique','Ito','Junqueira',
    'Keller','Lima','Mendes','Nogueira','Oliveira','Pereira','Queiroz','Ramos','Silva','Teixeira',
    'Ueda','Valente','Watanabe','Xavier','Yamamoto','Zanetti','Andrade','Bastos','Cardoso','Dias'
  ];
begin
  if v_user_id is null then
    raise exception 'É necessário entrar na sua conta para fundar uma promoção.';
  end if;

  if p_name is null or char_length(trim(p_name)) not between 2 and 60 then
    raise exception 'O nome da promoção deve ter entre 2 e 60 caracteres.';
  end if;
  if p_country is null or char_length(trim(p_country)) not between 2 and 60 then
    raise exception 'Informe um país válido.';
  end if;
  if p_style is null or char_length(trim(p_style)) not between 2 and 40 then
    raise exception 'Informe um estilo válido.';
  end if;

  insert into public.promotions(name, country, style, promotion_type, owner_user_id)
  values (trim(p_name), trim(p_country), trim(p_style), 'player_created', v_user_id)
  returning id into v_promotion_id;

  for v_i in 1..12 loop
    v_wrestler_id := null;
    v_attempt := 0;

    while v_wrestler_id is null loop
      v_attempt := v_attempt + 1;
      if v_attempt > 100 then
        raise exception 'Não foi possível gerar um nome fictício único. Tente novamente.';
      end if;

      v_first := v_first_names[1 + floor(random() * array_length(v_first_names, 1))::integer];
      v_last := v_last_names[1 + floor(random() * array_length(v_last_names, 1))::integer];
      v_ring_name := v_first || ' ' || v_last;

      begin
        insert into public.wrestlers(
          ring_name, nationality, age, identity_source, attributes
        )
        values (
          v_ring_name,
          trim(p_country),
          20 + floor(random() * 19)::integer,
          'fictional_generated',
          jsonb_build_object(
            'overall', 45 + floor(random() * 26)::integer,
            'strength', 40 + floor(random() * 51)::integer,
            'technique', 40 + floor(random() * 51)::integer,
            'charisma', 40 + floor(random() * 51)::integer,
            'stamina', 40 + floor(random() * 51)::integer,
            'role', case when v_i % 4 = 0 then 'tag_team' else 'singles' end
          )
        )
        returning id into v_wrestler_id;
      exception when unique_violation then
        v_wrestler_id := null;
      end;
    end loop;

    insert into public.wrestler_contracts(
      wrestler_id, promotion_id, weekly_salary, contract_status
    )
    values (v_wrestler_id, v_promotion_id, 500 + floor(random() * 1501)::numeric, 'active');
  end loop;

  return v_promotion_id;
end;
$$;

-- Permissões explícitas: sem escrita direta nas tabelas críticas pelo navegador.
alter table public.profiles enable row level security;
alter table public.promotions enable row level security;
alter table public.wrestlers enable row level security;
alter table public.wrestler_contracts enable row level security;
alter table public.world_clock enable row level security;
alter table public.turn_submissions enable row level security;

revoke all on public.profiles, public.promotions, public.wrestlers,
  public.wrestler_contracts, public.world_clock, public.turn_submissions
from anon, authenticated;

grant select, update on public.profiles to authenticated;
grant select on public.promotions, public.wrestlers, public.wrestler_contracts,
  public.world_clock to authenticated;
grant select, insert, update on public.turn_submissions to authenticated;

create policy profiles_select_own on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy profiles_update_own on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy promotions_read_authenticated on public.promotions
  for select to authenticated using (true);

create policy wrestlers_read_authenticated on public.wrestlers
  for select to authenticated using (true);

create policy contracts_read_authenticated on public.wrestler_contracts
  for select to authenticated using (true);

create policy world_clock_read_authenticated on public.world_clock
  for select to authenticated using (true);

create policy turn_submissions_read_own on public.turn_submissions
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy turn_submissions_insert_own_open_turn on public.turn_submissions
  for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.promotions p
      where p.id = promotion_id and p.owner_user_id = (select auth.uid())
        and p.promotion_type = 'player_created'
    )
    and exists (
      select 1 from public.world_clock w
      where w.singleton_id = 1 and w.clock_status = 'running'
        and w.current_turn = turn_number
        and w.turn_closes_at > now()
    )
  );

create policy turn_submissions_update_own_open_turn on public.turn_submissions
  for update to authenticated
  using (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.world_clock w
      where w.singleton_id = 1 and w.clock_status = 'running'
        and w.current_turn = turn_number
        and w.turn_closes_at > now()
    )
  )
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.promotions p
      where p.id = promotion_id and p.owner_user_id = (select auth.uid())
        and p.promotion_type = 'player_created'
    )
    and exists (
      select 1 from public.world_clock w
      where w.singleton_id = 1 and w.clock_status = 'running'
        and w.current_turn = turn_number
        and w.turn_closes_at > now()
    )
  );

revoke all on function public.found_player_promotion(text, text, text) from public, anon;
grant execute on function public.found_player_promotion(text, text, text) to authenticated;

-- O trigger de cadastro precisa executar como função interna do Supabase Auth.
revoke all on function public.handle_new_user() from public, anon, authenticated;
