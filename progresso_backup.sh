#!/bin/bash

# Diretório de origem
ORIGEM="/mnt/var/lib/pgsql/10/data"

# Dispositivo de destino
DESTINO="/dev/sdc1"

# Montagem do destino (ajuste se necessário)
MONTADO="/mnt/var/lib/pgsql/10/data"

# Tamanho total da origem (em GB)
TOTAL=$(du -sBG "$ORIGEM" 2>/dev/null | cut -f1 | tr -d 'G')

# Espaço usado no destino (em GB)
USADO=$(df -BG "$DESTINO" | awk 'NR==2 {print $3}' | tr -d 'G')

# Espaço livre no destino (em GB)
LIVRE=$(df -BG "$DESTINO" | awk 'NR==2 {print $4}' | tr -d 'G')

# Porcentagem concluída
PORCENTAGEM=$((USADO * 100 / TOTAL))

# Espaço restante para copiar
FALTA=$((TOTAL - USADO))

echo "📦 Total a copiar: ${TOTAL} GB"
echo "✅ Já copiado: ${USADO} GB"
echo "⏳ Falta copiar: ${FALTA} GB"
echo "📊 Progresso: ${PORCENTAGEM}%"
