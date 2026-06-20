# Guia de Publicação — GitHub + Vercel

Como colocar o painel do Aeroporto no ar, com um endereço público (ex.: `aeroporto-santa-maria.vercel.app`), e como atualizar o site no futuro sem dor de cabeça.

Tempo estimado: 20 a 30 minutos. Você não precisa programar — é só seguir os cliques. Faça **primeiro** o `GUIA_SUPABASE.md` (banco de dados e login). Só depois publique aqui.

> **Por que GitHub + Vercel?** O GitHub guarda os arquivos do site (como um Google Drive para código). A Vercel pega esses arquivos e publica na internet, de graça e com HTTPS. Sempre que você atualizar o arquivo no GitHub, a Vercel republica sozinha em segundos.

---

## Antes de começar — confira a pasta do projeto

Na pasta `producao/` você deve ter:

- `index.html` — o site (já com a URL e a anon key do Supabase coladas — veja o Passo 6 do guia do Supabase).
- `supabase-setup.sql`, `feed-apoio-setup.sql`, `apoiadores-setup.sql`, `fotos-campo-setup.sql` — os scripts do banco.
- `GUIA_SUPABASE.md` e `GUIA_VERCEL.md` — os guias.

Para a internet, **só o `index.html` precisa ir ao ar**. Os `.sql` e os guias podem ficar junto no GitHub (não atrapalham e são úteis de manutenção) — eles não aparecem para o visitante.

> **Importante:** confirme que o `index.html` já está com a `SUPABASE_URL` e a `SUPABASE_ANON` preenchidas. Se ainda estiver "COLE_AQUI_A_URL", o site sobe em "modo demonstração". A anon key é pública por natureza — pode ir ao GitHub sem problema. **Nunca** coloque a chave `service_role` no arquivo.

---

## Passo 1 — Criar a conta no GitHub

1. Acesse `https://github.com` e clique em **Sign up**.
2. Crie a conta com seu e-mail e uma senha forte. Confirme o e-mail.
3. Pode escolher o plano **Free** — é suficiente.

---

## Passo 2 — Criar o repositório (a "pasta" do projeto no GitHub)

1. Logado no GitHub, clique no **+** no canto superior direito → **New repository**.
2. Preencha:
   - **Repository name:** `aeroporto-santa-maria` (ou o que preferir).
   - **Visibility:** **Public** (a Vercel publica de qualquer forma; público é mais simples).
   - Não marque nenhuma opção extra (README etc.).
3. Clique em **Create repository**.

---

## Passo 3 — Enviar os arquivos (sem usar comandos)

A forma mais fácil para quem não programa é o **upload pelo navegador**:

1. Na página do repositório recém-criado, clique em **uploading an existing file** (link no meio da tela) — ou em **Add file** → **Upload files**.
2. Abra a pasta `producao/` no seu computador e **arraste o `index.html`** para a área de upload. (Pode arrastar também os `.sql` e os `.md` — opcional.)
3. Em **Commit changes**, escreva algo como `Primeira versão do painel` e clique em **Commit changes**.

Pronto: seus arquivos estão no GitHub.

> **Dica:** o arquivo precisa se chamar exatamente `index.html` e ficar na **raiz** do repositório (não dentro de uma subpasta). Assim a Vercel o encontra automaticamente.

---

## Passo 4 — Criar a conta na Vercel e conectar o GitHub

1. Acesse `https://vercel.com` e clique em **Sign Up**.
2. Escolha **Continue with GitHub** e autorize a Vercel a acessar sua conta do GitHub (é seguro e padrão).
3. Pode escolher o plano **Hobby** (gratuito).

---

## Passo 5 — Publicar (deploy)

1. No painel da Vercel, clique em **Add New…** → **Project**.
2. Na lista **Import Git Repository**, encontre `aeroporto-santa-maria` e clique em **Import**.
3. A Vercel detecta que é um site estático. **Não precisa mexer em nada:**
   - Framework Preset: **Other** (deixe como veio).
   - Build Command / Output: deixe em branco/padrão.
