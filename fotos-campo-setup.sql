-- ============================================================
-- GALERIA DE FOTOS DE CAMPO — NOVO AEROPORTO REGIONAL DE SANTA MARIA
-- Setup da tabela + bucket de Storage (rode no SQL Editor do Supabase)
-- ============================================================
-- Modelo de segurança:
--   * Leitura: PÚBLICA (qualquer visitante vê as fotos na moldura do site)
--   * Upload / edição / exclusão: APENAS admin autenticado (login no Supabase Auth)
--   * As imagens ficam no Storage (bucket público); a tabela guarda a
--     legenda, o caminho do arquivo, a URL pública e a ordem de exibição.
-- ============================================================

-- ------------------------------------------------------------
-- PARTE 1 — TABELA
-- ------------------------------------------------------------

-- 1) Tabela das fotos de campo
create table if not exists public.fotos_campo (
  id         bigint generated always as identity primary key,
  legenda    text,
  arquivo    text not null,                 -- caminho dentro do bucket (ex: 2026-06/visita-area.jpg)
  url        text not null,                 -- URL pública da imagem
  ordem      integer not null default 0,    -- ordem de exibição (menor aparece primeiro)
  criado_em  timestamptz not null default now(),
  constraint legenda_tam check (legenda is null or char_length(legenda) <= 200)
);

create index if not exists idx_fotos_campo_ordem
  on public.fotos_campo (ordem, criado_em desc);

-- 2) Habilita Row Level Security
alter table public.fotos_campo enable row level security;

-- 3) Políticas da tabela
--    a) Leitura pública (todos os visitantes veem as fotos)
drop policy if exists "fotos_leitura_publica" on public.fotos_campo;
create policy "fotos_leitura_publica"
  on public.fotos_campo for select using (true);

--    b) Admin: cadastrar
drop policy if exists "fotos_admin_insert" on public.fotos_campo;
create policy "fotos_admin_insert"
  on public.fotos_campo for insert to authenticated with check (true);

--    c) Admin: editar / reordenar / trocar legenda
drop policy if exists "fotos_admin_update" on public.fotos_campo;
create policy "fotos_admin_update"
  on public.fotos_campo for update to authenticated using (true) with check (true);

--    d) Admin: excluir
drop policy if exists "fotos_admin_delete" on public.fotos_campo;
create policy "fotos_admin_delete"
  on public.fotos_campo for delete to authenticated using (true);

-- 4) Realtime — a moldura do site atualiza ao vivo quando o admin sobe/remove uma foto
alter publication supabase_realtime add table public.fotos_campo;


-- ------------------------------------------------------------
-- PARTE 2 — STORAGE (onde os arquivos de imagem ficam guardados)
-- ------------------------------------------------------------

-- 5) Cria o bucket público "fotos-campo"
--    public = true permite que o site mostre as imagens sem login.
insert into storage.buckets (id, name, public)
values ('fotos-campo', 'fotos-campo', true)
on conflict (id) do update set public = true;

-- 6) Políticas do Storage (tabela storage.objects)
--    a) Leitura pública apenas deste bucket
drop policy if exists "fotos_storage_leitura_publica" on storage.objects;
create policy "fotos_storage_leitura_publica"
  on storage.objects for select
  using (bucket_id = 'fotos-campo');

--    b) Admin: enviar arquivo (upload) neste bucket
drop policy if exists "fotos_storage_admin_insert" on storage.objects;
create policy "fotos_storage_admin_insert"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'fotos-campo');

--    c) Admin: substituir arquivo
drop policy if exists "fotos_storage_admin_update" on storage.objects;
create policy "fotos_storage_admin_update"
  on storage.objects for update to authenticated
  using (bucket_id = 'fotos-campo') with check (bucket_id = 'fotos-campo');

--    d) Admin: excluir arquivo
drop policy if exists "fotos_storage_admin_delete" on storage.objects;
create policy "fotos_storage_admin_delete"
  on storage.objects for delete to authenticated
  using (bucket_id = 'fotos-campo');

-- ============================================================
-- Pronto. Próximo passo: criar o usuário admin em Authentication > Users
-- e colar a URL + anon key no index.html (veja o GUIA_SUPABASE.md).
-- ============================================================
