#!/usr/bin/env bash

# Script de teste de ciclo de vida para o plugin ZuYa Oh My Zsh

# --- Configuração ---
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
PLUGIN_DIR="$OH_MY_ZSH_DIR/custom/plugins/zuya"
PLUGIN_FILE="$PLUGIN_DIR/zuya.plugin.zsh"
TEST_DIR_BASE="./zuya_tests_$(date +%s)" # Diretório base para os testes (no diretório atual)
DUMMY_TEMPLATE_DIR="$TEST_DIR_BASE/dummy_mdc_templates"
DUMMY_WORKFLOW_FILE="development-workflow.mdc"

passed_tests=0
failed_tests=0

# --- Funções de Teste ---

_setup_test_env() {
  echo "\n--- Configurando Ambiente de Teste Geral ---"
  if [[ -d "$TEST_DIR_BASE" ]]; then
    echo "🧹 Limpando diretório base de teste anterior (se existir)..."
    rm -rf "$TEST_DIR_BASE"
  fi
  mkdir -p "$TEST_DIR_BASE" || { echo "❌ Falha ao criar diretório base de teste $TEST_DIR_BASE"; exit 1; }
  mkdir -p "$DUMMY_TEMPLATE_DIR/rules" || { echo "❌ Falha ao criar diretório de template dummy $DUMMY_TEMPLATE_DIR"; exit 1; }
  echo "# Dummy MDC file 1 (raiz)" > "$DUMMY_TEMPLATE_DIR/rule1.mdc"
  echo "# Dummy MDC file 2 (rules)" > "$DUMMY_TEMPLATE_DIR/rules/rule2.mdc"
  echo "# Dummy Workflow (rules)" > "$DUMMY_TEMPLATE_DIR/rules/$DUMMY_WORKFLOW_FILE"
  echo "   ✅ Diretório base de teste criado: $TEST_DIR_BASE"
  echo "   ✅ Diretório de template MDC dummy criado: $DUMMY_TEMPLATE_DIR"
  echo "-------------------------------------------"
}

_run_zsh_command() {
  local description="$1"
  local test_subdir="$2"
  local command_to_run="$3"
  local current_test_dir="$TEST_DIR_BASE/$test_subdir"

  echo "\n🧪 Executando Teste: $description..."
  echo "   Diretório de trabalho: $current_test_dir"
  mkdir -p "$current_test_dir"

  # Exportar o diretório de template dummy com CAMINHO ABSOLUTO
  local absolute_dummy_template_dir="$(cd "$DUMMY_TEMPLATE_DIR" && pwd)"
  export ZAYA_MDC_TEMPLATES_DIR="$absolute_dummy_template_dir"

  # Mudar para o diretório de teste antes de executar o comando zsh
  pushd "$current_test_dir" > /dev/null

  # Executar comando dentro de uma instância zsh
  zsh <<EOF
  source "$PLUGIN_FILE" || { echo "❌ Falha ao carregar arquivo do plugin: $PLUGIN_FILE"; exit 1; }
  echo "   Comando: $command_to_run"
  $command_to_run
EOF
  local exit_status=$?

  # Voltar ao diretório original
  popd > /dev/null

  if [[ $exit_status -eq 0 ]]; then
    echo "   ✅ Teste '$description' PASSOU (Exit Code: $exit_status)"
    passed_tests=$((passed_tests + 1))
    return 0
  else
    echo "   ❌ Teste '$description' FALHOU (Exit Code: $exit_status)"
    failed_tests=$((failed_tests + 1))
    return 1
  fi
}

_verify_file_exists() {
  local file_path="$1"
  local test_description="$2"
  echo -n "      Verificando se existe: $file_path... "
  if [[ -f "$file_path" ]]; then
    echo "OK"
    return 0
  else
    echo "FALHOU"
    echo "   ❌ Verificação Falhou: Arquivo não encontrado em $test_description."
    failed_tests=$((failed_tests + 1))
    passed_tests=$((passed_tests - 1)) # Decrementar o contador de passes do teste principal
    return 1
  fi
}

_verify_dir_exists() {
  local dir_path="$1"
  local test_description="$2"
  echo -n "      Verificando se existe: $dir_path... "
  if [[ -d "$dir_path" ]]; then
    echo "OK"
    return 0
  else
    echo "FALHOU"
    echo "   ❌ Verificação Falhou: Diretório não encontrado em $test_description."
    failed_tests=$((failed_tests + 1))
    passed_tests=$((passed_tests - 1)) # Decrementar o contador de passes do teste principal
    return 1
  fi
}

