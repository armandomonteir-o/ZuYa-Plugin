# Registro de Feedbacks e Sugestões

## 1. Sugestões de Melhoria no Workflow (Processo)

### Prioridade Média

20. **`[Status: To Do]`** **`[#workflow-improvement][#versioning] Sugestão: Questionar Estratégia de Release por Tags na Iniciação`** [Priority: Medium]

    - **Contexto:** Etapa 2 (Analysis, Initial Guide & Setup Discussion) do `development-workflow.mdc`.
    - **Feedback:** O workflow poderia incluir uma pergunta explícita ao usuário sobre se o projeto seguirá uma estratégia de versionamento e release baseada em tags Git (ex: v1.0.0, v1.1.0).
    - **Objetivo:** Alinhar as expectativas e potencialmente ajustar o fluxo de trabalho (ex: ênfase na criação de tags ao final de grupos de features) desde o início.
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Adicionar esta pergunta como parte das "Key Initial Questions" na Etapa 2.

21. **`[Status: To Do]`** **`[#workflow-improvement][#versioning][#planning] Sugestão: Detalhar Planejamento e Execução de Releases por Tags`** [Priority: Medium]

    - **Contexto:** Workflow geral, especialmente Etapa 4 (Review, Planning, Sub-Task Detailing) e Etapa 6 (Post-Task Review).
    - **Feedback:** O usuário questiona como o planejamento de releases por tags (ex: "adicionar 5 features para o próximo release v1.1.0") se encaixa no workflow.
    - **Objetivo:** Clarificar como agrupar features concluídas em um release versionado e como planejar o conteúdo de futuros releases.
    - **Sugestão de Melhoria (`development-workflow.mdc`):**
      - Na Etapa 4 (Planning), adicionar uma nota sobre como a priorização de Features pode ser usada para definir o escopo de um próximo release (tag).
      - Na Etapa 6 (Post-Task), adicionar uma verificação opcional ao final de uma Feature: "Esta Feature completa o escopo planejado para o release `vX.Y.Z`? Se sim, considerar criar e pushar a tag."
      - Talvez adicionar uma seção específica sobre Versionamento e Releases.

22. **`[Status: To Do]`** **`[#workflow-improvement][#testing] Sugestão: Detalhar Estratégia de Verificação Pós-Subtarefa em `development-workflow.mdc``** [Priority: Medium]

    - **Contexto:** Lições aprendidas durante a refatoração da Feature ZUYA-11 no projeto ZuYa.
    - **Feedback:** O workflow padrão (`development-workflow.mdc`) poderia beneficiar-se de diretrizes mais explícitas sobre como abordar a verificação após sub-tarefas, especialmente durante refatorações que podem impactar funcionalidades existentes ou a integridade de scripts/código gerado.
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Adicionar uma seção ou nota (possivelmente no Passo 4 ou 6) que discuta estratégias de verificação balanceadas, sugerindo:
      - Verificações rápidas (ex: linting, syntax check como `zsh -n script.sh`) após sub-tarefas que modificam código crítico ou geradores.
      - Verificações completas (ex: build, execução de testes funcionais básicos, `npm run dev`) agrupadas ao final de um conjunto de sub-tarefas ou de uma Feature de refatoração, para otimizar o tempo.
    - **Objetivo:** Oferecer um guia no workflow padrão para equilibrar a necessidade de detecção precoce de erros com a eficiência do processo de desenvolvimento durante refatorações.
    - **Nota:** Esta sugestão deriva da decisão prática tomada no projeto ZuYa, onde se optou por verificações de sintaxe `zsh -n` após edições no plugin e um teste completo ao final da refatoração do `setup_nextjs`.

