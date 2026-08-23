import network
import binascii


TIPOS_SEGURANCA = {
    0: "OPEN",
    1: "WEP",
    2: "WPA-PSK",
    3: "WPA2-PSK",
    4: "WPA/WPA2-PSK"
}


def classificar_sinal(rssi):
    if rssi >= -60:
        return "FORTE"
    elif rssi >= -75:
        return "MEDIO"
    else:
        return "FRACO"


def formatar_bssid(bssid):
    return binascii.hexlify(bssid, ":").decode("utf-8")


def obter_seguranca(codigo):
    return TIPOS_SEGURANCA.get(codigo, "DESCONHECIDA")


def escanear_redes():
    wlan = network.WLAN(network.WLAN.IF_STA)
    wlan.active(True)

    print("Escaneando redes Wi-Fi...")

    redes = wlan.scan()

    return redes


def exibir_rede(rede):
    ssid = rede[0].decode("utf-8")
    bssid = formatar_bssid(rede[1])
    canal = rede[2]
    rssi = rede[3]
    seguranca = obter_seguranca(rede[4])

    oculta = rede[5]
    oculta_texto = "SIM" if oculta else "NAO"

    qualidade = classificar_sinal(rssi)

    print("SSID:", ssid)
    print("BSSID:", bssid)
    print("CANAL:", canal)
    print("RSSI:", rssi, "dBm")
    print("SINAL:", qualidade)
    print("SEGURANCA:", seguranca)
    print("OCULTA:", oculta_texto)
    print("--------------------")


def main():
    print("Cybersecurity Box iniciada!")
    print("Iniciando Wi-Fi Monitor...")
    print()

    redes = escanear_redes()

    print("Redes encontradas:", len(redes))
    print()

    for rede in redes:
        exibir_rede(rede)


main()