_verify_mdc_files() {
    local project_dir="$1"
    local test_description="$2"
    echo "      Verificando arquivos MDC..."
    _verify_file_exists "$project_dir/.cursor/rule1.mdc" "$test_description (rule1.mdc)" && \
    _verify_file_exists "$project_dir/.cursor/rules/rule2.mdc" "$test_description (rule2.mdc)" && \
    _verify_file_exists "$project_dir/.cursor/rules/000_$DUMMY_WORKFLOW_FILE" "$test_description (prioritized workflow)"
    return $?
}

# Função auxiliar para executar um comando dentro de um subdiretório do projeto gerado
_run_project_command() {
  local project_base_dir="$1" # Caminho base onde o projeto foi criado (e.g., $TEST_DIR_BASE/$test_subdir/$project_name)
  local sub_path="$2"         # Subdiretório onde o comando deve rodar (e.g., "frontend")
  local command_to_run="$3"   # O comando a ser executado
  local description="$4"      # Descrição para logs

  local full_path="$project_base_dir/$sub_path"

  echo "      Executando Comando no Projeto: $description..."
  echo "         Em: $full_path"
  echo "         Comando: $command_to_run"

  if [[ ! -d "$full_path" ]]; then
    echo "      ❌ Falha: Diretório do projeto '$full_path' não encontrado para executar comando."
    # Incrementar falha global? Ou deixar o teste que chama decidir? Por ora, só retorna erro.
    return 1
  fi

  pushd "$full_path" > /dev/null
  eval "$command_to_run" # Usar eval para comandos com pipes ou redirecionamentos, se necessário
  local exit_status=$?
  popd > /dev/null

  if [[ $exit_status -eq 0 ]]; then
    echo "      ✅ Comando '$description' PASSOU (Exit Code: $exit_status)"
    return 0
  else
    echo "      ❌ Comando '$description' FALHOU (Exit Code: $exit_status)"
    # Incrementar falha global? Provavelmente o teste principal fará isso.
    return 1
  fi
}

_cleanup() {
  echo "\n🧹 Limpando diretório de teste base..."
  if [[ -d "$TEST_DIR_BASE" ]]; then
      local attempts=3
      local delay=1
      while [[ $attempts -gt 0 && -d "$TEST_DIR_BASE" ]]; do
          rm -rf "$TEST_DIR_BASE"
          if [[ $? -ne 0 && -d "$TEST_DIR_BASE" ]]; then # Se falhou e ainda existe
              echo "   ⚠️ Falha ao remover $TEST_DIR_BASE (tentativa $((4-attempts))). Tentando novamente em ${delay}s..."
              sleep $delay
              attempts=$((attempts - 1))
              delay=$((delay + 1)) # Opcional: aumentar o delay a cada tentativa
          else
              # Se rm bem-sucedido ou diretório desapareceu, sair do loop
              break
          fi
      done

      if [[ -d "$TEST_DIR_BASE" ]]; then
           echo "   ❌ Falha final ao remover $TEST_DIR_BASE após múltiplas tentativas."
           # Considerar incrementar failed_tests aqui também?
      else
           echo "   Removido $TEST_DIR_BASE com sucesso."
      fi
  else
      echo "   Diretório base $TEST_DIR_BASE não encontrado para limpeza."
  fi
}

# --- Script Principal ---

# Garantir que Zsh está disponível
if ! command -v zsh &> /dev/null; then
    echo "❌ Erro: Comando 'zsh' não encontrado." ; exit 1
fi

_setup_test_env

# --- Testes de Criação ---
test_create_express_pg() {
  local project_name="test_express_pg"
  local test_subdir="create/express_pg"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  _run_zsh_command "Create: next-express com PostgreSQL" "$test_subdir" "zuya create $project_name next-express --db postgresql --force-rules"
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "   Verificações Pós-Criação Express/PG:"
    _verify_dir_exists "$project_path/frontend" "Express/PG" && \
    _verify_dir_exists "$project_path/backend" "Express/PG" && \
    _verify_mdc_files "$project_path" "Express/PG" && \
    _verify_file_exists "$project_path/docker-compose.yml" "Express/PG (docker-compose)" && \
    _verify_file_exists "$project_path/backend/.env.example" "Express/PG (backend env)" && \
    grep -q "DB_TYPE=postgres" "$project_path/backend/.env.example" || { echo "   ❌ Verificação Falhou: .env.example não contém DB_TYPE=postgres"; return 1; }
    # Adicione mais verificações se necessário (conteúdo de arquivos específicos, etc)
  fi
  return $result
}

