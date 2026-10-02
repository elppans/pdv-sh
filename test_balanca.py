#!/usr/bin/env python3
import os
import sys
import time
import termios
import select

DEVICE = "/dev/ttyS4"
BAUD_RATES = [
    (2400, termios.B2400),
    (4800, termios.B4800),
    (9600, termios.B9600)
]
ENQ = b'\x05'

def test_baud(device_path, baud_name, baud_const):
    print("\n[+] Testando %s @ %d bps (8N1)..." % (device_path, baud_name))
    try:
        fd = os.open(device_path, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    except Exception as e:
        print("    [-] Erro ao abrir dispositivo: %s" % str(e))
        return False

    try:
        attr = termios.tcgetattr(fd)
        attr[4] = baud_const
        attr[5] = baud_const
        attr[0] = 0
        attr[1] = 0
        attr[2] = termios.CS8 | termios.CREAD | termios.CLOCAL
        attr[3] = 0
        attr[6][termios.VMIN] = 0
        attr[6][termios.VTIME] = 0
        termios.tcsetattr(fd, termios.TCSANOW, attr)
        termios.tcflush(fd, termios.TCIOFLUSH)

        os.write(fd, ENQ)

        r, _, _ = select.select([fd], [], [], 1.5)
        if r:
            time.sleep(0.1)
            data = os.read(fd, 64)
            if data:
                hex_str = " ".join(["%02X" % b for b in data])
                ascii_clean = "".join([chr(b) if 32 <= b <= 126 else ("\\x%02x" % b) for b in data])
                print("    [✔] SUCESSO! Resposta recebida:")
                print("        Hex   : %s" % hex_str)
                print("        ASCII : %s" % ascii_clean)
                
                if b'\x02' in data and b'\x03' in data:
                    start = data.find(b'\x02') + 1
                    end = data.find(b'\x03')
                    raw_peso = data[start:end].decode('latin-1', errors='ignore')
                    print("        -> Peso Decodificado: %s (Bruto)" % raw_peso)
                return True
        print("    [-] Timeout (Nenhuma resposta)")
    except Exception as e:
        print("    [-] Erro durante a comunicacao: %s" % str(e))
    finally:
        os.close(fd)
    return False

if __name__ == "__main__":
    dev = sys.argv[1] if len(sys.argv) > 1 else DEVICE
    print("=== Varredura de Baud Rate para Balanca Toledo (%s) ===" % dev)
    
    found = False
    for baud_val, baud_const in BAUD_RATES:
        if test_baud(dev, baud_val, baud_const):
            print("\n==========================================")
            print(" CONFIGURACAO CORRETA DETECTADA: %d bps" % baud_val)
            print("==========================================")
            found = True
            break
            
    if not found:
        print("\n[!] Nenhuma velocidade respondeu ao comando ENQ.")
        print("    Verifique se a balanca esta ligada e configurada em PrT 1 / P03.")