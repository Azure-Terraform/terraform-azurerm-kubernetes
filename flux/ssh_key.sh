#!/bin/bash

eval "$(jq -r '@sh "export HOST=\(.host)"')"
KEY=$(ssh-keyscan -t rsa -p "$(echo "$HOST" | sed -e "s/\([^@]*\)\@\([^:]*\):\([0-9]*\).*/\3/" | sed -e "s/^$/22/")" "$(echo "$HOST" | sed -e "s/\([^@]*\)\@\([^:]*\).*/\2/")")
jq -n --arg key "$KEY" '{"key":$key}'
