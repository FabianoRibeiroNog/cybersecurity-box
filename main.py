import network
import binascii

SECURITY_TYPES = {
    0: "OPEN",
    1: "WEP",
    2: "WPA-PSK",
    3: "WPA2-PSK",
    4: "WPA/WPA2-PSK"
}

def classifySignal(rssi):
    if rssi >= -60:
        return = "STRONG"
    elif rssi >= -75:
        return = "MEDIUM"
    else:
        return = "WEAK"

def format_bssid(bssid):
    return binascii.hexlify(rede[1], ":").decode("utf-8")

def get_security(code):
    return SECURITY_TYPES.get(code, "DESCONHECIDA")

print("Cybersecurity Box iniciada!")
print("Iniciando Wi-fi Monitor...")

wlan = network.WLAN(network.WLAN.IF_STA)
wlan.active(True)

redes = wlan.scan()

print("Redes encontradas: ", len(redes))
print()

for rede in redes:
    ssid = rede[0].decode("utf-8")
    bssid = format_bssid(rede[1])
    canal = rede[2]
    rssi = rede[3]

    codigo_seguranca = rede[4]
    seguranca = SECURITY_TYPES.get(codigo_seguranca, "DESCONHECIDA")

    oculta = rede[5]
    ocultaTexto = "Sim" if oculta else "Não"

    quality = classifySignal(rssi)


    print("SSID: ", ssid)
    print("BSSID: ", bssid)
    print("CANAL: ", canal)
    print("RSSI", rssi)
    print("SEGURANCA: ", seguranca)
    print("OCULTA: ", ocultaTexto)
    print("SIGNAL: ", quality)
    print("-------------------")