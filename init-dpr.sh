#!/bin/bash
cd "$PWD"
source "$PWD"/venv/bin/activate
python3 "$PWD"/src/main.py
deactivate
