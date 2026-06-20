# Guia do Supabase — Painel do Aeroporto Santa Maria

Passo a passo para sair do modo demonstração (localStorage) e colocar o painel no ar com dados ao vivo, login seguro e a nova galeria de fotos de campo.

Tempo estimado: 20 a 30 minutos. Você não precisa saber programar — é tudo no painel do Supabase e um colar de duas linhas no arquivo do site.

---

## O que você vai precisar

- Um e-mail para criar a conta do Supabase (plano gratuito serve).
- Os arquivos `.sql` que já estão na pasta `producao/`:
  - `supabase-setup.sql` — o painel (etapas e marcos)
  - `feed-apoio-setup.sql` — o mural de mensagens de apoio
  - `apoiadores-setup.sql` — as logomarcas das instituições
  - `fotos-campo-setup.sql` — a galeria de fotos (novo)
- O arquivo `producao/index.html` (onde você vai colar as credenciais).

---

## Passo 1 — Criar a conta e o projeto

1. Acesse `https://supabase.com` e clique em **Start your project**. Crie a conta (pode usar login com Google/GitHub).
2. No painel, clique em **New project**.
3. Preencha:
   - **Name:** `aeroporto-santa-maria` (ou o que preferir)
   - **Database Password:** crie uma senha forte e **guarde** num lugar seguro. É a senha do banco — não é a senha de login do admin do site.
   - **Region:** escolha **South America (São Paulo)** para menor latência.
4. Clique em **Create new project** e aguarde 1–2 minutos enquanto o projeto é provisionado.

---

## Passo 2 — Pegar a URL e a chave pública (anon key)

1. No menu lateral, vá em **Project Settings** (ícone de engrenagem) → **API**.
2. Anote dois valores:
   - **Project URL** — algo como `https://abcdefgh.supabase.co`
   - **anon public** (em *Project API keys*) — uma chave longa que começa com `eyJ...`
3. Pode deixar essa aba aberta; você vai usar esses valores no Passo 6.

> A chave **anon** é pública por natureza — pode ficar no código do site. A segurança vem das políticas (RLS) que os SQLs já configuram. **Nunca** use a chave `service_role` no site.

---

## Passo 3 — Rodar os SQLs (cria as tabelas e a segurança)

1. No menu lateral, abra **SQL Editor** → **New query**.
2. Rode **um arquivo por vez, nesta ordem**. Para cada um: abra o `.sql` no seu computador, copie todo o conteúdo, cole no editor e clique em **Run**.
   1. `supabase-setup.sql`
   2. `feed-apoio-setup.sql`
   3. `apoiadores-setup.sql`
   4. `fotos-campo-setup.sql`
3. Cada execução deve terminar com **Success**. Se aparecer um aviso de que algo "already exists", pode ignorar — os scripts foram feitos para rodar mais de uma vez sem quebrar.

Ao final você terá as tabelas `painel_aeroporto`, `mensagens_apoio`, `apoiadores` e `fotos_campo`, além do bucket de fotos.

---

## Passo 4 — Conferir o bucket de fotos

O `fotos-campo-setup.sql` já cria o bucket, mas vale confirmar:

1. No menu lateral, vá em **Storage**.
2. Você deve ver um bucket chamado **fotos-campo** marcado como **Public**.
3. Se não aparecer, clique em **New bucket**, nomeie `fotos-campo`, marque **Public bucket** e salve.

É nesse bucket que as fotos enviadas pelo admin ficam guardadas.

---

## Passo 5 — Criar o usuário admin (quem pode editar o painel)

A senha do admin **não fica no site** — fica no Supabase Auth.

1. No menu lateral, vá em **Authentication** → **Users** → **Add user** → **Create new user**.
2. Informe um **e-mail** e uma **senha** para a pessoa que vai administrar o painel.
3. Marque **Auto Confirm User** (assim o login já funciona sem precisar confirmar e-mail).
4. Clique em **Create user**.

Repita para cada pessoa da equipe que precisar de acesso. Para trocar a senha depois, é nesse mesmo lugar (ou pelo fluxo "Esqueci a senha").

---

## Passo 6 — Conectar o site ao Supabase

1. Abra o arquivo `producao/index.html` num editor de texto.
2. Lá no começo do `<script>` existem duas linhas:

   ```js
   const SUPABASE_URL  = "COLE_AQUI_A_URL";       // ex: https://abcdefgh.supabase.co
   const SUPABASE_ANON = "COLE_AQUI_A_ANON_KEY";  // ex: eyJhbGciOi...
   ```

3. Substitua os textos entre aspas pelos valores do **Passo 2** (a Project URL e a anon key). Mantenha as aspas.
4. Salve o arquivo.

Pronto: ao abrir o `index.html`, o site sai do "modo demonstração" e passa a ler/gravar no Supabase.

---

## Passo 7 — Testar

1. Abra `producao/index.html` no navegador.
2. O painel deve carregar os dados do banco (o seed inicial de junho/2026).
3. Clique em **Área administrativa**, faça login com o e-mail/senha do **Passo 5**.
4. Edite o progresso de uma etapa e clique em **Publicar** — deve aparecer "✓ Publicado para todos".
5. Recarregue a página pública: a mudança aparece para qualquer visitante.

---

## Como vai funcionar a galeria de fotos

Depois que o front-end da moldura estiver ligado (próxima etapa do nosso trabalho), o fluxo será:

- No admin, você escolhe a foto do computador e, opcionalmente, escreve uma legenda.
- A imagem é redimensionada e comprimida no navegador (para carregar rápido), enviada ao bucket **fotos-campo** e registrada na tabela **fotos_campo**.
- Na página pública, as fotos passam em sequência (crossfade) dentro da moldura ao lado do título, com a legenda embaixo.
- Para remover uma foto, basta excluí-la no admin — some do site na hora.

---

## Dicas de segurança

- Use uma senha forte no admin e não compartilhe a chave `service_role`.
- Mantenha o **RLS ativado** em todas as tabelas (os SQLs já deixam assim) — é o que impede um visitante de editar o painel.
- O bucket de fotos é público **para leitura** (necessário para exibir as imagens), mas só o admin logado pode enviar ou excluir arquivos.

---

## Problemas comuns

- **"Configure o Supabase…" continua aparecendo:** confira se a URL começa com `https://` e se a anon key foi colada inteira (é bem longa).
- **Login não funciona:** confirme que o usuário foi criado com **Auto Confirm** e que está usando o e-mail/senha exatos.
- **Erro ao salvar/publicar:** você precisa estar **logado** no admin — a escrita é bloqueada para visitantes por segurança.
- **Foto não sobe:** verifique no **Storage** se o bucket `fotos-campo` existe e está **Public**, e se você rodou o `fotos-campo-setup.sql`.
