#!/bin/bash

# CONFIGURAÇÃO DA IMPRESSORA SWEDA NO CONVERSOR.ini
# Base rc.local

# -- PROCEDIMENTO --
#
# * Método 1:
# 1) Copiar este Script para o diretório "/Zanthus/Zeus/pdvJava"
# 2) Adicionar estes 2 comandos no começo do Script PDVTouch.sh:
#
# chmod +x /Zanthus/Zeus/pdvJava/device_sweda.sh
# /Zanthus/Zeus/pdvJava/device_sweda.sh
#
# * Método 2:
# 1) Copie este Script para /usr/local/bin/device_sweda.sh
# 2) Crie/Modifique a seguinte regra:
# 97-Impressora.rules
# SWEDA SL300-S
# KERNEL=="*[0-9]", SUBSYSTEM=="usb", ACTION=="add", ATTRS{idVendor}=="1c8a", SYMLINK+="sweda", OWNER="lp", GROUP="lp", MODE="0666"
# KERNEL=="*[0-9]", SUBSYSTEM=="usb", ATTRS{idVendor}=="1c8a", RUN+="/usr/local/bin/device_sweda.sh"



DEVICE_SWEDA="$(ls /dev/serial/by-id/usb-SWEDA_USB_To_Serial_Interface_*-if*)"

# Impressora Sweda, ttyACM0
if ls -l "$DEVICE_SWEDA" &>/dev/null ; then
DEVICE_SWEDA_PRINTER=$(ls -l "$DEVICE_SWEDA" 2>/dev/null | awk '{print $NF}')
USBSERAL_PORT_PRINTER=$(basename $DEVICE_SWEDA_PRINTER 2>/dev/null)
# DEV_USBSERAL_PORT_PRINTER="$USBSERAL_PORT_PRINTER"
# ln -sf /dev/$USBSERAL_PORT_PRINTER /dev/ttyACM999
fi

# echo "USBSERAL_PORT_PRINTER: $USBSERAL_PORT_PRINTER"

if [ -f /Zanthus/Zeus/pdvJava/CONVERSOR.ini ];then
sed -i "s|^PORTA = /dev/.*|PORTA = /dev/$USBSERAL_PORT_PRINTER|" /Zanthus/Zeus/pdvJava/CONVERSOR.ini
fi
