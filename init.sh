#!/usr/bin/env bash
set -euo pipefail

virtualenv env
. venv/bin/activate
pip install -r requirements.txt