23. **`[Status: To Do]`** **`[#workflow-improvement][#planning][#bug-tracking] Sugestão: Melhorar Criação de Sub-tarefas para Bugs`** [Priority: Medium]

    - **Contexto:** Discussão sobre como lidar com a correção do erro de limpeza no script `test_zuya.sh`.
    - **Feedback:** O processo de criação de sub-tarefas dedicadas a bugs ou pequenas correções que surgem durante a implementação de uma Feature/Sub-tarefa maior poderia ser mais intuitivo.
    - **Objetivo:** Facilitar o rastreamento e planejamento de correções sem interromper excessivamente o fluxo da tarefa principal.
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Explorar e documentar abordagens para registrar e lidar com bugs ou débitos técnicos identificados:
      - **Opção A (Sub-tarefa Imediata):** Criar imediatamente uma nova sub-tarefa dentro da Feature atual para a correção.
      - **Opção B (Tarefa Separada):** Criar uma nova tarefa (Bug ou Chore) separada para a correção, possivelmente vinculada à tarefa original com `dependsOn` ou `relatedTo`.
      - **Opção C (Nota de Conclusão):** Adicionar a necessidade da correção nas `completionNotes` da sub-tarefa atual, adiando a criação de uma tarefa formal para um momento posterior de planejamento.
      - Definir critérios para escolher a melhor abordagem (urgência, complexidade, impacto no fluxo).
    - **Nota:** No caso do erro de limpeza do teste, optamos por criar uma tarefa separada (`ZUYA-14`) para não poluir o escopo da refatoração `ZUYA-11`.

24. **`[Status: To Do]`** **`[#workflow-improvement][#documentation][#artifact-structure] Sugestão: Separar Arquivos de Aprendizado por Feature em Diretório Dedicado`** [Priority: Medium]

    - **Contexto:** Finalização das sub-tarefas de refatoração do Next.js (ZUYA-11.x) e necessidade de melhor organização.
    - **Feedback:** O arquivo único `PROJECT_LEARNINGS.md` pode se tornar muito grande. A separação por tarefa mãe (`[PARENT_TASK_ID]_LEARNINGS.md`) melhora, mas ainda pode poluir a raiz do projeto.
    - **Objetivo:** Melhorar a modularidade e organização dos registros de aprendizado, agrupando-os em um local específico.
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Modificar o workflow (principalmente Passos 4 e 6 e seção de Artefatos) para:
      1.  Criar um diretório `learnings/` na raiz do projeto, se não existir.
      2.  Em vez de um único `PROJECT_LEARNINGS.md` ou arquivos `[PARENT_TASK_ID]_LEARNINGS.md` na raiz, cada Tarefa Mãe (Feature/Epic) terá seu próprio arquivo de aprendizados dentro do diretório `learnings/` (ex: `learnings/ZUYA-11_LEARNINGS.md`).
      - A lógica do assistente precisaria identificar a Tarefa Mãe da Sub-tarefa atual.
      - Criar o diretório `learnings/` e o arquivo específico da Tarefa Mãe se não existirem.
      - Anexar os aprendizados pré e pós-tarefa ao arquivo correto dentro de `learnings/`.
      - Atualizar as referências em `PROJECT_TASKS.json` (completionNotes) para apontar para o caminho completo (`learnings/[PARENT_TASK_ID]_LEARNINGS.md`).
    - **Nota:** Isso melhora significativamente a organização da raiz do projeto.

25. **`[Status: To Do]`** **`[#workflow-improvement][#documentation][#mdc-feedback] Sugestão: Refinar Feedback MDC (Específico Local vs. Genérico no Log)`** [Priority: Medium]

    - **Contexto:** Reflexão sobre como aplicar melhorias identificadas nas regras MDC padrão durante um projeto.
    - **Feedback:** A lógica atual de "dupla ação" (aplicar a mesma melhoria padrão localmente e no `feedbacks.md`) pode não ser ideal quando a solução imediata no projeto é muito específica, mas o princípio por trás dela é genérico.
    - **Objetivo:** Permitir a aplicação de soluções específicas no `.mdc` local do projeto enquanto se captura a essência genérica da melhoria para os templates mestre.
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Modificar a seção de Feedback (Passo 6) para:
      - Quando uma melhoria para um `.mdc` padrão for identificada e aplicável imediatamente:
        1.  **Editar o `.mdc` local (`./.cursor/rules/arquivo.mdc`)** aplicando a solução **específica** necessária para o projeto atual (com confirmação do usuário).
        2.  **Registrar uma entrada em `feedbacks.md`** descrevendo o problema e a solução de forma **genérica**, focando no princípio ou lição aprendida, para que possa ser usada para atualizar os templates `.mdc` mestre de forma mais ampla.
    - **Nota:** Isso substitui parcialmente a lógica anterior da "dupla ação" onde a mesma sugestão era aplicada em ambos os locais.