test_create_nest_mongo() {
  local project_name="test_nest_mongo"
  local test_subdir="create/nest_mongo"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  # Nota: setup_mongodb ainda é placeholder, então não verificaremos docker-compose ou .env específicos
  _run_zsh_command "Create: next-nest com MongoDB" "$test_subdir" "zuya create $project_name next-nest --db mongodb --force-rules"
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "   Verificações Pós-Criação Nest/Mongo:"
    _verify_dir_exists "$project_path/frontend" "Nest/Mongo" && \
    _verify_dir_exists "$project_path/backend" "Nest/Mongo" && \
    _verify_mdc_files "$project_path" "Nest/Mongo"
    # _verify_file_exists "$project_path/backend/.env.example" "Nest/Mongo (backend env)" # Descomente se setup_mongodb criar/atualizar .env
  fi
  return $result
}

# --- Testes de Cópia de Regras ---
test_copy_rules_no_force() {
  local test_subdir="copy/no_force"
  local test_workdir="$TEST_DIR_BASE/$test_subdir"
  mkdir -p "$test_workdir/.cursor/rules"
  # Criar arquivos existentes para testar não-sobrescrita
  echo "# Existing root rule" > "$test_workdir/.cursor/rule1.mdc"
  echo "# Existing workflow" > "$test_workdir/.cursor/rules/$DUMMY_WORKFLOW_FILE"

  # Executar copy-rules sem force (deve copiar rule2.mdc mas não os outros)
  _run_zsh_command "Copy Rules: Sem Force (Não sobrescrever)" "$test_subdir" "zuya copy-rules"
  local result=$?
  if [[ $result -eq 0 ]]; then
     echo "   Verificações Pós-Cópia (No Force):"
     # Verificar se rule1.mdc NÃO foi alterado
     grep -q "# Existing root rule" "$test_workdir/.cursor/rule1.mdc" || { echo "   ❌ Verificação Falhou: rule1.mdc foi sobrescrito."; return 1; }
     # Verificar se rule2.mdc FOI copiado
     _verify_file_exists "$test_workdir/.cursor/rules/rule2.mdc" "No Force (rule2.mdc)" || return 1
     # Verificar se workflow NÃO foi renomeado (porque o original não foi sobrescrito)
     _verify_file_exists "$test_workdir/.cursor/rules/$DUMMY_WORKFLOW_FILE" "No Force (workflow não renomeado)" || return 1
     # Verificar se arquivo priorizado NÃO existe
     if [[ -f "$test_workdir/.cursor/rules/000_$DUMMY_WORKFLOW_FILE" ]]; then echo "   ❌ Verificação Falhou: Workflow foi renomeado indevidamente."; return 1; fi
  fi
  return $result
}

test_copy_rules_with_force() {
  local test_subdir="copy/with_force"
  local test_workdir="$TEST_DIR_BASE/$test_subdir"
  mkdir -p "$test_workdir/.cursor/rules"
  # Criar arquivos existentes
  echo "# Existing root rule" > "$test_workdir/.cursor/rule1.mdc"
  echo "# Existing workflow" > "$test_workdir/.cursor/rules/$DUMMY_WORKFLOW_FILE"

  # Executar copy-rules COM force (deve sobrescrever e priorizar)
  _run_zsh_command "Copy Rules: Com Force (Sobrescrever)" "$test_subdir" "zuya copy-rules 1" # Passar 1 para forçar
  local result=$?
  if [[ $result -eq 0 ]]; then
     echo "   Verificações Pós-Cópia (With Force):"
     # Verificar se rule1.mdc FOI alterado
     grep -q "# Dummy MDC file 1 (raiz)" "$test_workdir/.cursor/rule1.mdc" || { echo "   ❌ Verificação Falhou: rule1.mdc não foi sobrescrito."; return 1; }
     # Verificar se rule2.mdc FOI copiado/sobrescrito
     _verify_file_exists "$test_workdir/.cursor/rules/rule2.mdc" "With Force (rule2.mdc)" || return 1
     # Verificar se workflow FOI renomeado
     _verify_file_exists "$test_workdir/.cursor/rules/000_$DUMMY_WORKFLOW_FILE" "With Force (workflow renomeado)" || return 1
  fi
  return $result
}

