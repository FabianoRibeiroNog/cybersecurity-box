import network
import binascii

print("Cybersecurity Box iniciada!")
print("Iniciando Wi-fi Monitor...")

wlan = network.WLAN(network.WLAN.IF_STA)
wlan.active(True)

redes = wlan.scan()

print("Redes encontradas: ", len(redes))
print()

tiposSeguranca = {
    0: "OPEN",
    1: "WEP",
    2: "WPA-PSK",
    3: "WPA2-PSK",
    4: "WPA/WPA2-PSK"
}

for rede in redes:
    ssid = rede[0].decode("utf-8")
    bssid = binascii.hexlify(rede[1], ":").decode("utf-8")
    canal = rede[2]
    rssi = rede[3]
    codigo_seguranca = rede[4]

    seguranca = tiposSeguranca.get(codigo_seguranca, "DESCONHECIDA")

    print("SSID: ", ssid)
    print("BSSID: ", bssid)
    print("CANAL: ", canal)
    print("RSSI", rssi)
    print("SEGURANCA: ", seguranca)
    print("-------------------")