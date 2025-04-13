# ZuYa Oh My Zsh Plugin - v1.0.0

🧙‍♂️ Seu assistente mágico para scaffolding de projetos fullstack TypeScript!

## 🎯 Objetivo

Automatizar processos repetitivos de desenvolvimento de software via Oh My Zsh, com foco na criação de templates de projeto robustos e configuráveis utilizando as tecnologias e configurações mais atuais (foco 2025).

ZuYa é um plugin para [Oh My Zsh](https://ohmyz.sh/) que acelera a criação de novos projetos fullstack
baseados em TypeScript, configurando estruturas comuns e copiando suas regras de desenvolvimento
personalizadas do Cursor.

## Funcionalidades (v1.0.0)

### 🚀 Tecnologias Principais

- **Plugin:** Zsh Scripting
- **Projetos Gerados:**
  - **Core:** TypeScript, Node.js, npm
  - **Frontend:** Next.js (App Router)
  - **Backend:** NestJS, Express
  - **Estilo:** Tailwind CSS
  - **Qualidade:** ESLint, Prettier, Jest
  - **BD/ORM:** TypeORM (PostgreSQL), Zod (Express)
  - **Infra (BD):** Docker Compose

### Detalhes das Funcionalidades

- **Criação de Projetos:**
  - Gera rapidamente a estrutura base para aplicações frontend e backend.
  - Comando: `zuya create <nome-projeto> [template] [--db <tipo-db>] [--force-rules]`
- **Templates Disponíveis:**
  - `next-nest` (Padrão): Frontend Next.js (App Router, Tailwind, ESLint, Jest) + Backend NestJS (ESLint,
    Jest).
  - `next-express`: Frontend Next.js + Backend Express (TypeScript, ESLint, Prettier, Jest, Nodemon, Zod).
- **Configuração de Banco de Dados:**
  - Suporte inicial para **PostgreSQL** (com TypeORM) via flag `--db postgresql`. Instala dependências,
    atualiza `.env.example` e gera um `docker-compose.yml` básico.
  - Placeholders para outros bancos de dados (MySQL, SQLite, MongoDB, Redis, Cassandra).
  - Modo interativo para seleção do banco de dados se a flag `--db` não for usada.
- **Cópia de Regras do Cursor:**
  - Comando: `zuya copy-rules [force]`
  - Copia arquivos `.mdc` de um diretório de templates configurado para o diretório `.cursor` do projeto
    atual.
  - Busca arquivos na raiz do diretório de template e no subdiretório `rules/`.
  - **Não sobrescreve** arquivos existentes por padrão. Use `zuya copy-rules 1` ou a flag `--force-rules` no
    comando `create` para sobrescrever.
  - Prioriza um arquivo chamado `development-workflow.mdc` renomeando-o para `000_development-workflow.mdc`
    (apenas se a cópia for forçada).
- **Validação de Tipos (Backend Express):**
  - Instala automaticamente a biblioteca `zod`.
  - Cria um diretório `src/schemas` sugerido.
  - Inclui um exemplo comentado de middleware de erro Zod em `src/index.ts`.
- **Robustez:**
  - Verifica a existência de dependências externas (`git`, `npm`, `npx`, `node`) antes de iniciar.
  - Tratamento de erros básico durante o processo de criação.

## Instalação

**Pré-requisitos (Ubuntu / Debian-based):**

Antes de instalar o plugin, certifique-se de que possui `zsh`, `git` e `curl` (ou `wget`) instalados. Você pode instalá-los com:

```bash
sudo apt update && sudo apt install zsh git curl
```

**Instalando Oh My Zsh:**

Este plugin requer o [Oh My Zsh](https://ohmyz.sh/). Se ainda não o tiver, instale-o (isso geralmente também define Zsh como seu shell padrão):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

_Siga as instruções na tela após a execução do comando._

**Instalando o Plugin ZuYa:**

1.  Clone este repositório para o diretório de plugins customizados do Oh My Zsh:

    ```bash
    # Substitua <URL_DO_SEU_REPO> pela URL real do repositório ZuYa
    git clone <URL_DO_SEU_REPO> ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zuya
    ```

    _Alternativamente, copie manualmente o diretório do plugin para `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/` e renomeie-o para `zuya`._

2.  Adicione `zuya` à lista de plugins no seu arquivo `~/.zshrc`. Encontre a linha que começa com `plugins=` e adicione `zuya`:

    ```zsh
    # Exemplo:
    plugins=(git otherplugin zuya)
    ```

3.  Recarregue sua configuração do Zsh para aplicar as mudanças:
    ```zsh
    source ~/.zshrc
    ```

## Configuração (Opcional)

Por padrão, `zuya` busca templates MDC em
`/home/armando-monteiro/Documentos/codes/development-typescript-guidelines/.cursor`.

Para usar um diretório diferente (por exemplo, seu próprio repositório de templates), defina a variável de
ambiente `ZAYA_MDC_TEMPLATES_DIR` no seu `~/.zshrc` **antes** da linha que carrega o Oh My Zsh:

```zsh
# Exemplo:
export ZAYA_MDC_TEMPLATES_DIR="/caminho/absoluto/para/seu/diretorio/.cursor"

# ... (resto do seu .zshrc)
plugins=(... zuya)
source $ZSH/oh-my-zsh.sh
```

## Uso

Consulte a ajuda do plugin:

```bash
zuya help
```

Exemplo de criação:

```bash
# Criar projeto com Next.js/Express, PostgreSQL, sobrescrevendo regras MDC
zuya create meu-novo-app next-express --db postgresql --force-rules

# Criar projeto com Next.js/Nest (padrão), perguntando sobre o DB
zuya create outro-app
```

## Testes

Um script de teste (`test_zuya.sh`) está incluído para verificar as funcionalidades básicas. Execute-o com:

```bash
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zuya
./test_zuya.sh
```

## Licença

[MIT](LICENSE)
