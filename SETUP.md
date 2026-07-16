# Conviver Pay — Setup

## 1. Criar o projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e faça login com sua conta.
2. **New project** → escolha organização, dê um nome (ex: `conviver-pay`), defina uma senha forte do banco (guarde-a, mas não vai precisar dela no app) e escolha a região mais próxima (ex: São Paulo).
3. Aguarde o projeto terminar de provisionar (1–2 minutos).

## 2. Rodar o schema do banco

1. No painel do projeto, abra **SQL Editor** (menu lateral) → **New query**.
2. Abra o arquivo [`schema.sql`](./schema.sql) desta pasta, copie todo o conteúdo e cole no editor.
3. Clique em **Run**. Isso cria as tabelas `coligadas`, `empreendimentos`, `responsaveis`, `lancamentos`, `lancamentos_historico` e `pagadoria`, já com as políticas de acesso (RLS) para usuários autenticados.

## 3. Criar o usuário de login da equipe

1. Menu lateral → **Authentication** → **Users** → **Add user** → **Create new user**.
2. Preencha e-mail e senha de cada pessoa que vai usar o sistema (pode repetir esse passo para vários usuários da equipe).
3. Deixe a opção "Auto confirm user" marcada, para o login funcionar direto, sem precisar confirmar o e-mail.

## 4. Pegar a URL e a chave pública (anon key)

1. Menu lateral → **Project Settings** (ícone de engrenagem) → **API**.
2. Copie o valor de **Project URL** (algo como `https://xxxxxxxxxxxx.supabase.co`).
3. Copie o valor de **anon public** em Project API keys.

## 5. Colar no app

Abra [`index.html`](./index.html) desta pasta e edite estas duas linhas (procure por `COLE_AQUI`):

```js
const SB_URL='COLE_AQUI_A_PROJECT_URL';
const SB_ANON='COLE_AQUI_A_ANON_PUBLIC_KEY';
```

Substitua pelos valores copiados no passo 4. Salve o arquivo.

> A chave `anon` é pública por design (é a mesma que fica exposta em qualquer app frontend que usa Supabase) — a segurança real vem das políticas RLS do banco, que já exigem login para qualquer leitura/escrita.

## 6. Publicar / usar

- **Uso local**: dê duplo clique em `index.html` ou sirva a pasta com qualquer servidor estático.
- **Publicar** (ex: GitHub Pages, igual ao Conviver Events): suba `index.html` para um repositório e ative o Pages apontando pra branch/pasta raiz.

Depois de logar, o sistema já sobe com as abas **Lançamentos**, **Pagadoria** e **Configurações**. Cadastre primeiro as Coligadas e Empreendimentos em Configurações — eles alimentam os seletores de Lançamentos.

## 7. Migração do histórico do Conviver Events (opcional)

Quando você exportar o backup `.json` do Conviver Events, me envie o arquivo que eu escrevo o script de importação adaptando os campos (remove categoria/evento, mapeia o status antigo para o novo fluxo com "Pagamento Programado").

## Limite da consulta de CNPJ

O botão "Consultar" no CNPJ usa a API pública `publica.cnpj.ws`, que permite **3 consultas por minuto por IP**. Se aparecer erro de limite, aguarde cerca de 1 minuto e tente de novo.
