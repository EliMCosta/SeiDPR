#!/bin/bash
echo "Ativando ambiente virtual isolado..."
cd "$PWD"
source "$PWD"/venv/bin/activate
echo "Iniciando execução do serviço..."
python3 "$PWD"/src/main.py
echo "Execução do serviço terminada."
sleep 1
echo "Desativando ambiente..."
deactivate
echo "Ambiente desativado."
sleep 5
