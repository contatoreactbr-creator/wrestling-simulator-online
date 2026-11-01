# Fase 2 — banco de dados e regras de segurança

## Escolha técnica inicial

O projeto usa Supabase como primeira opção de infraestrutura: PostgreSQL para os dados, Supabase Auth para contas e Row Level Security (RLS) para limitar o acesso de cada jogador.

## O que esta migração cria

- Perfis associados às contas do Supabase Auth.
- Promoções de jogadores e referências de empresas reais controladas pelo sistema.
- Identidades globais de wrestlers.
- Contratos e vínculo atual de cada wrestler.
- Relógio global e turnos compartilhados.
- Envio de ordens por jogador para o turno atual.
- Fundação transacional de uma promoção com 12 wrestlers fictícios únicos.

## Regras de integridade importantes

- Cada jogador pode fundar uma única promoção nesta primeira versão.
- Jogadores não recebem permissão para inserir, editar ou apagar empresas, wrestlers e contratos diretamente pelo navegador.
- A promoção é criada por uma função transacional do banco.
- Cada wrestler só pode ter um contrato ativo por vez.
- Nomes dos wrestlers fictícios são únicos globalmente; IDs UUID são permanentes.
- Empresas reais só poderão ser inseridas por processo administrativo confiável.
- O relógio global começa em estado `setup`; só um processo de servidor poderá colocá-lo em `running` e avançar turnos.
- Ordens só podem ser enviadas durante um turno aberto e para a promoção pertencente ao jogador.

## Instalação

1. Crie um projeto no painel do Supabase.
2. Abra **SQL Editor**.
3. Copie e execute o arquivo `supabase/migrations/202611010001_initial_world.sql`.
4. Em **Authentication**, habilite o método de login desejado (por exemplo, e-mail).
5. Não publique chaves secretas nem a chave `service_role` no frontend.

Esta migração é a fundação do banco, não uma aplicação multiplayer pronta. O frontend ainda precisa receber autenticação real e chamar a função `found_player_promotion`; também falta criar o serviço confiável que fecha e processa os turnos globais.

## Próxima etapa

Conectar a tela do jogo ao Supabase Auth, implementar cadastro/login e substituir a criação local de promoção pela função segura do banco. Depois disso, criar o processador de turnos no servidor.
