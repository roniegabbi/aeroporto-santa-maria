-- ============================================================
-- MURAL DE APOIO — NOVO AEROPORTO REGIONAL DE SANTA MARIA
-- Setup do feed de mensagens de apoio (rode no SQL Editor do Supabase)
-- ============================================================
-- Modelo de segurança:
--   * Visitante (anon): pode ENVIAR mensagem, mas ela entra como NÃO aprovada
--   * Leitura pública: somente mensagens APROVADAS aparecem no site
--   * Moderação (aprovar / excluir): apenas admin autenticado (login Supabase)
-- ============================================================

-- 1) Tabela das mensagens de apoio
create table if not exists public.mensagens_apoio (
  id         bigint generated always as identity primary key,
  nome       text not null,
  cidade     text,
  mensagem   text not null,
  aprovado   boolean not null default false,
  criado_em  timestamptz not null default now(),
  constraint nome_tam   check (char_length(trim(nome)) between 1 and 80),
  constraint cidade_tam check (cidade is null or char_length(cidade) <= 80),
  constraint msg_tam    check (char_length(trim(mensagem)) between 1 and 500)
);

create index if not exists idx_apoio_aprovado_data
  on public.mensagens_apoio (aprovado, criado_em desc);

-- 2) Habilita Row Level Security
alter table public.mensagens_apoio enable row level security;

-- 3) Políticas
--    a) Leitura pública: só o que já foi aprovado
drop policy if exists "apoio_leitura_aprovados" on public.mensagens_apoio;
create policy "apoio_leitura_aprovados"
  on public.mensagens_apoio
  for select
  using (aprovado = true);

--    b) Envio público: qualquer visitante pode inserir, mas SEMPRE como não aprovado
drop policy if exists "apoio_envio_publico" on public.mensagens_apoio;
create policy "apoio_envio_publico"
  on public.mensagens_apoio
  for insert
  to anon, authenticated
  with check (aprovado = false);

--    c) Admin (autenticado): enxerga TODAS as mensagens (inclusive pendentes)
drop policy if exists "apoio_admin_select" on public.mensagens_apoio;
create policy "apoio_admin_select"
  on public.mensagens_apoio
  for select
  to authenticated
  using (true);

--    d) Admin: aprovar / editar
drop policy if exists "apoio_admin_update" on public.mensagens_apoio;
create policy "apoio_admin_update"
  on public.mensagens_apoio
  for update
  to authenticated
  using (true)
  with check (true);

--    e) Admin: excluir
drop policy if exists "apoio_admin_delete" on public.mensagens_apoio;
create policy "apoio_admin_delete"
  on public.mensagens_apoio
  for delete
  to authenticated
  using (true);

-- 4) Realtime — o mural atualiza ao vivo quando uma mensagem é aprovada
alter publication supabase_realtime add table public.mensagens_apoio;

-- 5) (Opcional) Mensagens de exemplo já aprovadas, para o mural não nascer vazio.
--    Comente este bloco se não quiser dados de exemplo.
insert into public.mensagens_apoio (nome, cidade, mensagem, aprovado) values
  ('Equipe do Projeto', 'Santa Maria', 'Que este mural se encha de vozes que acreditam no futuro da nossa região. Deixe aqui o seu apoio!', true)
on conflict do nothing;
