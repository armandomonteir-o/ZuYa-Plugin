#!/usr/bin/env zsh

# ZuYa - Assistente mágico para desenvolvimento fullstack TypeScript
# Versão: 1.0.1 (Abril 2025)

# --- Configurações ---
# URL do repositório template Next.js (usado por setup_nextjs)
_ZUYA_NEXTJS_TEMPLATE_URL="https://github.com/armandomonteir-o/zuya-plugin-template-nextjs.git"

# Diretório onde seus arquivos .mdc estão armazenados
# Permite sobrescrever via variável de ambiente ZAYA_MDC_TEMPLATES_DIR
# Modificado para usar o caminho do repositório de guidelines como padrão
: "${MDC_TEMPLATES_DIR:=${ZAYA_MDC_TEMPLATES_DIR:-"/home/armando-monteiro/Documentos/codes/development-typescript-guidelines/.cursor"}}" # Usar caminho absoluto para o repositório clonado

# --- Verificação Inicial ---
if [[ ! -d "$MDC_TEMPLATES_DIR" ]]; then
  echo "❌ Erro: Diretório de templates MDC não encontrado em '$MDC_TEMPLATES_DIR'."
  echo "Verifique o caminho ou defina a variável de ambiente ZAYA_MDC_TEMPLATES_DIR."
  return 1 # Use return em vez de exit em scripts de plugin
fi
# -------------------------

# Função auxiliar para verificar dependências externas
_zuya_check_deps() {
  local missing_deps=0
  local deps=("git" "npm" "npx" "node") # Dependências essenciais
  echo "🔍 Verificando dependências necessárias..."
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
      echo "❌ Erro: Comando '$dep' não encontrado. Por favor, instale-o."
      missing_deps=1
    fi
  done
  # Verificar Docker separadamente (opcional)
  if ! command -v "docker" &> /dev/null; then
        echo "⚠️ Aviso: Comando 'docker' não encontrado. Necessário para usar bancos de dados via Docker com 'docker compose up'."
  fi

  if [[ "$missing_deps" -eq 1 ]]; then
    return 1 # Falha se alguma dependência essencial estiver faltando
  fi
    echo "✅ Dependências essenciais encontradas."
  return 0
}

# Função principal
zuya() {
  local command=$1
  shift

  case "$command" in
    create)
      zuya_create_project "$@"
      ;;
    copy-rules)
      zuya_copy_rules "$@"
      ;;
    help)
      zuya_help
      ;;
    *)
      echo "🧙‍♂️ ZuYa: Comando desconhecido: $command"
      zuya_help
      return 1
      ;;
  esac
}

# Função para criar um novo projeto
zuya_create_project() {
  # Verificar dependências primeiro
  _zuya_check_deps || return 1

  local project_name=$1
  local template=${2:-"next-nest"}
  local db_choice="" # Variável para guardar escolha do DB se passada por argumento
  local force_rules=0 # Flag para forçar sobrescrita das regras

  # --- Processamento de argumentos (exemplo para DB) ---
  # Você pode expandir isso para mais opções
  while [[ $# -gt 0 ]]; do
    case $1 in
      --db)
        db_choice="$2"
        shift 2
        ;;
      --force-rules)
        force_rules=1
        shift # Consumir a flag
        ;;
      *)
        # Se não for uma flag conhecida, assume que é nome/template
        if [[ -z "$project_name" ]]; then
          project_name=$1
        elif [[ "$template" == "next-nest" && -z "${2:-}" ]]; then # Evita sobrescrever template se já definido
           template=$1
        fi
        shift
        ;;
    esac
  done
  # ----------------------------------------------------

  if [[ -z "$project_name" ]]; then
    echo "❌ Nome do projeto é obrigatório"
    echo "Uso: zuya create <nome-projeto> [template] [--db <tipo-db>]"
    return 1
  fi

  echo "🚧 Criando projeto '$project_name' com template '$template'..."

  # Verificar se o diretório já existe
  if [[ -d "$project_name" ]]; then
    echo "❌ Erro: Diretório '$project_name' já existe."
    return 1
  fi

  # Criar diretório do projeto e verificar sucesso
  mkdir -p "$project_name" || { echo "❌ Erro ao criar diretório '$project_name'."; return 1; }
  cd "$project_name" || { echo "❌ Erro ao entrar no diretório '$project_name'."; return 1; } # Entrar no diretório

  # Inicializar Git
  echo "🔄 Inicializando repositório Git..."
  git init -q # -q para modo silencioso

  # Configurar estrutura com base no template
  case "$template" in
    "next-nest")
      setup_nextjs "frontend" || return 1
      setup_nestjs "backend" || return 1
      ;;
    "next-express")
      setup_nextjs "frontend" || return 1
      setup_express "backend" || return 1
      ;;
    *)
      echo "❌ Template desconhecido: $template"
      # Limpar diretório criado antes de sair
      cd ..
      rm -rf "$project_name"
      return 1
      ;;
  esac

  # Configurar banco de dados (interativo ou via flag)
  if [[ -n "$db_choice" ]]; then
    echo "⚙️ Configurando banco de dados '$db_choice' (via argumento)..."
    # Adicionar lógica para chamar setup_<db_choice> diretamente
    case "$db_choice" in
        postgresql) setup_postgresql ;;
        mysql) setup_mysql ;;
        sqlite) setup_sqlite ;;
        mongodb) setup_mongodb ;;
        redis) setup_redis ;;
        cassandra) setup_cassandra ;;
        *) echo "⚠️ Tipo de banco de dados '$db_choice' desconhecido via argumento." ;;
    esac
  else
    setup_database # Chama a função interativa se --db não foi usado
  fi

  # Copiar seus arquivos .mdc existentes
  zuya_copy_rules "$force_rules" || return 1 # Parar se a cópia falhar

  echo "✅ Projeto '$project_name' criado com sucesso no diretório $(pwd)!"
  echo "ℹ️  Não se esqueça de configurar as variáveis de ambiente (.env) se necessário."
}

