-- ============================================================
-- ABAIXO-ASSINADO — NOVO AEROPORTO REGIONAL DE SANTA MARIA
-- Setup do banco no Supabase (rode no SQL Editor)
-- ============================================================
-- Personas: 'agente_politico' | 'entidade' | 'cidadao'
-- Segurança / LGPD:
--   * Qualquer pessoa pode ASSINAR (insert público)
--   * A LEITURA da tabela (com CPF/CNPJ) é restrita a admins autenticados
--   * O público só vê contagem e os apoiadores públicos (agentes/entidades), sem CPF
-- ============================================================

create table if not exists public.assinaturas (
  id             uuid primary key default gen_random_uuid(),
  tipo           text not null check (tipo in ('agente_politico','entidade','cidadao')),
  entidade       text,          -- razão social (entidade) OU casa/órgão (agente político)
  cnpj           text,          -- só entidade
  cargo          text,          -- só agente político (ex.: Senador, Deputado Federal, Bancada)
  partido        text,          -- só agente político
  uf             text,          -- só agente político
  endereco       text,
  responsavel    text not null, -- presidente (entidade) / nome do agente / nome do cidadão
  cpf            text,          -- CPF (opcional para agente/bancada; recomendado p/ entidade e cidadão)
  cidade         text,
  email          text,
  assinatura_png text not null,
  hash           text,
  ip             text,
  user_agent     text,
  criado_em      timestamptz not null default now()
);

-- Colunas novas (caso a tabela já existisse de uma versão anterior)
alter table public.assinaturas add column if not exists cargo   text;
alter table public.assinaturas add column if not exists partido text;
alter table public.assinaturas add column if not exists uf      text;
alter table public.assinaturas alter column cpf drop not null;

-- Atualiza o CHECK do tipo para incluir agente_politico
do $$
begin
  if exists (select 1 from pg_constraint where conname = 'assinaturas_tipo_check') then
    alter table public.assinaturas drop constraint assinaturas_tipo_check;
  end if;
  alter table public.assinaturas
    add constraint assinaturas_tipo_check check (tipo in ('agente_politico','entidade','cidadao'));
end $$;

create index if not exists idx_assinaturas_criado on public.assinaturas (criado_em desc);
create index if not exists idx_assinaturas_tipo on public.assinaturas (tipo);

alter table public.assinaturas enable row level security;

drop policy if exists "assinar_publico" on public.assinaturas;
create policy "assinar_publico" on public.assinaturas
  for insert to anon, authenticated with check (true);

drop policy if exists "leitura_admin" on public.assinaturas;
create policy "leitura_admin" on public.assinaturas
  for select to authenticated using (true);

-- ============================================================
-- Funções PÚBLICAS sem dados sensíveis (LGPD)
-- ============================================================

create or replace function public.resumo_apoios()
returns json language sql security definer set search_path = public as $$
  select json_build_object(
    'total',     (select count(*) from public.assinaturas),
    'agentes',   (select count(*) from public.assinaturas where tipo = 'agente_politico'),
    'entidades', (select count(*) from public.assinaturas where tipo = 'entidade'),
    'cidadaos',  (select count(*) from public.assinaturas where tipo = 'cidadao')
  );
$$;

-- Mural público: agentes políticos e entidades (NUNCA cidadãos, NUNCA CPF)
create or replace function public.apoiadores_publicos()
returns table(tipo text, nome text, cargo text, partido text, uf text, cidade text, criado_em timestamptz)
language sql security definer set search_path = public as $$
  select tipo,
         case when tipo = 'entidade' then entidade else responsavel end as nome,
         cargo, partido, uf, cidade, criado_em
  from public.assinaturas
  where tipo in ('agente_politico','entidade')
  order by criado_em desc
  limit 800;
$$;

grant execute on function public.resumo_apoios() to anon, authenticated;
grant execute on function public.apoiadores_publicos() to anon, authenticated;
