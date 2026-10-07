#!/bin/bash

# CONFIGURAÇÃO DO PINPAD NO CliSiTef.ini
# Base rc.local

# -- PROCEDIMENTO --
#
# * Método 1:
# 1) Copiar este Script para o diretório "/Zanthus/Zeus/pdvJava"
# 2) Adicionar estes 2 comandos no começo do Script PDVTouch.sh:
#
# chmod +x /Zanthus/Zeus/pdvJava/device_pinpad.sh
# /Zanthus/Zeus/pdvJava/device_pinpad.sh
#
# * Método 2:
# 1) Copie este Script para /usr/local/bin/device_pinpad.sh
# 2) Crie/Modifique a seguinte regra:
# 98-Pinpad.rules
# PINPAD GERTEC PPC920/PPC930
# SUBSYSTEM=="tty", ATTRS{idVendor}=="1753", ATTRS{idProduct}=="c901|c902", RUN+="/usr/local/bin/device_pinpad.sh"
# ACTION=="add", ATTRS{idVendor}=="1753", ATTRS{idProduct}=="c901|c902", SUBSYSTEM=="tty", KERNEL=="ttyUSB[0-9]*|ttyACM[0-9]*", SYMLINK+="ttyPIN", MODE="0666"

DEVICE_PINPAD="$(ls /dev/serial/by-id/usb*Pinpad_Terminal-*-if*)"

# PINPAD, ttyACM1
if ls -l "$DEVICE_PINPAD" &>/dev/null ; then
DEVICE_PINPAD_PORT=$(ls -l "$DEVICE_PINPAD" 2>/dev/null | awk '{print $NF}')
USBSERAL_PORT_PINPAD=$(basename $DEVICE_PINPAD_PORT 2>/dev/null)
# ln -sf /dev/$USBSERAL_PORT_PINPAD /dev/ttyACM888
fi

echo "USBSERAL_PORT_PINPAD: $USBSERAL_PORT_PINPAD"

if [ -f /Zanthus/Zeus/pdvJava/CliSiTef.ini ];then
sed -i "s|^Porta=/dev/.*|Porta=/dev/$USBSERAL_PORT_PINPAD|" /Zanthus/Zeus/pdvJava/CliSiTef.ini
fi