# Função para copiar seus arquivos .mdc existentes
zuya_copy_rules() {
  local force_rules=$1 # Recebe 1 se forçar, 0 ou vazio caso contrário
  local copy_opts="-n" # Opção padrão: --no-clobber

  if [[ "$force_rules" -eq 1 ]]; then
    echo "⚠️  Forçando sobrescrita das regras .mdc existentes."
    copy_opts="" # Sem opções extras, sobrescreverá
  fi

  echo "🔄 Copiando regras do Cursor..."

  local project_rules_dir=".cursor" # Diretório padrão do Cursor
  local source_rules_dir="$MDC_TEMPLATES_DIR" # Diretório fonte principal
  local workflow_file="development-workflow.mdc"
  local source_workflow_path=""

  # Determinar o caminho completo do workflow no template
  if [[ -f "$source_rules_dir/rules/$workflow_file" ]]; then
      source_workflow_path="$source_rules_dir/rules/$workflow_file"
  elif [[ -f "$source_rules_dir/$workflow_file" ]]; then
      source_workflow_path="$source_rules_dir/$workflow_file"
  fi

  # Criar diretório de regras no projeto se não existir
  mkdir -p "$project_rules_dir/rules" || { echo "❌ Erro ao criar diretório '$project_rules_dir/rules'."; return 1; }

  # Copiar todos os arquivos .mdc do diretório de templates (e subdiretório rules, se existir)
  local copied_count=0
  local skipped_count=0
  local target_file=""
  local source_file=""

  # Função auxiliar para copiar e contar
  _copy_mdc_files() {
    local source_dir=$1
    local target_dir=$2
    local find_depth=$3

    # Usar find para iterar sobre os arquivos .mdc
    while IFS= read -r -d $'\0' source_file;
    do
        target_file="$target_dir/$(basename "$source_file")"
        # Verificar se o arquivo de destino já existe e se não estamos forçando
        if [[ -f "$target_file" && "$force_rules" -ne 1 ]]; then
            # echo "   -> Arquivo '$target_file' já existe. Pulando."
            skipped_count=$((skipped_count + 1))
        else
            # Copiar com as opções corretas ( -n ou nada)
            cp $copy_opts "$source_file" "$target_dir/" && copied_count=$((copied_count + 1))
        fi
    done < <(find "$source_dir" -maxdepth "$find_depth" -name '*.mdc' -print0)
  }

  # Tentar copiar da estrutura com subdiretório 'rules'
  if [[ -d "$source_rules_dir/rules" ]]; then
    _copy_mdc_files "$source_rules_dir/rules" "$project_rules_dir/rules" 1
      # find "$source_rules_dir/rules" -maxdepth 1 -name '*.mdc' -exec cp {} "$project_rules_dir/rules/" \; -print &>/dev/null
      # copied_count=$(find "$project_rules_dir/rules" -maxdepth 1 -name '*.mdc' | wc -l)
  fi
  # Tentar copiar da raiz do diretório de templates
  _copy_mdc_files "$source_rules_dir" "$project_rules_dir" 1
  # find "$source_rules_dir" -maxdepth 1 -name '*.mdc' -exec cp {} "$project_rules_dir/" \; -print &>/dev/null

  # Atualizar contagem total (considerando raiz e subdiretório)
  # copied_count=$(find "$project_rules_dir" \( -path "$project_rules_dir/rules/*.mdc" -o -path "$project_rules_dir/*.mdc" \) -type f | wc -l)


  if [[ $copied_count -eq 0 && $skipped_count -eq 0 ]]; then
      echo "⚠️ Nenhum arquivo .mdc encontrado em '$source_rules_dir' ou '$source_rules_dir/rules'. Nenhuma regra copiada."
      # Não retornar erro necessariamente, pode ser intencional não ter regras
  elif [[ $copied_count -gt 0 ]]; then
       echo "✅ $copied_count arquivos .mdc copiados para '$project_rules_dir'."
  fi

  if [[ $skipped_count -gt 0 ]]; then
    echo "ℹ️ $skipped_count arquivos .mdc existentes foram mantidos (não sobrescritos). Use --force-rules para sobrescrever."
  fi

  # Priorizar o arquivo development-workflow.mdc
  if [[ -n "$source_workflow_path" ]]; then # Se o arquivo existe no template
      local target_workflow_path=""
      local target_workflow_dir=""
      # Verificar onde ele existe no projeto (pode ser o original ou o copiado)
      if [[ -f "$project_rules_dir/rules/$workflow_file" ]]; then
          target_workflow_path="$project_rules_dir/rules/$workflow_file"
          target_workflow_dir="$project_rules_dir/rules"
      elif [[ -f "$project_rules_dir/$workflow_file" ]]; then
           target_workflow_path="$project_rules_dir/$workflow_file"
           target_workflow_dir="$project_rules_dir"
      fi

      # Verificar se o arquivo priorizado já existe (caso de execuções anteriores)
      local prioritized_name="000_$workflow_file"
      local existing_prioritized_path=""
       if [[ -f "$project_rules_dir/rules/$prioritized_name" ]]; then
           existing_prioritized_path="$project_rules_dir/rules/$prioritized_name"
       elif [[ -f "$project_rules_dir/$prioritized_name" ]]; then
            existing_prioritized_path="$project_rules_dir/$prioritized_name"
       fi

      # AGORA, a lógica de decisão:
      if [[ -n "$target_workflow_path" ]]; then
          # Encontramos o arquivo com nome normal.
          if [[ "$force_rules" -eq 1 ]]; then
              # Estamos forçando -> Renomear o arquivo que (presumivelmente) acabamos de copiar.
              local prioritized_path="$target_workflow_dir/$prioritized_name"
              # Apenas renomear se o nome for diferente (segurança extra)
              if [[ "$target_workflow_path" != "$prioritized_path" ]]; then
                    mv "$target_workflow_path" "$prioritized_path" && \
                    echo "✨ Arquivo '$workflow_file' priorizado como '$prioritized_name' (forçado/sobrescrito)." || \
                    echo "⚠️ Erro ao tentar priorizar '$workflow_file' após forçar cópia."
              else
                  echo "ℹ️ Arquivo '$workflow_file' forçado já parece estar priorizado."
              fi
          else
              # Não estamos forçando -> Deixar o arquivo existente como está.
              echo "ℹ️ Arquivo '$workflow_file' existente mantido em '$target_workflow_path' (não forçado). Nenhuma priorização realizada."
          fi
      elif [[ -n "$existing_prioritized_path" ]]; then
          # Não encontramos o arquivo com nome normal, mas o priorizado já existe.
          echo "ℹ️ Arquivo '$workflow_file' já parece estar priorizado em '$existing_prioritized_path'."
      else
           # Não encontramos o arquivo de workflow no destino, nem normal nem priorizado.
           # Isso pode ocorrer se o arquivo de template existe, mas não foi copiado
           # (porque --force não foi usado e ele não existia antes), ou erro na cópia.
           echo "⚠️ Arquivo '$workflow_file' definido no template ('$source_workflow_path') mas não encontrado no destino após tentativa de cópia."
      fi
  else
      # Caso original: workflow não encontrado no template
      echo "ℹ️ Arquivo '$workflow_file' não encontrado nos templates. Nenhuma priorização necessária."
  fi

}

