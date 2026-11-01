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

Esta é a **Fase 1 — protótipo de interface**. O site atual é uma demonstração local e ainda não possui contas, banco de dados, partidas online ou sincronização multiplayer. Os dados criados no navegador não são compartilhados entre jogadores.

## Executar localmente

1. Baixe ou clone este repositório.
2. Abra `index.html` no navegador.

Também é possível executar um servidor local com Python:

```bash
python -m http.server 8080
```

Acesse `http://localhost:8080`.

## Próximas etapas

1. Estruturar o frontend e a navegação do jogo.
2. Criar backend, autenticação e banco de dados.
3. Implementar identidade global dos wrestlers e contratos.
4. Implementar o calendário global autoritativo.
5. Adicionar negociações, shows, finanças e multiplayer.

## Dados e propriedade intelectual

Nomes, marcas, imagens, logotipos e outros materiais de empresas e wrestlers reais podem exigir autorização/licenciamento. A inclusão de dados reais será feita com atenção à origem, precisão e direitos de uso.
