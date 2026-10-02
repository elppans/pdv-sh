#!/bin/bash
# Nome do arquivo: temp_upload.sh

# Verifica se foi passado um argumento
if [ $# -eq 0 ]; then
  echo "Uso: $0 arquivo"
  exit 1
fi

ARQUIVO=$1

# Faz o upload para temp.sh
LINK=$(curl -s -F "file=@${ARQUIVO}" https://temp.sh/upload)

# Mostra o link gerado
echo "Arquivo enviado com sucesso!"
echo "Link: $LINK"