# Configuração do Next.js com Tailwind CSS
setup_nextjs() {
  local dir_name=$1
  echo "🚀 Clonando template Next.js pré-configurado para '$dir_name'...'"

  # Clonar o repositório template diretamente no diretório especificado
  git clone "$_ZUYA_NEXTJS_TEMPLATE_URL" "$dir_name" || { echo "❌ Falha ao clonar o template Next.js de '$_ZUYA_NEXTJS_TEMPLATE_URL'."; return 1; }

  # Entrar no diretório (necessário para próximas etapas como rm .git e npm install)
  cd "$dir_name" || { echo "❌ Falha ao entrar no diretório '$dir_name' após clonagem."; return 1; }

  # Remover histórico Git do template
  echo "🧹 Removendo histórico Git do template..."
  rm -rf .git || { echo "⚠️ Falha ao remover o diretório .git do template (pode não existir ou erro de permissão)."; }

  # A instalação (ZUYA-18.5) virá na próxima subtarefa

  echo "✅ Template Next.js clonado e limpo com sucesso em '$dir_name'."
  cd .. # Voltar para o diretório raiz do projeto para manter consistência
  return 0 # Indicar sucesso
}

# Configuração do NestJS
setup_nestjs() {
  local dir_name=$1
  echo "🚀 Configurando NestJS em '$dir_name'..."

  # Criar projeto NestJS (adicionar --yes e @latest)
  npx --yes @nestjs/cli@latest new "$dir_name" --package-manager npm --strict --skip-git || { echo "❌ Falha ao criar projeto NestJS."; return 1; } # --skip-git porque já inicializamos

  cd "$dir_name" || { echo "❌ Falha ao entrar no diretório '$dir_name'."; return 1; }

  # Configurar ESLint avançado (sobrescrever o padrão do NestJS se necessário)
  echo "📝 Configurando ESLint..."
  cat > .eslintrc.js << 'EOL'
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin'],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended', // Garante integração com Prettier
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js'],
  rules: {
    '@typescript-eslint/interface-name-prefix': 'off',
    '@typescript-eslint/explicit-function-return-type': 'warn', // Manter como warn pode ser útil
    '@typescript-eslint/explicit-module-boundary-types': 'warn', // Manter como warn pode ser útil
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { 'argsIgnorePattern': '^_' }], // Avisar sobre não usados
    'prettier/prettier': ['warn', {}, { usePrettierrc: true }] // Avisar sobre regras do prettier
  },
};
EOL

  # (Opcional) Instalar dependências adicionais comuns, ex: config, class-validator, class-transformer
  # echo "📦 Instalando dependências comuns do NestJS..."
  # npm install @nestjs/config class-validator class-transformer

  echo "✅ Configuração do NestJS concluída."
  cd .. # Voltar para o diretório raiz do projeto
  return 0 # Indicar sucesso
}

