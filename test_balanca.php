#!/usr/bin/env php
<?php

$device = isset($argv[1]) ? $argv[1] : '/dev/ttyS4';
$bauds = array(2400, 4800, 9600);
$enq = "\x05";

echo "=== Varredura de Baud Rate para Balanca Toledo (" . $device . ") ===\n";

$found = false;

foreach ($bauds as $baud) {
    echo "\n[+] Testando " . $device . " @ " . $baud . " bps (8N1)...\n";

    $out = array();
    $ret = 0;
    exec("stty -F " . escapeshellarg($device) . " " . $baud . " cs8 -cstopb -parenb raw -echo min 0 time 2 2>/dev/null", $out, $ret);
    if ($ret !== 0) {
        echo "    [-] Falha ao configurar stty para " . $baud . " bps.\n";
        continue;
    }

    $fp = @fopen($device, "r+b");
    if (!$fp) {
        echo "    [-] Erro ao abrir a porta " . $device . ".\n";
        continue;
    }

    stream_set_blocking($fp, false);
    @fread($fp, 128); // Limpa buffer residual

    fwrite($fp, $enq);

    $read = array($fp);
    $write = null;
    $except = null;
    $numChanged = @stream_select($read, $write, $except, 1, 500000);

    if ($numChanged > 0) {
        usleep(100000);
        $response = fread($fp, 64);
        if ($response !== false && strlen($response) > 0) {
            $hexParts = array();
            for ($i = 0; $i < strlen($response); $i++) {
                $hexParts[] = sprintf("%02X", ord($response[$i]));
            }
            $hex = implode(' ', $hexParts);

            echo "    [✔] SUCESSO! Resposta recebida:\n";
            echo "        Hex   : " . $hex . "\n";
            echo "        Bruto : " . addcslashes($response, "\0..\37\177..\377") . "\n";

            if (strpos($response, "\x02") !== false && strpos($response, "\x03") !== false) {
                $p1 = strpos($response, "\x02") + 1;
                $p2 = strpos($response, "\x03");
                $peso = substr($response, $p1, $p2 - $p1);
                echo "        -> Peso Lido: " . $peso . "\n";
            }

            echo "\n==========================================\n";
            echo " CONFIGURACAO CORRETA DETECTADA: " . $baud . " bps\n";
            echo "==========================================\n";
            $found = true;
            fclose($fp);
            break;
        }
    }

    echo "    [-] Timeout (Nenhuma resposta)\n";
    fclose($fp);
}

if (!$found) {
    echo "\n[!] Nenhuma velocidade respondeu ao comando ENQ.\n";
}