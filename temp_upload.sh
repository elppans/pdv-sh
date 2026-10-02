#!/bin/bash
# Nome do arquivo: temp_upload.sh

# -- Como usar sem baixar: --
#
# bash <(curl -s https://elppans.github.io/pdv-sh/temp_upload.sh) arquivo.tar.gz
# OU
# bash <(wget -qO- https://elppans.github.io/pdv-sh/temp_upload.sh) arquivo.tar.gz
# 
# Observações:
# 1) O arquivo expira em 3 dias
# 2) O limite atual de tamanho do arquivo é de 4GB

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
