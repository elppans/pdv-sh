#!/usr/bin/env bash
# Diagnóstico de disco (kernel, sistema de arquivos, hdparm, smartctl, badblocks)
# Saída completa em ~/smart.txt
#
# Uso:
#   ./smart-check.sh                      # diagnóstico rápido (só leitura)
#   ./smart-check.sh --long-test          # também inicia o self-test longo (background)
#   ./smart-check.sh --badblocks          # também roda badblocks (LENTO, só leitura)
#   ./smart-check.sh --lba 123456         # também tenta achar o arquivo do LBA ruim
#   DISK=/dev/sdb PART=/dev/sdb1 ./smart-check.sh
#
# Depois que o self-test longo terminar (pode levar horas):
#   ./smart-check.sh --result

# Disco e partição em variáveis: 
# O padrão é /dev/sda e /dev/sda3, mas pode trocar com DISK=/dev/sdb PART=/dev/sdb1 ./smart-check.sh.

DISK="${DISK:-/dev/sda}"
PART="${PART:-/dev/sda3}"
OUT="$HOME/smart.txt"

LONG_TEST=0; BADBLOCKS=0; RESULT=0; LBA=""

while [ $# -gt 0 ]; do
    case "$1" in
        --long-test) LONG_TEST=1 ;;
        --badblocks) BADBLOCKS=1 ;;
        --result)    RESULT=1 ;;
        --lba)       LBA="$2"; shift ;;
        -h|--help)   sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "Opção desconhecida: $1"; exit 1 ;;
    esac
    shift
done

# Pede a senha do sudo uma vez só
sudo -v || exit 1

titulo() { echo -e "\n===== $* =====" | tee -a "$OUT"; }
roda()   { echo "\$ $*" | tee -a "$OUT"; "$@" 2>&1 | tee -a "$OUT"; }

# Só o resultado do self-test longo
if [ "$RESULT" -eq 1 ]; then
    titulo "Resultado do self-test (smartctl -l selftest)"
    roda sudo smartctl -l selftest "$DISK"
    exit 0
fi

# Começa um arquivo novo
echo "Diagnóstico de $DISK em $(date)" > "$OUT"

########################################
# Sem smartctl
########################################
titulo "Erros de I/O no kernel (dmesg)"
echo "\$ dmesg | grep -iE 'error|fail|I/O error|ata|sd[a-z]'" | tee -a "$OUT"
sudo dmesg | grep -iE 'error|fail|I/O error|ata|sd[a-z]' | tee -a "$OUT"

titulo "Erros no journal do kernel (journalctl -k)"
echo "\$ journalctl -k | grep -iE 'error|ata|sd[a-z]'" | tee -a "$OUT"
sudo journalctl -k | grep -iE 'error|ata|sd[a-z]' | tee -a "$OUT"

titulo "Sistema de arquivos (fsck -n = somente leitura, não corrige nada)"
roda sudo fsck -n "$PART"

titulo "Modelo do disco via sysfs"
echo "\$ cat /sys/block/${DISK##*/}/device/model" | tee -a "$OUT"
cat "/sys/block/${DISK##*/}/device/model" | tee -a "$OUT"

titulo "Informações do disco (hdparm -I)"
roda sudo hdparm -I "$DISK"

########################################
# Com smartctl
########################################
if ! command -v smartctl >/dev/null 2>&1; then
    titulo "Instalando smartmontools"
    sudo apt update && sudo apt -y install smartmontools
fi

titulo "Identificação do disco"
roda lsblk
roda sudo smartctl --scan

titulo "Suporte a SMART (procure 'SMART support is: Enabled')"
roda sudo smartctl -i "$DISK"
# Se estiver Disabled, ative manualmente com: sudo smartctl -s on "$DISK"

titulo "Veredito de saúde (PASSED ou FAILED!)"
roda sudo smartctl -H "$DISK"

titulo "Info + saúde + valores gerais"
roda sudo smartctl -i -H -c "$DISK"

titulo "Atributos detalhados (smartctl -A)"
# Observe: Reallocated_Sector_Ct (5), Current_Pending_Sector (197),
# Offline_Uncorrectable (198), UDMA_CRC_Error_Count (199)
roda sudo smartctl -A "$DISK"

titulo "Log de erros já registrados"
roda sudo smartctl -l error "$DISK"

titulo "Tudo (smartctl -x): atributos, log de erros, histórico de testes"
roda sudo smartctl -x "$DISK"

########################################
# Opcionais
########################################
if [ "$LONG_TEST" -eq 1 ]; then
    titulo "Iniciando self-test longo (roda em background no disco)"
    roda sudo smartctl -t long "$DISK"
    echo "Quando terminar, rode: $0 --result" | tee -a "$OUT"
fi

if [ "$BADBLOCKS" -eq 1 ]; then
    titulo "badblocks em modo leitura (não destrutivo, DEMORADO)"
    roda sudo badblocks -sv "$DISK"
fi

if [ -n "$LBA" ]; then
    titulo "Achar QUAL arquivo está no LBA $LBA"
    echo "Atenção: o LBA do disco precisa ser convertido para bloco do sistema de arquivos" | tee -a "$OUT"
    echo "(bloco = (LBA - início_da_partição) * 512 / tamanho_do_bloco)." | tee -a "$OUT"
    echo "Início da partição:" | tee -a "$OUT"
    cat "/sys/class/block/${PART##*/}/start" | tee -a "$OUT"
    echo "Depois use: sudo debugfs -R \"icheck <BLOCO>\" $PART" | tee -a "$OUT"
    echo "        e:  sudo debugfs -R \"ncheck <INODE>\" $PART" | tee -a "$OUT"
fi

echo -e "\nConcluído. Resultado em: $OUT"