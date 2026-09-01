#!/bin/bash

# CONFIGURAÇÃO DE BALANÇAS PARA SELF
# Base rc.local

# -- PROCEDIMENTO --
# 1) Copiar este Script para o diretório "/Zanthus/Zeus/pdvJava"
# 2) Adicionar estes 2 comandos no começo do Script PDVTouch.sh:
#
# chmod +x /Zanthus/Zeus/pdvJava/devices-self.sh
# /Zanthus/Zeus/pdvJava/devices-self.sh

# Device BY-ID
DEVICE_USB0="/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0"
DEVICE_TOLEDO="/dev/serial/by-id/usb-TOLEDO_CDC_DEVICE_*-if*"
DEVICE_MAGELLAN="/dev/serial/by-id/usb-Datalogic_S.r.I_and_its_affiliates_Magellan_3x10i_*-if*"

# Device SERIAL
DEVICE_USB0_SERIAL="/dev/ttyS2"
DEVICE_TOLEDO_SERIAL="/dev/ttyS3"
DEVICE_MAGELLAN_SERIAL="/dev/ttyS4"

# Export variáveis
export DEVICE_USB0
export DEVICE_TOLEDO
export DEVICE_MAGELLAN
export DEVICE_USB0_SERIAL
export DEVICE_TOLEDO_SERIAL
export DEVICE_MAGELLAN_SERIAL

# Balança USB/Serial, ttyUSB0
if ls -l "$DEVICE_USB0" &>/dev/null ; then
DEVICE_BALANCA_USB0=$(ls -l "$DEVICE_USB0" 2>/dev/null | awk '{print $NF}')
USBSERAL_PORT_BALANCA=$(basename $DEVICE_BALANCA_USB0 2>/dev/null)
rm -rf "$DEVICE_USB0_SERIAL"
ln -sf /dev/$USBSERAL_PORT_BALANCA "$DEVICE_USB0_SERIAL"

# DEBUG:
echo "DEVICE_BALANCA_USB0: $DEVICE_BALANCA_USB0"
echo "USBSERAL_PORT_BALANCA: $USBSERAL_PORT_BALANCA"
fi

# Balança Toledo USB, ttyACM0
if ls -l "$DEVICE_TOLEDO" &>/dev/null ; then
DEVICE_BALANCA_TOLEDO=$(ls -l "$DEVICE_TOLEDO" 2>/dev/null | awk '{print $NF}')
TOLEDOCDC_PORT=$(basename $DEVICE_BALANCA_TOLEDO 2>/dev/null)
rm -rf "$DEVICE_TOLEDO_SERIAL"
ln -sf /dev/$TOLEDOCDC_PORT "$DEVICE_TOLEDO_SERIAL"

# DEBUG:
echo "DEVICE_BALANCA_TOLEDO: $DEVICE_BALANCA_TOLEDO"
echo "TOLEDOCDC_PORT: $TOLEDOCDC_PORT"
fi

# DATALOGIC MAGELLAN 3X10I
if ls -l "$DEVICE_MAGELLAN" &>/dev/null ; then
DEVICE_DATALOGIC_MAGELLAN=$(ls -l "$DEVICE_MAGELLAN" 2>/dev/null | awk '{print $NF}')
DATALOGIC_PORT=$(basename $DEVICE_DATALOGIC_MAGELLAN 2>/dev/null)
rm -rf "$DEVICE_MAGELLAN_SERIAL"
ln -sf /dev/$DATALOGIC_PORT "$DEVICE_MAGELLAN_SERIAL"

# DEBUG:
echo "DEVICE_DATALOGIC_MAGELLAN: $DEVICE_DATALOGIC_MAGELLAN"
echo "DATALOGIC_PORT: $DATALOGIC_PORT"
fi

