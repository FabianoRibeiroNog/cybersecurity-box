import time
import wifi_monitor

INTERVALO_SCAN = 300

def main():
    print("Cybersecurity Box iniciada!")
    print("Iniciando Wi-Fi Monitor...")
    print()

    while(True):
        redes = wifi_monitor.escanear_redes()

        print("Redes encontradas:", len(redes))
        print()

        for rede in redes:
            wifi_monitor.exibir_rede(rede)

            print()
            print("Novo scan em", INTERVALO_SCAN, "Segundos... ")
            print()

            time.sleep(INTERVALO_SCAN)

main()