#!/bin/bash
cd "$PWD"
source "$PWD"/venv/bin/activate
sleep 5
python3 "$PWD"/src/main.py
deactivate
