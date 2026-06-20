-- ============================================================
-- PAINEL DE TRANSPARÊNCIA — NOVO AEROPORTO REGIONAL DE SANTA MARIA
-- Setup do banco no Supabase (rode no SQL Editor do projeto)
-- ============================================================
-- Modelo de segurança:
--   * Leitura: PÚBLICA (qualquer visitante, via chave anon) — só-leitura
--   * Escrita: APENAS usuários autenticados (login no Supabase Auth)
--   * A senha NUNCA fica no código do site — fica no Supabase Auth
-- ============================================================

-- 1) Tabela de linha única que guarda todo o estado do painel
create table if not exists public.painel_aeroporto (
  id            integer primary key default 1,
  dados         jsonb not null,
  atualizado_em timestamptz not null default now(),
  constraint linha_unica check (id = 1)
);

-- 2) Habilita Row Level Security
alter table public.painel_aeroporto enable row level security;

-- 3) Políticas
--    Leitura liberada para todos (inclusive visitantes não logados)
drop policy if exists "leitura_publica" on public.painel_aeroporto;
create policy "leitura_publica"
  on public.painel_aeroporto
  for select
  using (true);

--    Atualização somente para usuários autenticados (admin logado)
drop policy if exists "escrita_autenticada" on public.painel_aeroporto;
create policy "escrita_autenticada"
  on public.painel_aeroporto
  for update
  to authenticated
  using (true)
  with check (true);

-- 4) Mantém atualizado_em sempre correto no update
create or replace function public.set_atualizado_em()
returns trigger as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_atualizado_em on public.painel_aeroporto;
create trigger trg_atualizado_em
  before update on public.painel_aeroporto
  for each row execute function public.set_atualizado_em();

-- 5) Habilita Realtime (para o site público atualizar ao vivo)
alter publication supabase_realtime add table public.painel_aeroporto;

-- 6) Seed inicial — estado atual do projeto (junho/2026)
insert into public.painel_aeroporto (id, dados)
values (1, '{
  "atualizadoEm": "2026-06-19",
  "proximoMarco": "M1",
  "fases": [
    {"id":"f1","num":"1","nome":"Estudo e priorização de áreas","periodo":"nov/2025 – set/2026","resp":"ITA e SAC","peso":8,"status":"em_andamento","progresso":40,"paralela":false,"desc":"Estudo técnico de áreas e priorização pelo ITA/SAC."},
    {"id":"f2","num":"2","nome":"Escolha da área pelo Município","periodo":"out/2026 – dez/2026","resp":"Município","peso":4,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Avaliação e escolha definitiva do sítio aeroportuário."},
    {"id":"f3","num":"3","nome":"Viabilidade técnica e ambiental","periodo":"mar/2027 – out/2027","resp":"SAC","peso":10,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Levantamento, diretrizes, cenários e estudo preliminar."},
    {"id":"f4","num":"4","nome":"Declaração de utilidade pública","periodo":"nov/2027 – dez/2027","resp":"Município","peso":3,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Decreto de utilidade pública das áreas necessárias."},
    {"id":"f5","num":"5","nome":"Convênio de Delegação SAC","periodo":"jan/2028 – mar/2028","resp":"SAC e Município","peso":5,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Celebração do convênio de delegação SAC/Município."},
    {"id":"f6","num":"6","nome":"Desapropriação das áreas","periodo":"jan/2028 – dez/2028","resp":"Município","peso":10,"status":"a_iniciar","progresso":0,"paralela":true,"desc":"Desapropriação das áreas — corre em paralelo às demais etapas."},
    {"id":"f7","num":"7","nome":"Licença Prévia Ambiental","periodo":"jun/2027 – mai/2029","resp":"SAC e Município","peso":15,"status":"a_iniciar","progresso":0,"paralela":true,"desc":"Licenciamento ambiental — em paralelo do início até o fim da obra."},
    {"id":"f8","num":"8","nome":"Projeto Básico","periodo":"abr/2028 – jul/2029","resp":"SAC","peso":15,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Elaboração do Projeto Básico de engenharia."},
    {"id":"f9","num":"9","nome":"Execução da obra","periodo":"ago/2029 – jan/2032","resp":"SAC e Município","peso":30,"status":"a_iniciar","progresso":0,"paralela":false,"desc":"Execução da obra do novo aeroporto."}
  ],
  "marcos": [
    {"cod":"M1","nome":"Apresentação à AMCentro das tratativas e próximos passos","data":"jul/2026","resp":"Município"},
    {"cod":"M2","nome":"Recepção do estudo de áreas para o novo sítio aeroportuário","data":"out/2026","resp":"Município"},
    {"cod":"M3","nome":"Visita ao Ministro de Portos e Aeroportos e apresentação da área","data":"dez/2026","resp":"SAC e Município"},
    {"cod":"M4","nome":"Celebração do Convênio de delegação SAC/Município","data":"mar/2028","resp":"SAC e Município"}
  ]
}'::jsonb)
on conflict (id) do nothing;
