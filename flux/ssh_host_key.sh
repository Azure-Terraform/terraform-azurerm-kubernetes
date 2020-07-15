#!/bin/bash

eval "$(jq -r '@sh "export URL=\(.url)"')"
HOST=$(echo "$URL" | sed -e "s/\([^@]*\)\@\([^:]*\).*/\2/")
KEY=$(ssh-keyscan -t rsa -p "$(echo "$URL" | sed -e "s/\([^@]*\)\@\([^:]*\):\([0-9]*\).*/\3/" | sed -e "s/^$/22/")" "$HOST")
jq -n --arg host "$HOST" --arg key "$KEY" '{"host":$host,"key":$key}'