26. **`[Status: To Do]`** **`[#workflow-improvement][#git][#version-control] Sugestão: Excluir Arquivos de Workflow dos Commits do Projeto`** [Priority: High]

    - **Contexto:** Após atualização do `development-workflow.mdc`.
    - **Feedback:** As alterações nos arquivos `.mdc` (regras) ou nos artefatos de gerenciamento do workflow (ex: `PROJECT_TASKS.json`, `feedbacks.md`, `*_LEARNINGS.md`) não devem ser incluídas nos commits relacionados ao código-fonte do projeto.
    - **Objetivo:** Manter o histórico do Git focado nas mudanças do produto/código, separando-o das mudanças no processo de desenvolvimento ou nos metadados do projeto gerenciados pelo workflow.
    - **Sugestão de Melhoria (`development-workflow.mdc` e `git.mdc`):**
      - **`development-workflow.mdc`:** No Passo 6 (Commit Proposal), adicionar uma nota explícita instruindo a IA a propor commits _apenas_ para alterações no código-fonte do projeto e arquivos diretamente relacionados (README, scripts de teste, etc.), excluindo arquivos `.mdc` e artefatos JSON/MD do workflow.
      - **`git.mdc`:** Adicionar uma seção ou nota reforçando que os commits devem refletir mudanças no produto e não no processo de desenvolvimento ou metadados.
    - **Nota:** Esta decisão implica que as alterações nos arquivos `.mdc` e artefatos são gerenciadas fora do histórico principal do Git do projeto ou não são versionadas de forma convencional junto com o código.

27. **`[Status: To Do]`** **`[#workflow-improvement][#git][#version-control][#automation] Sugestão: Criar Branches Git Automaticamente por Tarefa Mãe (Feature/Epic)`** [Priority: Medium]

    - **Contexto:** Planejamento e início da implementação de Tarefas Mãe (Features/Epics) no `development-workflow.mdc`.
    - **Feedback:** O workflow atual não define uma estratégia clara ou automatizada para a criação de branches Git associadas a Tarefas Mãe. Isso pode levar a inconsistências ou trabalho manual repetitivo.
    - **Objetivo:** Integrar a criação de branches Git ao workflow, garantindo que cada conjunto significativo de trabalho (Feature/Epic com sub-tarefas) seja desenvolvido em seu próprio branch isolado e nomeado de forma padronizada.
    - **Sugestão de Melhoria (`development-workflow.mdc`, `git.mdc`, Lógica da IA):**
      - **Quando:** Ao iniciar o detalhamento das sub-tarefas de uma nova Tarefa Mãe (Feature/Epic) na Etapa 4 (Review, Planning, Sub-Task Detailing) do workflow.
      - **Lógica:**
        1. Verificar se a tarefa sendo planejada é uma Tarefa Mãe (e.g., `taskType` é Feature ou Epic) E se ela possui `subTasks` definidas (ou se está planejado criar sub-tarefas para ela).
        2. Se ambas as condições forem verdadeiras, a IA deve propor a criação e o checkout de um novo branch Git.
        3. **Formato do Branch:** Usar um formato padronizado, como `feature/[TASK_ID]` ou `epic/[TASK_ID]` (ex: `feature/ZUYA-11`). O `git.mdc` pode ser atualizado para definir este padrão.
        4. O checkout para o novo branch deve ocorrer antes de iniciar a primeira sub-tarefa.
        5. Considerar o que fazer se o branch já existir (talvez apenas fazer checkout ou avisar o usuário).
      - **Atualizar Documentação:** Detalhar essa prática nos arquivos `development-workflow.mdc` e `git.mdc`.

## 2. Aprendizados e Sugestões para Regras `.mdc`

(Esta seção está vazia por enquanto)

## 3. Issues e Feedbacks sobre Ferramentas (Ex: Cursor)