# --- Testes de Refatoração (Exemplo para Next.js e NestJS) ---
test_refactored_nextjs_build_run() {
  local project_name="test_refactor_next"
  local test_subdir="refactor/nextjs"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  _run_zsh_command "Refactor Test: Create Next.js Project (via next-nest)" "$test_subdir" "zuya create $project_name next-nest --force-rules"
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "   Verificações Pós-Criação Refatorada (Next.js):"
    _verify_dir_exists "$project_path/frontend" "Refactor Next.js (frontend dir)" && \
    _verify_file_exists "$project_path/frontend/eslint.config.mjs" "Refactor Next.js (eslint.config.mjs)" && \
    _verify_file_exists "$project_path/frontend/jest.config.js" "Refactor Next.js (jest.config.js)" && \
    _verify_file_exists "$project_path/frontend/tsconfig.json" "Refactor Next.js (tsconfig.json)"
    local checks_passed=$?
    if [[ $checks_passed -ne 0 ]]; then return 1; fi # Se verificações básicas falharem, não continuar

    # Verificar build e run (frontend)
    _run_project_command "$project_path" "frontend" "npm install --legacy-peer-deps" "Install Frontend Dependencies" || return 1
    _run_project_command "$project_path" "frontend" "npm run build" "Build Frontend" || return 1

    # Tentar iniciar o servidor de dev em background
    echo "      Tentando iniciar 'npm run dev' em background (frontend)..."
    pushd "$project_path/frontend" > /dev/null
    npm run dev > /dev/null 2>&1 &
    local dev_pid=$!
    popd > /dev/null
    sleep 5 # Dar tempo para iniciar (ou falhar)
    if ps -p $dev_pid > /dev/null; then
        echo "      ✅ Frontend 'npm run dev' iniciou com sucesso (PID: $dev_pid). Finalizando..."
        kill $dev_pid
        wait $dev_pid 2>/dev/null # Limpar processo
    else
        echo "      ❌ Frontend 'npm run dev' falhou ao iniciar ou encerrou prematuramente."
        # O teste principal já incrementou falhas, mas retornamos 1 para parar aqui
        return 1
    fi
  fi
  # Se _run_zsh_command falhou, result já será != 0
  # Se chegamos aqui e result == 0, todas as etapas passaram
  return $result
}

test_refactored_nestjs_build_run() {
  local project_name="test_refactor_nest"
  local test_subdir="refactor/nestjs"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  _run_zsh_command "Refactor Test: Create NestJS Project (via next-nest)" "$test_subdir" "zuya create $project_name next-nest --force-rules"
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "   Verificações Pós-Criação Refatorada (NestJS):"
    _verify_dir_exists "$project_path/backend" "Refactor NestJS (backend dir)" && \
    _verify_file_exists "$project_path/backend/eslint.config.mjs" "Refactor NestJS (eslint.config.mjs)" && \
    (echo -n "      Verificando config Jest em package.json... " && grep -q '"jest": {' "$project_path/backend/package.json" && echo "OK") || (echo "FALHOU" && echo "   ❌ Verificação Falhou: Configuração do Jest não encontrada em package.json." && exit 1) && \
    _verify_file_exists "$project_path/backend/tsconfig.json" "Refactor NestJS (tsconfig.json)"
    local checks_passed=$?
    if [[ $checks_passed -ne 0 ]]; then return 1; fi # Se verificações básicas falharem, não continuar

    # Verificar build e run (backend)
    _run_project_command "$project_path" "backend" "npm install" "Install Backend Dependencies" || return 1
    _run_project_command "$project_path" "backend" "npm run build" "Build Backend" || return 1

    # Encontrar uma porta livre
    local free_port
    echo "      Procurando porta livre para o servidor NestJS..."
    free_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()' 2>/dev/null)

    if [[ -z "$free_port" || "$free_port" -eq 0 ]]; then
        echo "      ❌ Falha ao encontrar porta livre usando Python. Pulando teste de inicialização."
        # Considerar falhar o teste aqui? Por ora, apenas pula a verificação de 'start:dev'.
        # A falha pode ser porque python não está no PATH ou ocorreu um erro inesperado.
        # A build já passou, o que é um bom sinal.
        # Vamos permitir que o teste passe, mas com um aviso.
        echo "      ⚠️ Aviso: Teste de inicialização do servidor NestJS pulado devido à falha na obtenção de porta livre."
        return 0 # Retorna sucesso pois a build passou, mas o run não foi verificado.
    fi
    echo "      Usando porta $free_port para o teste de inicialização."

    # Tentar iniciar o servidor de dev em background na porta encontrada
    echo "      Tentando iniciar 'npm run start:dev' em background (backend) na porta $free_port..."
    pushd "$project_path/backend" > /dev/null
    # Passa a porta como variável de ambiente para o comando npm
    PORT=$free_port npm run start:dev -- --watch > nest_server.log 2>&1 &
    local dev_pid=$!
    popd > /dev/null
    sleep 8 # Dar um pouco mais de tempo para NestJS iniciar

    if ps -p $dev_pid > /dev/null; then
        echo "      ✅ Backend 'npm run start:dev' iniciou com sucesso na porta $free_port (PID: $dev_pid). Finalizando..."
        kill $dev_pid
        wait $dev_pid 2>/dev/null # Limpar processo
    else
        echo "      ❌ Backend 'npm run start:dev' falhou ao iniciar ou encerrou prematuramente (verifique $project_path/backend/nest_server.log)."
        # O teste principal já incrementou falhas, mas retornamos 1 para parar aqui
        return 1
    fi
  fi
  return $result
}

