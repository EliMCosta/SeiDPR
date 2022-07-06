#!/bin/bash
cd "$PWD"
echo "Aguarde. Configurando."
python3 -m venv venv
source "$PWD"/venv/bin/activate
sleep 5
python3 -m pip install --user --upgrade pip
python3 -m pip install -r requirements.txt
python3 "$PWD"/config/set_credentials.py
echo "Senha guardada com segurança."
sleep 1
echo "Configuração realizada com sucesso!"
sleep 5