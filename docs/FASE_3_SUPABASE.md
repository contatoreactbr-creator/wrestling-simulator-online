# Fase 3 — autenticação e fundação online

O frontend em `index.html` agora usa `@supabase/supabase-js` via ESM CDN.

## Configuração atual

- URL do projeto: `https://hlhffwvhwefkmwvstolm.supabase.co`
- Chave: publishable (`sb_publishable_`), própria para cliente/browser.
- Não coloque uma chave `service_role` ou qualquer segredo no frontend.

A chave publishable identifica o projeto, mas não substitui as políticas RLS. As tabelas continuam protegidas pelas políticas criadas na migration da Fase 2.

## Fluxo implementado

1. Cadastro por e-mail e senha, enviando `display_name` como metadado do usuário.
2. Login por e-mail e senha.
3. Restauração da sessão ao recarregar a página.
4. Consulta da promoção do jogador autenticado.
5. Se ainda não existir promoção, exibe o formulário de fundação.
6. A fundação chama a função SQL `found_player_promotion`, que cria a promoção e 12 wrestlers fictícios com contratos numa única transação.
7. Logout.

## Teste manual

1. Abra a página publicada pelo GitHub Pages/host ou rode um servidor local.
2. Crie uma conta com um e-mail válido e senha de pelo menos 6 caracteres.
3. Se a confirmação de e-mail estiver habilitada no Supabase, confirme o e-mail antes de entrar.
4. Entre e crie uma promoção.
5. Confirme no Supabase Table Editor que há uma linha em `promotions`, 12 wrestlers novos em `wrestlers` e 12 contratos em `wrestler_contracts`.
6. Saia e entre novamente: a página deve reconhecer a promoção existente e não oferecer uma segunda fundação.

## Limites desta fase

- O calendário global permanece em `setup`; nenhum turno é processado ainda.
- Ainda não existe painel de gerenciamento do elenco.
- A geração de nomes fictícios no SQL usa uma lista inicial finita; deve ser ampliada antes de uma abertura pública em grande escala.
- A chave publishable pode aparecer no código do navegador. A segurança depende de RLS e das funções SQL com permissões corretas.