# --- Funções Auxiliares para setup_express ---

_setup_express_init() {
  echo "   -> Inicializando diretório e package.json..."
  npm init -y -q || return 1
}

_setup_express_install_deps() {
  echo "   📦 Instalando dependências de runtime (Express, cors, dotenv, zod)..."
  # Adicionando zod aqui!
  npm install express cors dotenv zod || return 1
}

_setup_express_install_dev_deps() {
  echo "   📦 Instalando dependências de desenvolvimento..."
  npm install --save-dev typescript ts-node nodemon @types/express @types/cors @types/node jest ts-jest @types/jest eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin prettier eslint-config-prettier eslint-plugin-prettier || return 1
}

_setup_express_configure_ts() {
  echo "   📝 Configurando TypeScript (tsconfig.json)..."
  cat > tsconfig.json << 'EOL'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "sourceMap": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts", "dist"]
}
EOL
  return 0 # Indicar sucesso (cat não retorna status útil diretamente)
}

_setup_express_configure_eslint() {
  echo "   📝 Configurando ESLint (.eslintrc.js)..."
  cat > .eslintrc.js << 'EOL'
module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: 'tsconfig.json',
    tsconfigRootDir: __dirname,
    sourceType: 'module',
  },
  plugins: ['@typescript-eslint/eslint-plugin', 'prettier'],
  extends: [
    'plugin:@typescript-eslint/recommended',
    'plugin:prettier/recommended',
  ],
  root: true,
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['.eslintrc.js', 'dist/'],
  rules: {
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { 'argsIgnorePattern': '^' }],
    'prettier/prettier': 'warn',
  },
};
EOL
  return 0
}

