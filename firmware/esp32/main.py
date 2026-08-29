import time
import time_sync
import wifi_monitor

INTERVALO_SCAN = 10
UTC_OFFSET_HORAS = -3

def obter_horario(offset_horas=UTC_OFFSET_HORAS):
    if offset_horas:
        agora = time.localtime(time.time() + (offset_horas * 3600))
    else:
        agora = time.localtime()

    ano = agora[0]
    mes = agora[1]
    dia = agora[2]
    hora = agora[3]
    minuto = agora[4]
    segundo = agora[5]

    return "{:02d}/{:02d}/{} {:02d}:{:02d}:{:02d}".format(dia, mes, ano, hora, minuto, segundo)


def main():
    print("Cybersecurity Box iniciada!")
    print("Sincronizando horario via NTP...")

    if not time_sync.sincronizar_horario():
        print("Aviso: NTP indisponivel. Continuando com horario atual do RTC.")

    if UTC_OFFSET_HORAS == 0:
        print("Timestamps em UTC.")
    else:
        print("Timestamps com offset UTC", UTC_OFFSET_HORAS)

    print("Iniciando Wi-Fi Monitor...")
    print()

    redes_conhecidas = set()
    primeiro_scan = True

    while True:
        horario_inicio = obter_horario()

        print()
        print("======================")
        print("SCAN INICIADO EM: ", horario_inicio)

        redes = wifi_monitor.escanear_redes()

        horario_fim = obter_horario()

        print("Redes encontradas: ", len(redes))
        print("======================")
        print("SCAN FINALIZADO EM: ", horario_fim)
        print("======================")
        print()

        print("Redes encontradas:", len(redes))
        print()

        for rede in redes:
            wifi_monitor.exibir_rede(rede)

        bssids_atuais = set()

        for rede in redes:
            bssid = rede[1]
            bssids_atuais.add(bssid)

            if not primeiro_scan and bssid not in redes_conhecidas:
                horario_deteccao = obter_horario()
                print()
                print("======================")
                print("!!! NOVA REDE DETECTADA !!!")
                print("======================")
                print("HORARIO DA DETECCAO: ", horario_deteccao)
                wifi_monitor.exibir_rede(rede)

        redes_conhecidas.update(bssids_atuais)

        primeiro_scan = False

        print()
        print("Novo scan em", INTERVALO_SCAN, "segundos...")
        print()

        time.sleep(INTERVALO_SCAN)

main()
