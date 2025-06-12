#!/bin/sh
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# echo "🚀AI PACKAGED SOLUTION SETUP"
# echo "  _____                  ____  _             _         _         _          ____             _             "
# echo " | ____|__ _ ___ _   _  / ___|| |_ __ _  ___| | __    / \  _   _| |_ ___   |  _ \  ___ _ __ | | ___  _   _ "
# echo " |  _| / _| / __| | | | \___ \| __/ _| |/ __| |/ /   / _ \| | | | __/ _ \  | | | |/ _ \ '_ \| |/ _ \| | | |"
# echo " | |__| (_| \__ \ |_| |  ___) | || (_| | (__|   <   / ___ \ |_| | || (_) | | |_| |  __/ |_) | | (_) | |_| |"
# echo " |_____\__,_|___/\__, | |____/ \__\__,_|\___|_|\_\ /_/   \_\__,_|\__\___/  |____/ \___| .__/|_|\___/ \__, |"
# echo "                 |___/                                                                |_|            |___/ "

# Verifica se algum módulo foi passado como argumento
if [ "$#" -eq 0 ]; then
    echo "🚨 Erro: Nenhum módulo especificado para deploy."
    echo "Uso: $0 <modulo1> <modulo2> ..."
    exit 1
fi

export TF_VAR_project_id=$GOOGLE_CLOUD_PROJECT

# --- Construção Dinâmica da Variável de Módulos ---
# Lista de todos os módulos possíveis
ALL_MODULES=("img-studio")
map_content=""

# Itera sobre todos os módulos conhecidos
for module_name in "${ALL_MODULES[@]}"; do
  enabled="false"
  # Verifica se o módulo atual está na lista de argumentos
  for arg in "$@"; do
    if [ "$arg" = "$module_name" ]; then
      enabled="true"
      break
    fi
  done
  # Adiciona a entrada ao mapa
  map_content="${map_content}\"${module_name}\" = ${enabled}, "
done

# Remove a vírgula e o espaço extras no final
map_content=$(echo "${map_content}" | sed 's/, $//')

# Exporta a variável para o Terraform
export TF_VAR_deploy_modules="{ ${map_content} }"

echo "🔧 Módulos a serem implantados: $@"
echo "Terraform variable set: TF_VAR_deploy_modules=${TF_VAR_deploy_modules}"
# --- Fim da Construção Dinâmica ---

echo "⚙️ Setup Terraform"
terraform init

echo "🚀 Apply Terraform"
terraform apply -auto-approve

echo "☁️ Persist terraform state in the bucket"
terraform init -migrate-state