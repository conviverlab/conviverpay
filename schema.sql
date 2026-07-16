-- ============================================================
-- Conviver Pay — schema do banco (Supabase / Postgres)
-- Rode este script inteiro no SQL Editor do seu projeto Supabase
-- (Project > SQL Editor > New query > colar > Run).
-- ============================================================

-- ---------- CONFIGURAÇÕES (apoio a Lançamentos/Pagadoria) ----------

create table if not exists coligadas (
  id         text primary key,
  num        text not null unique,
  razao      text not null,
  cnpj       text,
  pag_nome   text
);

create table if not exists empreendimentos (
  id           text primary key,
  nome         text not null unique,
  cidade       text,
  estado       text,
  cor          text,
  coligada_id  text references coligadas(id) on delete restrict,
  coligada     text,          -- número da coligada, denormalizado p/ exibição rápida
  ordem        int
);

create table if not exists responsaveis (
  id    text primary key,
  nome  text not null unique
);

-- ---------- LANÇAMENTOS ----------

create table if not exists lancamentos (
  id                    text primary key,
  titulo                text not null,
  empreendimento        text,

  -- identificadores usados para casar com a planilha da Pagadoria
  numero_oc             text not null,
  numero_atividade      text not null,

  -- dados do fornecedor (preenchidos manualmente ou via consulta de CNPJ)
  fornecedor            text,           -- razão social
  nome_fantasia         text,
  cnpj                  text,
  cnpj_norm             text,           -- só dígitos, pra busca/casamento
  endereco              text,           -- logradouro
  numero_endereco       text,
  bairro                text,
  forn_cidade           text,
  forn_estado           text,
  cep                   text,
  telefone              text,
  email                 text,

  -- dados bancários
  banco                 text,
  agencia               text,
  conta                 text,
  pix                   text,

  valor                 numeric(14,2),
  forma_pagamento       text,
  parcela_atual         int,
  total_parcelas        int,
  prioridade            text,
  responsavel           text,
  data_solicitacao      date,
  data_limite           date,

  status                text not null default 'rascunho',
  -- rascunho | aguardando_aprovacao | enviado_pagadoria | pagamento_programado | pago | cancelado

  requer_atencao        boolean not null default false,
  requer_atencao_motivo text,           -- ex: "Planilha trouxe STATUS MOVIMENTO = Bloqueado em 10/07/2026"

  observacoes           text,
  checklist              jsonb not null default '[]'::jsonb,

  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint lancamentos_oc_atividade_uniq unique (numero_oc, numero_atividade)
);

create index if not exists idx_lancamentos_status on lancamentos(status);
create index if not exists idx_lancamentos_oc_ativ on lancamentos(numero_oc, numero_atividade);

-- histórico/auditoria de mudanças automáticas (via importação da Pagadoria)
create table if not exists lancamentos_historico (
  id                  bigserial primary key,
  lancamento_id       text references lancamentos(id) on delete cascade,
  data                timestamptz not null default now(),
  usuario             text,             -- e-mail de quem importou a planilha
  de_status           text,
  para_status         text,
  tipo                text not null,    -- 'automatico_importacao' | 'manual'
  motivo              text,
  planilha_oc         text,
  planilha_atividade  text
);

create index if not exists idx_historico_lancamento on lancamentos_historico(lancamento_id);

-- ---------- PAGADORIA (espelho importado da planilha .xlsx) ----------

create table if not exists pagadoria (
  oc                 text not null,
  atividade          text not null,
  usuario            text,
  data               date,
  status_atendimento text,
  status_movimento   text,
  coligada           text,
  empreendimento     text,
  fornecedor         text,
  cnpj               text,
  historico          text,
  dados_pgto         text,
  responsavel        text,
  valor              numeric(14,2),
  updated_at         timestamptz not null default now(),
  primary key (oc, atividade)
);

-- ============================================================
-- RLS — qualquer usuário autenticado (login da equipe) tem acesso
-- total. Mesmo modelo de confiança do Conviver Events: não há
-- papéis distintos entre usuários dentro do time.
-- ============================================================

alter table coligadas             enable row level security;
alter table empreendimentos       enable row level security;
alter table responsaveis          enable row level security;
alter table lancamentos           enable row level security;
alter table lancamentos_historico enable row level security;
alter table pagadoria             enable row level security;

create policy "auth full access" on coligadas             for all to authenticated using (true) with check (true);
create policy "auth full access" on empreendimentos       for all to authenticated using (true) with check (true);
create policy "auth full access" on responsaveis          for all to authenticated using (true) with check (true);
create policy "auth full access" on lancamentos           for all to authenticated using (true) with check (true);
create policy "auth full access" on lancamentos_historico for all to authenticated using (true) with check (true);
create policy "auth full access" on pagadoria             for all to authenticated using (true) with check (true);
