<!-- LEARN-START: ZUYA-11.7 -->

## Tarefa: ZUYA-11.7 - Research Current NestJS/TypeScript/Tooling Best Practices (2025 Focus)

_Data: 2025-04-13 00:15:13_

### Diretrizes Consultadas

- Documentação oficial do NestJS (v10), Node.js (v20 LTS), ESLint, Prettier, Jest, TypeScript.
- Repositórios de projetos NestJS de referência.
- Regras internas: `nestjs-typescript-best-practices.mdc`, `testing.mdc`.

### Pontos Pesquisados (Critérios de Aceite AC11.7.1 a AC11.7.6)

1.  **Node.js LTS:** Confirmado **Node.js 20.x (LTS)** como a versão recomendada e suportada.
2.  **NestJS Version:** Versão estável atual é **v10**. O `@nestjs/cli` usará a mais recente.
3.  **ESLint:**
    - **Padrão:** O `@nestjs/cli` gera **`.eslintrc.js` (formato legado)** por padrão.
    - **Flat Config:** Possível, mas exige configuração manual e o ecossistema NestJS (exemplos, integrações) ainda está mais alinhado com o formato legado.
    - **Decisão:** Manter a geração do **`.eslintrc.js`** no plugin `zuya` por enquanto, para maior compatibilidade com o padrão do NestJS CLI. Garantir que os plugins (`@typescript-eslint/parser`, `@typescript-eslint/eslint-plugin`, `eslint-plugin-prettier`, `eslint-config-prettier`) e regras estejam atualizados.
4.  **Prettier:** Integração padrão via `eslint-plugin-prettier` e `eslint-config-prettier` no `.eslintrc.js`.
5.  **Jest:** Configuração padrão do NestJS CLI usando `ts-jest` como preset geralmente é adequada. Revisar as opções geradas.
6.  **TypeScript:** `tsconfig.json` padrão do CLI é bom (`strict: true`, `module: CommonJS`). Verificar `target` (talvez `ES2022`) e `moduleResolution`.

### Decisões para Refatoração `setup_nestjs`

- Usar `@nestjs/cli@latest` para gerar o projeto base.
- Manter a geração do arquivo `.eslintrc.js` (formato legado), mas revisar e atualizar os plugins e regras dentro dele.
- Revisar a configuração do Jest (`package.json` ou `jest.config.js`) gerada pelo CLI e fazer ajustes mínimos se necessário.
- Revisar o `tsconfig.json` gerado e ajustar o `target` se apropriado para Node 20 (e.g., `ES2022`).

### Próximos Passos

- Implementar as atualizações nas dependências e configurações geradas pela função `setup_nestjs` em `zuya.plugin.zsh` (Sub-tarefas ZUYA-11.8 em diante).

### Tags

`[#research]`, `[#nestjs]`, `[#eslint]`, `[#jest]`, `[#typescript]`, `[#best-practices]`, `[#planning]`, `[#decision]`

<!-- LEARN-END: ZUYA-11.7 -->