_setup_express_configure_prettier() {
  echo "   💅 Configurando Prettier (.prettierrc, .prettierignore)..."
  cat > .prettierrc << 'EOL'
{
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true
}
EOL

  cat > .prettierignore << 'EOL'
node_modules
dist
coverage
.env
*.log
EOL
  return 0
}

_setup_express_configure_jest() {
  echo "   🛠️  Configurando Jest (jest.config.js)..."
  cat > jest.config.js << 'EOL'
/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.+(ts|tsx|js)', '**/?(*.)+(spec|test).+(ts|tsx|js)'],
  transform: {
    '^.+\\.(ts|tsx)$': ['ts-jest', { 
      tsconfig: 'tsconfig.json'
    }]
  },
  moduleNameMapper: { 
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  collectCoverage: true,
  coverageDirectory: "coverage", 
  coverageProvider: "v8",
};
EOL
  return 0
}

_setup_express_create_structure() {
  echo "   📁 Criando estrutura de diretórios em src/..."
  mkdir -p src/{controllers,routes,services,models,middleware,utils,config,tests,schemas} # Adicionado schemas para Zod
}

_setup_express_create_main_file() {
  echo "   📄 Criando arquivo principal (src/index.ts)..."
  cat > src/index.ts << 'EOL'
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
// import { ZodError } from 'zod'; // Descomente se usar middleware de erro Zod

// Carregar variáveis de ambiente do .env
dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors()); 
app.use(express.json()); 
app.use(express.urlencoded({ extended: true })); 

// Rota de exemplo
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({ message: 'API funcionando com ZuYa! Pronto para usar Zod!' }); // Adicionado Zod na msg
});

// TODO: Importar e usar suas rotas aqui
// Exemplo: import userRoutes from './routes/userRoutes';
// app.use('/api/users', userRoutes);

// TODO: Considerar um middleware global para tratamento de erros (incluindo ZodError)
/*
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof ZodError) {
    return res.status(400).json({
      message: 'Erro de validação',
      errors: err.errors,
    });
  }
  console.error(err.stack);
  res.status(500).json({ message: 'Erro interno do servidor' });
});
*/

// Tratamento básico de erro 404 (deve vir depois das rotas e antes do error handler global)
app.use((req: Request, res: Response) => {
  res.status(404).json({ message: 'Rota não encontrada' });
});

