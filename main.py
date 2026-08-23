import network
import binascii

print("Cybersecurity Box iniciada!")
print("Iniciando Wi-fi Monitor...")

wlan = network.WLAN(network.WLAN.IF_STA)
wlan.active(True)

redes = wlan.scan()

print("Redes encontradas: ", len(redes))
print()

for rede in redes:
    ssid = rede[0].decode("utf-8")
    bssid = binascii.hexlify(rede[1], ":").decode("utf-8")
    canal = rede[2]
    rssi = rede[3]

    print("SSID: ", ssid)
    print("BSSID: ", bssid)
    print("CANAL: ", canal)
    print("RSSI", rssi)
    print("-------------------")