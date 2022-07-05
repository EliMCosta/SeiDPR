#!/bin/bash
cd "$PWD"
#python3 -m venv venv
source "$PWD"/venv/bin/activate
#python3 -m pip install --user --upgrade pip
#python3 -m pip install -r requirements.txt
python3 "$PWD"/config/set_credentials.py