// Iniciar servidor apenas se não estiver no ambiente de teste
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Servidor Express rodando na porta ${PORT}`);
    console.log(`   Ambiente: ${process.env.NODE_ENV || 'development'}`);
  });
}

// Exportar app para testes
export default app;
EOL
  return 0
}

_setup_express_create_env_example() {
   echo "   📄 Criando arquivo .env.example..."
   cat > .env.example << 'EOL'
# Variáveis de Ambiente - Exemplo
# Renomeie este arquivo para .env e preencha com seus valores

# Configurações do Servidor
PORT=3001
NODE_ENV=development # development, production, test

# Configurações de Banco de Dados (exemplo)
# DB_HOST=localhost
# DB_PORT=5432
# DB_USER=user
# DB_PASSWORD=secret
# DB_NAME=mydatabase

# Outras configurações (chaves de API, etc)
# API_KEY=your_api_key
EOL
   return 0
}

_setup_express_update_gitignore() {
  echo "   🔒 Adicionando entradas ao .gitignore..."
  # Criar se não existir, ou adicionar ao existente
  echo "" >> .gitignore 
  echo "# Arquivos de ambiente" >> .gitignore
  echo ".env" >> .gitignore
  echo ".env.*" >> .gitignore
  echo "!.env.example" >> .gitignore 
  echo "" >> .gitignore
  echo "# Logs" >> .gitignore
  echo "*.log" >> .gitignore
  echo "" >> .gitignore
  echo "# Arquivos de build" >> .gitignore
  echo "dist/" >> .gitignore
  echo "" >> .gitignore
  echo "# Cobertura de testes" >> .gitignore
  echo "coverage/" >> .gitignore
  return 0
}

_setup_express_add_npm_scripts() {
  echo "   📜 Adicionando scripts ao package.json..."
  npm pkg set scripts.dev="nodemon" > /dev/null
  npm pkg set scripts.build="tsc" > /dev/null
  npm pkg set scripts.start="node dist/index.js" > /dev/null
  npm pkg set scripts.test="jest" > /dev/null
  npm pkg set scripts.test:watch="jest --watch" > /dev/null
  npm pkg set scripts.lint="eslint . --ext .ts" > /dev/null
  npm pkg set scripts.lint:fix="eslint . --ext .ts --fix" > /dev/null
  npm pkg set scripts.format="prettier --write \"src/**/*.ts\"" > /dev/null
  return 0 # npm pkg não retorna status útil, assumir sucesso se não houver erro visível
}

_setup_express_configure_nodemon() {
  echo "   ⚙️  Configurando nodemon (nodemon.json)..."
  cat > nodemon.json << 'EOL'
{
  "watch": ["src"],
  "ext": "ts,json",
  "ignore": ["src/**/*.spec.ts", "src/**/*.test.ts"],
  "exec": "ts-node ./src/index.ts"
}
EOL
  return 0
}

# --- Fim das Funções Auxiliares para setup_express ---

# Configuração do Express (Refatorada)
setup_express() {
  local dir_name=$1
  echo "🚀 Configurando Express em '$dir_name'..."

  mkdir -p "$dir_name" || { echo "❌ Falha ao criar diretório '$dir_name'."; return 1; }
  cd "$dir_name" || { echo "❌ Falha ao entrar no diretório '$dir_name'."; return 1; }

  # Chamar funções auxiliares em sequência
  _setup_express_init || { echo "❌ Falha na inicialização do Express."; cd ..; return 1; }
  _setup_express_install_deps || { echo "❌ Falha ao instalar dependências de runtime."; cd ..; return 1; }
  _setup_express_install_dev_deps || { echo "❌ Falha ao instalar dependências dev."; cd ..; return 1; }
  _setup_express_configure_ts || { echo "❌ Falha ao configurar TypeScript."; cd ..; return 1; }
  _setup_express_configure_eslint || { echo "❌ Falha ao configurar ESLint."; cd ..; return 1; }
  _setup_express_configure_prettier || { echo "❌ Falha ao configurar Prettier."; cd ..; return 1; }
  _setup_express_configure_jest || { echo "❌ Falha ao configurar Jest."; cd ..; return 1; }
  _setup_express_create_structure || { echo "❌ Falha ao criar estrutura de diretórios."; cd ..; return 1; }
  _setup_express_create_main_file || { echo "❌ Falha ao criar arquivo principal."; cd ..; return 1; }
  _setup_express_create_env_example || { echo "❌ Falha ao criar .env.example."; cd ..; return 1; }
  _setup_express_update_gitignore || { echo "❌ Falha ao atualizar .gitignore."; cd ..; return 1; }
  _setup_express_add_npm_scripts || { echo "❌ Falha ao adicionar scripts npm."; cd ..; return 1; }
  _setup_express_configure_nodemon || { echo "❌ Falha ao configurar nodemon."; cd ..; return 1; }

  echo "✅ Configuração do Express concluída."
  cd .. # Voltar para o diretório raiz do projeto
  return 0 # Indicar sucesso
}

# Função de ajuda
zuya_help() {
  echo "🧙‍♂️ ZuYa - Seu assistente mágico para desenvolvimento fullstack TypeScript"
  echo ""
  echo "Uso:"
  echo "  zuya create <nome-projeto> [template] [--db <tipo-db>]"
  echo "  zuya copy-rules"
  echo "  zuya help"
  echo ""
  echo "Templates disponíveis:"
  echo "  next-nest    - Next.js + NestJS (padrão)"
  echo "  next-express - Next.js + Express"
}

# Função interativa para configurar banco de dados
setup_database() {
  echo "🚧 Configuração de Banco de Dados"
  echo "Você precisa de um banco de dados para este projeto? (s/n)"
  read -r need_db
  
  if [[ "$need_db" =~ ^[Ss]$ ]]; then
    echo "Selecione o tipo de banco de dados:"
    echo "1) Relacional"
    echo "2) Não Relacional"
    read -r db_type
    
    case "$db_type" in
      1)
        echo "Opções de bancos de dados relacionais:"
        echo "1) PostgreSQL"
        echo "2) MySQL"
        echo "3) SQLite"
        read -r relational_choice
        
        case "$relational_choice" in
          1) setup_postgresql ;;
          2) setup_mysql ;;
          3) setup_sqlite ;;
          *) echo "Opção inválida. Nenhum banco de dados configurado." ;;
        esac
        ;;
      2)
        echo "Opções de bancos de dados não relacionais:"
        echo "1) MongoDB"
        echo "2) Redis"
        echo "3) Cassandra"
        read -r non_relational_choice
        
        case "$non_relational_choice" in
          1) setup_mongodb ;;
          2) setup_redis ;;
          3) setup_cassandra ;;
          *) echo "Opção inválida. Nenhum banco de dados configurado." ;;
        esac
        ;;
      *)
        echo "Opção inválida. Nenhum banco de dados configurado."
        ;;
    esac
  else
    echo "Nenhum banco de dados será configurado."
  fi
}

# Funções de configuração para cada banco de dados (Placeholders)
setup_postgresql() {
  echo "🚧 Configurando PostgreSQL..."
  local backend_dir="backend" # Assumindo que o backend está sempre em 'backend'
  local docker_compose_file="docker-compose.yml"
  local env_example_file="$backend_dir/.env.example"

  if [[ ! -d "$backend_dir" ]]; then
    echo "❌ Erro: Diretório backend '$backend_dir' não encontrado. Impossível configurar o banco de dados."
    return 1
  fi

  # --- Instalar Dependências ---
  echo "📦 Instalando dependências do PostgreSQL e TypeORM..."
  cd "$backend_dir" || { echo "❌ Erro ao entrar no diretório '$backend_dir'."; return 1; }

  # Verificar se é NestJS (presença de @nestjs/core) ou Express
  if npm list --depth=0 | grep -q '@nestjs/core'; then
    echo "   Detectado backend NestJS. Instalando @nestjs/typeorm, typeorm, pg..."
    npm install --save @nestjs/typeorm typeorm pg || { echo "❌ Falha ao instalar dependências do NestJS/TypeORM."; cd ..; return 1; }
    # TODO: Adicionar configuração do TypeOrmModule no app.module.ts (requer manipulação de arquivo mais complexa)
    echo "⚠️ Lembre-se de importar e configurar TypeOrmModule.forRootAsync(...) no seu AppModule no NestJS!"
  elif [[ -f "src/index.ts" ]]; then # Verificar se é o setup do Express que criamos
    echo "   Detectado backend Express. Instalando typeorm, pg, reflect-metadata..."
    # reflect-metadata é necessário para TypeORM com TS
    npm install --save typeorm pg reflect-metadata || { echo "❌ Falha ao instalar dependências do Express/TypeORM."; cd ..; return 1; }
     # Adicionar import do reflect-metadata no início do src/index.ts
    echo "   Adicionando 'import \"reflect-metadata\";' ao src/index.ts..."
    # Usar sed para adicionar no início do arquivo (pode ser frágil)
    # Criar backup antes de modificar
    # cp src/index.ts src/index.ts.bak
    # sed -i '1s/^/import "reflect-metadata";\n/' src/index.ts || echo "⚠️ Falha ao adicionar import \"reflect-metadata\" automaticamente."
    # Nota: Edição direta de código com sed é propensa a erros. Uma abordagem mais segura seria usar uma ferramenta de AST ou template.
    # Por ora, vamos apenas avisar o usuário.
     echo "⚠️ Importante: Adicione 'import \"reflect-metadata\";' no topo do seu arquivo principal (ex: src/index.ts) para usar TypeORM com Express."
    # TODO: Adicionar lógica de inicialização da conexão TypeORM no Express (requer edição de index.ts)
     echo "⚠️ Lembre-se de configurar e inicializar a conexão do TypeORM no seu código Express!"
  else
    echo "⚠️ Tipo de backend não reconhecido em '$backend_dir'. Instalando apenas 'pg' e 'typeorm'."
    npm install --save typeorm pg || { echo "❌ Falha ao instalar dependências genéricas do TypeORM."; cd ..; return 1; }
  fi

  # --- Atualizar .env.example ---
  echo "📝 Atualizando $env_example_file..."
  # Estando dentro do diretório backend, precisamos verificar o arquivo localmente
  local local_env_example=".env.example"
  if [[ -f "$local_env_example" ]]; then
    echo "" >> "$local_env_example" # Linha em branco
    echo "# PostgreSQL Configuration (TypeORM)" >> "$local_env_example"
    echo "DB_TYPE=postgres" >> "$local_env_example"
    echo "DB_HOST=localhost" >> "$local_env_example"
    echo "DB_PORT=5432" >> "$local_env_example"
    echo "DB_USERNAME=admin" >> "$local_env_example" # Usuário padrão do docker-compose
    echo "DB_PASSWORD=admin" >> "$local_env_example" # Senha padrão do docker-compose
    echo "DB_DATABASE=mydatabase" >> "$local_env_example" # DB padrão do docker-compose
    echo "DB_SYNCHRONIZE=true" >> "$local_env_example" # true para desenvolvimento (cria tabelas), false para produção
    echo "DB_LOGGING=true" >> "$local_env_example" # true para ver SQLs gerados
  else
    # Usar o caminho original na mensagem de erro para clareza
    echo "⚠️ Arquivo '$env_example_file' não encontrado (verificado como '$local_env_example' no diretório atual). Pulei a atualização."
  fi

  cd .. # Voltar para a raiz do projeto

  # --- Criar docker-compose.yml ---
  echo "🐳 Gerando $docker_compose_file básico para PostgreSQL..."
  if [[ -f "$docker_compose_file" ]]; then
    echo "⚠️ Arquivo '$docker_compose_file' já existe. Não vou sobrescrever."
  else
    cat > "$docker_compose_file" << EOL
version: '3.8'

services:
  postgres:
    image: postgres:15 # Use uma versão específica
    container_name: postgres_db
    environment:
      POSTGRES_USER: admin # Deve corresponder ao .env
      POSTGRES_PASSWORD: admin # Deve corresponder ao .env
      POSTGRES_DB: mydatabase # Deve corresponder ao .env
      PGDATA: /var/lib/postgresql/data/pgdata # Diretório de dados dentro do container
    ports:
      - "5432:5432" # Mapeia a porta do host para o container
    volumes:
      - postgres_data:/var/lib/postgresql/data/pgdata # Volume persistente
    restart: unless-stopped

volumes:
  postgres_data: # Define o volume nomeado

EOL
    echo "✅ $docker_compose_file criado. Use 'docker compose up -d' para iniciar."
  fi

  echo "✅ Configuração básica do PostgreSQL concluída."
  echo "ℹ️ Lembre-se de:"
  echo "   - Renomear '.env.example' para '.env' no backend e preencher os valores."
  echo "   - Integrar a configuração do TypeORM no código do seu backend (AppModule no NestJS ou inicialização no Express)."
  echo "   - Executar 'docker compose up -d' (na raiz do projeto) para iniciar o container do PostgreSQL."
}

setup_mysql() {
  echo "🚧 Configurando MySQL (placeholder)..."
  echo "   Adicione aqui a lógica para instalar dependências (mysql2), configurar .env, etc."
   # Exemplo: npm install mysql2 @nestjs/typeorm typeorm
}

setup_sqlite() {
  echo "🚧 Configurando SQLite (placeholder)..."
  echo "   Adicione aqui a lógica para instalar dependências (sqlite3), configurar .env, etc."
   # Exemplo: npm install sqlite3 @nestjs/typeorm typeorm
}

setup_mongodb() {
  echo "🚧 Configurando MongoDB (placeholder)..."
  echo "   Adicione aqui a lógica para instalar dependências (mongoose, @nestjs/mongoose), configurar .env, etc."
  # Exemplo: npm install mongoose @nestjs/mongoose
}

setup_redis() {
  echo "🚧 Configurando Redis (placeholder)..."
  echo "   Adicione aqui a lógica para instalar dependências (ioredis), configurar .env, etc."
  # Exemplo: npm install ioredis
}

setup_cassandra() {
  echo "🚧 Configurando Cassandra (placeholder)..."
  echo "   Adicione aqui a lógica para instalar dependências (cassandra-driver), configurar .env, etc."
  # Exemplo: npm install cassandra-driver
}

# Exportar apenas a função principal para o ambiente Zsh
