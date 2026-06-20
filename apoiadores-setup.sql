-- ============================================================
-- INSTITUIÇÕES APOIADORAS — NOVO AEROPORTO REGIONAL DE SANTA MARIA
-- Logomarcas exibidas no site em ticker (rode no SQL Editor do Supabase)
-- ============================================================
-- Modelo de segurança:
--   * Leitura: PÚBLICA (qualquer visitante vê as logos)
--   * Cadastro / exclusão: APENAS admin autenticado
-- ============================================================

-- 1) Tabela das instituições apoiadoras
create table if not exists public.apoiadores (
  id         bigint generated always as identity primary key,
  nome       text not null,
  logo_url   text not null,
  site_url   text,
  ordem      integer not null default 0,
  criado_em  timestamptz not null default now(),
  constraint nome_tam check (char_length(trim(nome)) between 1 and 120)
);

create index if not exists idx_apoiadores_ordem on public.apoiadores (ordem, criado_em);

-- 2) Habilita Row Level Security
alter table public.apoiadores enable row level security;

-- 3) Políticas
--    Leitura pública
drop policy if exists "apoiadores_leitura_publica" on public.apoiadores;
create policy "apoiadores_leitura_publica"
  on public.apoiadores for select using (true);

--    Admin: cadastrar
drop policy if exists "apoiadores_admin_insert" on public.apoiadores;
create policy "apoiadores_admin_insert"
  on public.apoiadores for insert to authenticated with check (true);

--    Admin: editar / reordenar
drop policy if exists "apoiadores_admin_update" on public.apoiadores;
create policy "apoiadores_admin_update"
  on public.apoiadores for update to authenticated using (true) with check (true);

--    Admin: excluir
drop policy if exists "apoiadores_admin_delete" on public.apoiadores;
create policy "apoiadores_admin_delete"
  on public.apoiadores for delete to authenticated using (true);

-- 4) Realtime — o ticker atualiza ao vivo quando o admin cadastra/remove uma logo
alter publication supabase_realtime add table public.apoiadores;
