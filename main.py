import wifi_monitor


def main():
    print("Cybersecurity Box iniciada!")
    print("Iniciando Wi-Fi Monitor...")
    print()

    redes = wifi_monitor.escanear_redes()

    print("Redes encontradas:", len(redes))
    print()

    for rede in redes:
        wifi_monitor.exibir_rede(rede)


main()