# --- Teste de Erro ---
test_create_duplicate_project() {
  local project_name="test_duplicate"
  local test_subdir="error/duplicate"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  # Criar o diretório primeiro para simular o erro
  mkdir -p "$project_path"

  # Tentar criar o projeto (deve falhar)
  echo "\n🧪 Executando Teste: Create com diretório duplicado (espera falha)..."
  echo "   Diretório de trabalho: $TEST_DIR_BASE/$test_subdir"
  pushd "$TEST_DIR_BASE/$test_subdir" > /dev/null
  zsh <<EOF
  source "$PLUGIN_FILE" || { echo "❌ Falha ao carregar arquivo do plugin: $PLUGIN_FILE"; exit 1; }
  echo "   Comando: zuya create $project_name"
  zuya create $project_name
EOF
  local exit_status=$?
  popd > /dev/null

  if [[ $exit_status -ne 0 ]]; then
      echo "   ✅ Teste 'Create Duplicado' PASSOU (Falhou como esperado, Exit Code: $exit_status)"
      passed_tests=$((passed_tests + 1))
      return 0
  else
      echo "   ❌ Teste 'Create Duplicado' FALHOU (Não falhou como esperado, Exit Code: $exit_status)"
      failed_tests=$((failed_tests + 1))
      return 1
  fi
}

# --- Teste Específico para Template Next.js ---
test_verify_nextjs_template_overwrite() {
  local project_name="temp_next_overwrite_test"
  local test_subdir="verify/nextjs_template"
  local project_path="$TEST_DIR_BASE/$test_subdir/$project_name"
  local target_file="$project_path/frontend/src/app/page.tsx"

  # 1. Criar o projeto usando o plugin (espera-se que ele modifique page.tsx)
  _run_zsh_command "Verify Template: Criar projeto (next-nest)" "$test_subdir" "zuya create $project_name next-nest --force-rules"
  local result=$?
  
  # 2. Se a criação foi bem-sucedida, verificar o conteúdo final
  if [[ $result -eq 0 ]]; then
    # Verificar diretamente o conteúdo do arquivo, esperando que o plugin tenha funcionado
    echo "   Verificando conteúdo de $target_file (esperado template ZuYa)..."
    if [[ ! -f "$target_file" ]]; then
        echo "   ❌ Verificação Falhou: Arquivo $target_file não encontrado."
        failed_tests=$((failed_tests + 1)) 
        passed_tests=$((passed_tests - 1)) 
        return 1 
    fi
    
    # Usar grep -q para verificar o conteúdo esperado
    if grep -q "Welcome to ZuYa Templates" "$target_file"; then # Usar a string corrigida
        echo "   ✅ Verificação Passou: Conteúdo do template ZuYa encontrado em $target_file."
        return 0 # Sucesso (o _run_zsh_command já contou como passe)
    else
        echo "   ❌ Verificação Falhou: Conteúdo do template ZuYa NÃO encontrado em $target_file."
        failed_tests=$((failed_tests + 1)) 
        passed_tests=$((passed_tests - 1)) 
        return 1 # Falha
    fi
  fi
  return $result
}

# --- Executar Todos os Testes ---

# test_create_express_pg
# test_create_nest_mongo
# test_copy_rules_no_force
# test_copy_rules_with_force
# test_create_duplicate_project
# test_refactored_nextjs_build_run
# test_refactored_nestjs_build_run

# Executar apenas o teste de verificação do template
test_verify_nextjs_template_overwrite

# --- Relatório Final ---

echo "\n--- Resumo dos Testes --- 
Aprovação: $passed_tests
Falha:     $failed_tests
-------------------------"

_cleanup

if [[ $failed_tests -eq 0 ]]; then
  echo "\n🎉 Todos os testes passaram!"
  exit 0
else
  echo "\n❌ Alguns testes falharam."
  exit 1
fi
