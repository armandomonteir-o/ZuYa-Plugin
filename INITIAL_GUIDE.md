# Guia Inicial do Projeto: zuya-oh-my-zsh-plugin

Este documento resume as decisões iniciais e tecnologias para o plugin Zsh `zuya`.

## 1. Visão Geral

- **Objetivo:** Automatizar processos repetitivos de desenvolvimento de software via Oh My Zsh, com foco na criação de templates de projeto robustos utilizando configurações modernas (foco 2025).
- **Tecnologia Principal:** Zsh Scripting

## 2. Ferramentas e Práticas

- **Gerenciador de Pacotes:** Não aplicável (gerenciado pelo Oh My Zsh)
- **Docker:** Não será utilizado.
- **Diagramas/ADRs:** Não são necessários no momento.

## 3. Requisitos Iniciais (A discutir)

- **Funcionais (RFs):**
  - Fornecer comando CLI (`zuya create`) para gerar estruturas de projeto.
  - Suportar múltiplos templates (ex: Next.js + NestJS, Next.js + Express).
  - Configurar ferramental padrão (TypeScript, ESLint, Prettier, Jest) para cada template.
  - Integrar frameworks/libs de UI modernos (ex: Tailwind CSS para Next.js).
  - Opcionalmente, configurar setup de banco de dados (ex: PostgreSQL com TypeORM) via argumentos ou prompts interativos.
  - Incluir suporte Docker (`docker-compose.yml`) para serviços de banco de dados.
  - Automatizar cópia de diretrizes de desenvolvimento do usuário (`.mdc`) para novos projetos (`zuya copy-rules`).
  - Oferecer comandos de ajuda (`zuya help`).
- **Não Funcionais (RNFs):**
  - **Desempenho:** O carregamento do plugin não deve impactar significativamente o tempo de inicialização do Zsh.
  - **Compatibilidade:** Deve ser compatível com versões Zsh X.Y+ e Oh My Zsh.
  - **Usabilidade:** Comandos/aliases/funções devem ser fáceis de lembrar e usar.

## 4. Referências a Regras `.mdc`

- `development-workflow.mdc`: Guia o processo de desenvolvimento.
- `git.mdc`: Padrões para mensagens de commit.
- (Outras regras podem ser adicionadas se relevantes)