27. **`[Status: Done]** **`[#tool-issue][#git][#shell-escaping][#commit-message] Dificuldade ao Executar `git commit` com Mensagens Multi-linha Complexas via Terminal`** [Priority: Medium]

    - **Contexto:** Tentativa de commitar as alterações da refatoração do `setup_nextjs` (Refs: ZUYA-11.2 a ZUYA-11.6, ZUYA-14).
    - **Problema:** As tentativas iniciais de executar `git commit` com uma mensagem multi-linha detalhada (usando múltiplas flags `-m`) falharam. A primeira falha foi devido a caracteres de nova linha não permitidos pela ferramenta, e a segunda tentativa provavelmente falhou devido à interpretação incorreta de caracteres especiais (como backticks ` \``) dentro da mensagem pelo shell, mesmo com as flags  `-m` separadas.
    - **Solução/Contorno Aplicado:** Simplificação da mensagem de commit, removendo os caracteres especiais (backticks) e mantendo a estrutura multi-linha com múltiplas flags `-m`.
    - **Sugestão de Correção/Melhoria (Workflow/AI):**
      - **Consciência sobre Escaping:** Ao construir comandos complexos para a ferramenta de terminal, especialmente `git commit` com múltiplas flags `-m`, ter maior atenção às limitações de escaping do shell. Evitar caracteres especiais problemáticos (`, $, !, {, }, etc.) ou garantir que sejam adequadamente escapados para o contexto de execução.
      - **Simplificação Proativa:** Para mensagens de commit complexas, considerar propor uma versão ligeiramente simplificada (sem formatação como backticks) para aumentar a chance de sucesso na execução via terminal.
      - **Verificação Opcional:** Em caso de mensagens complexas, talvez confirmar com o usuário se a versão formatada para o terminal está correta antes de executar.
    - **Sugestão de Correção/Melhoria (Ferramenta `run_terminal_cmd`):** Se a ferramenta tem como objetivo suportar comandos complexos, investigar se a análise e o escaping interno de argumentos multi-linha ou com caracteres especiais podem ser aprimorados para lidar melhor com esses casos do `git commit`.

28. **`[Status: To Do]`** **`[#workflow-improvement][#task-management][#artifact-structure][#future-enhancement][#complexity] Sugestão (ULTRA TASK): Dividir PROJECT_TASKS.json em Arquivos por Feature ([PARENT_TASK_ID]_TASKS.json)`** [Priority: Low]

    - **Contexto:** Discussão sobre a escalabilidade do `PROJECT_TASKS.json` e comparação com a separação dos arquivos `*_LEARNINGS.md`.
    - **Feedback/Ideia:** Propõe-se dividir o arquivo monolítico `PROJECT_TASKS.json` em múltiplos arquivos, cada um contendo as tarefas (Feature/Sub-tasks) de uma única tarefa mãe (e.g., `ZUYA-11_TASKS.json`).
    - **Motivação:** Melhorar a modularidade, organização e potencialmente lidar com preocupações sobre o tamanho excessivo de um único arquivo JSON para projetos grandes.
    - **Objetivo:** Tornar o gerenciamento de tarefas mais granular e focado por feature.
    - **Principais Desafios/Considerações (Fases Conceituais):** Esta é uma mudança estrutural complexa que exigiria um esforço significativo, incluindo:
      1.  **Estratégia de Resolução de Dependências:** Definir como o campo `dependsOn` funcionaria entre arquivos diferentes (ex: busca global, índice central, convenção de nomenclatura).
      2.  **Agregação para Visão Global:** Desenvolver um mecanismo para ler e combinar informações de todos os arquivos `*_TASKS.json` para fornecer uma visão geral do projeto (status, prioridades, etc.).
      3.  **Atualização do Workflow (`development-workflow.mdc`):** Reescrever partes significativas do workflow para refletir a leitura/escrita/gerenciamento de tarefas distribuídas.
      4.  **Adaptação da Lógica da IA:** Modificar profundamente a lógica da IA para encontrar, criar, atualizar, e gerenciar o ciclo de vida das tarefas e suas dependências em múltiplos arquivos.
      5.  **Garantia de IDs Únicos:** Implementar verificações robustas para garantir que os IDs das tarefas permaneçam globalmente únicos.
      6.  **Estratégia de Migração:** Planejar como migrar um `PROJECT_TASKS.json` existente para a nova estrutura.
      7.  **Avaliação de Performance:** Analisar o impacto do aumento de operações de I/O e agregação de dados.
      8.  **Tratamento de Dependências Complexas:** Definir como lidar com épicos ou dependências que abrangem múltiplas features.
      9.  **Atualização da Visualização/Interação:** Ajustar como as tarefas são apresentadas e discutidas.
      10. **Testes Abrangentes:** Validar rigorosamente todo o novo sistema de gerenciamento de tarefas.
    - **Conclusão/Recomendação:** Devido à alta complexidade e aos riscos associados (principalmente na gestão de dependências e lógica de agregação), esta sugestão deve ser considerada uma melhoria de longo prazo a ser abordada com extremo cuidado e planejamento detalhado, apenas se os benefícios superarem claramente a complexidade introduzida.

29. **`[Status: To Do]`** **`[#workflow-improvement][#git][#artifact-structure] Adicionar Diretório `learnings/`ao`.gitignore`** [Priority: High]

    - **Contexto:** Criação do diretório `learnings/` para armazenar arquivos `[PARENT_TASK_ID]_LEARNINGS.md` (Feedback #24).
    - **Problema:** O diretório `learnings/` e seu conteúdo não foram adicionados ao `.gitignore`, o que faria com que os arquivos de aprendizado fossem rastreados pelo Git indevidamente, contrariando a decisão do Feedback #26 (Excluir Arquivos de Workflow dos Commits).
    - **Objetivo:** Garantir que os artefatos de aprendizado sejam ignorados pelo Git.
    - **Sugestão de Melhoria (Implementação Imediata):**
      1.  Editar o arquivo `.gitignore` do projeto e adicionar a entrada `learnings/`.
      2.  **`development-workflow.mdc`:** Atualizar o Passo 3.4 (Sub-Task Detailing - Setup) para incluir `learnings/` na lista de sugestões para o `.gitignore`.

30. **`[Status: Done]** **`[#bug][#workflow-artifact][#shell-script] Timestamp Automático Quebrado nos Arquivos _LEARNINGS.md`** [Priority: High]
    - **Contexto:** Geração de entradas no arquivo `learnings/ZUYA-11_LEARNINGS.md` para a sub-tarefa ZUYA-11.7.
    - **Problema:** A string `_Data:_ $(date +'%Y-%m-%d %H:%M:%S')` está sendo escrita literalmente nos arquivos de aprendizado, em vez de ser substituída pela data/hora atual. Isso provavelmente ocorre devido à forma como o comando `cat << \EOF` estava sendo usado (o `\` antes de `EOF` impede a substituição de comando/variável dentro do heredoc).
    - **Objetivo:** Garantir que a data e hora corretas sejam registradas confiavelmente e automaticamente nas entradas de aprendizado.
    - **Solução Implementada e Prevenção Futura (Método Robusto):**
      1.  **Correção Manual:** A entrada ZUYA-11.7 foi corrigida manualmente com o timestamp correto.
      2.  **Método Robusto Mandatório para o Futuro:**
          - **Passo 1: Capturar Timestamp em Variável:** _Sempre_ obter a data/hora atual _antes_ de gerar o bloco de texto, armazenando-a em uma variável Zsh. Exemplo:
          ```zsh
          local CURRENT_TIMESTAMP
          CURRENT_TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
          ```
          - **Passo 2: Construir Arquivo com `echo`:** Utilizar múltiplos comandos `echo "..." >> "$target_file"` para construir o conteúdo do arquivo linha por linha. Para a linha do timestamp, referenciar explicitamente a variável:
          ```zsh
          echo "_Data: $CURRENT_TIMESTAMP_" >> "$learning_file"
          ```
          - **Justificativa:** Esta abordagem de duas etapas (capturar variável, depois usar `echo`) é a mais segura e robusta. Ela isola a execução do comando `date` da geração do texto e evita completamente as complexidades e potenciais erros de substituição e escaping associados a diferentes formas de `heredoc` (`<< EOF` vs `<< \EOF`) quando o bloco de texto pode conter caracteres especiais (`$`, `` ` ``, `\`).
    - **Sugestão de Melhoria (`development-workflow.mdc`):** Atualizar os passos 3.4 (Learning Log) e 3.6 (Update Learnings) para prescrever explicitamente este método robusto de duas etapas (capturar data em variável, gerar linhas com `echo`) como a forma padrão de inserir timestamps nos artefatos.

(Esta seção estava vazia antes do feedback #27)
