#!/bin/bash

# Verifica e ajusta o layout do teclado em loop
while true; do
  current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')
  if [ "$current_layout" != "us" ]; then
    setxkbmap us
  fi
  sleep 5  # Verifica a cada 5 segundos, ajuste conforme necessário
done
