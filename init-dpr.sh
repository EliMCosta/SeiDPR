#!/bin/bash
echo "Ativando ambiente virtual isolado..."
cd "$PWD"
source "$PWD"/venv/bin/activate
sleep 5
echo "Ambiente ativado."
sleep 1
echo "Iniciando execução do serviço..."
python3 "$PWD"/src/main.py
echo "Execução do serviço terminada."
sleep 1
echo "Desativando ambiente..."
deactivate
echo "Ambiente desativado."
sleep 5