4. Clique em **Deploy** e aguarde ~30 segundos.
5. Aparece a tela de **Congratulations** com um endereço tipo `https://aeroporto-santa-maria.vercel.app`. Clique para abrir — o painel está no ar.

---

## Passo 6 — Testar o site publicado

1. Abra o endereço `.vercel.app` no celular e no computador.
2. O painel deve carregar os dados do Supabase (as 9 etapas, o avanço geral, os marcos).
3. Clique em **Área administrativa**, faça login com o e-mail/senha que você criou no Supabase (Passo 5 do guia do Supabase).
4. Edite uma etapa, clique em **Salvar e publicar** — a mudança aparece para qualquer visitante na hora.

Se aparecer a faixa amarela "Modo demonstração", volte ao `index.html` e confira se a URL e a anon key do Supabase estão coladas corretamente, então reenvie o arquivo (Passo 7).

---

## Passo 7 — Como atualizar o site depois (o dia a dia)

Você tem **dois tipos** de atualização:

**a) Mudar status/percentual das etapas, aprovar mensagens, subir fotos, cadastrar logos**
→ Isso é feito direto na **Área administrativa** do site (login). **Não precisa mexer no GitHub nem na Vercel.** Sai no ar na hora.

**b) Mudar o visual, textos fixos ou estrutura do site (o `index.html`)**
→ Atualize o arquivo no GitHub:
   1. No repositório, abra o `index.html` e clique no **lápis** (Edit), ou use **Add file → Upload files** para substituir.
   2. Faça a alteração / suba o arquivo novo e clique em **Commit changes**.
   3. A Vercel **republica sozinha** em segundos. Recarregue o site para ver.

---

## Endereço próprio (domínio) — opcional

Se quiser um endereço tipo `aeroporto.santamaria.rs.gov.br` em vez do `.vercel.app`:

1. Na Vercel, abra o projeto → **Settings** → **Domains** → **Add**.
2. Digite o domínio desejado e siga as instruções de DNS que a Vercel mostrar.
3. O ajuste de DNS é feito por quem administra o domínio do Município (TI da Prefeitura). A Vercel cuida do certificado HTTPS automaticamente.

---

## Organização recomendada do projeto

Para manter tudo arrumado e fácil de retomar no futuro:

- **Uma fonte da verdade do site:** trabalhe sempre no `producao/index.html`. A versão demo (fora da pasta `producao`) serve só para testes locais sem banco.
- **No GitHub:** mantenha junto o `index.html` e os arquivos `.sql` e `.md`. Assim, se precisar reconstruir o banco ou treinar outra pessoa, está tudo no mesmo lugar.
- **Senhas e chaves:** a senha do admin e a senha do banco ficam **só** no Supabase, nunca no GitHub. A anon key pode ficar no `index.html` (é pública). A `service_role` **nunca**.
- **Acessos da equipe:** cada pessoa que administra o painel deve ter o próprio usuário no Supabase (Authentication → Users). Evite compartilhar uma senha única.
- **Backup rápido:** dentro da Área administrativa há **Exportar dados (.json)** — baixe de vez em quando para ter uma cópia do estado do painel.

---

## Problemas comuns

- **Site abre mas mostra "Modo demonstração":** a URL/anon key do Supabase não foram coladas no `index.html`, ou o arquivo enviado ao GitHub ainda é o antigo. Corrija o arquivo e reenvie.
- **"404" ou página em branco na Vercel:** o `index.html` provavelmente está dentro de uma subpasta no repositório. Ele precisa estar na **raiz**. Reenvie na raiz.
- **Login não funciona no site publicado:** confirme que o usuário foi criado no Supabase com **Auto Confirm** e que você está usando o e-mail/senha exatos.
- **Mudei o arquivo no GitHub e o site não mudou:** aguarde alguns segundos e recarregue com **Ctrl+F5** (limpa o cache). Confira na Vercel, em **Deployments**, se o último deploy ficou **Ready**.
- **Fotos não sobem:** isso é Supabase, não Vercel — verifique no Storage se o bucket `fotos-campo` existe e está **Public** e se você rodou o `fotos-campo-setup.sql`.
