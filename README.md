# Wrestling Simulator Online

**Wrestling Simulator Online** é um simulador de gerenciamento de wrestling profissional para navegador, planejado para PC e dispositivos móveis.

## Regras centrais do universo

- Todo jogador começa criando uma promoção própria do zero.
- Promoções reais são entidades controladas pelo sistema; jogadores não podem assumir seu gerenciamento.
- Será possível negociar contratações, parcerias e aquisições de empresas reais, respeitando regras e disponibilidade.
- Cada nova promoção começa com um elenco de wrestlers genéricos.
- Identidades de wrestlers deverão ser globais e permanentes, sem duplicatas entre promoções.
- O calendário será compartilhado: nenhum jogador poderá avançar o tempo sozinho.

## Visão do calendário online

O servidor será a autoridade do relógio global. A proposta inicial é usar turnos semanais, com uma janela de planejamento em tempo real. Ao fechar o turno, o servidor processará as ações de todos e avançará o universo simultaneamente. A duração exata da janela será definida antes da implementação multiplayer.

## Estado atual

- **Fase 1 — protótipo de interface:** publicada em `index.html`; ainda funciona localmente.
- **Fase 2 — fundação do banco:** migration PostgreSQL/Supabase em `supabase/migrations/202611010001_initial_world.sql`.

A Fase 2 prepara perfis, promoções, wrestlers globais, contratos, relógio compartilhado e ordens por turno. Ela ainda precisa ser aplicada em um projeto Supabase e conectada ao frontend. O multiplayer ainda não está ativo.

## Executar localmente

1. Baixe ou clone este repositório.
2. Abra `index.html` no navegador.

Também é possível executar um servidor local com Python:

```bash
python -m http.server 8080
```

Acesse `http://localhost:8080`.

## Próximas etapas

1. Criar um projeto Supabase e aplicar a migration da Fase 2 (veja `docs/FASE_2_BANCO_DE_DADOS.md`).
2. Conectar cadastro/login e fundação da promoção ao banco.
3. Implementar o serviço de servidor que fecha e processa os turnos globais.
4. Adicionar negociações, shows, finanças e multiplayer.

## Dados e propriedade intelectual

Nomes, marcas, imagens, logotipos e outros materiais de empresas e wrestlers reais podem exigir autorização/licenciamento. A inclusão de dados reais será feita com atenção à origem, precisão e direitos de uso.
