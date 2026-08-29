import network
import ntptime
import time


WIFI_TIMEOUT_SECONDS = 15
NTP_HOST = "pool.ntp.org"


def _obter_credenciais():
    try:
        from wifi_secrets import WIFI_PASSWORD, WIFI_SSID
        return WIFI_SSID, WIFI_PASSWORD
    except ImportError:
        print("Aviso: wifi_secrets.py nao encontrado. NTP desativado.")
    except Exception as erro:
        print("Aviso: falha ao carregar credenciais Wi-Fi:", erro)

    return None, None


def conectar_wifi(timeout_segundos=WIFI_TIMEOUT_SECONDS):
    ssid, senha = _obter_credenciais()

    if not ssid or not senha:
        return None

    wlan = network.WLAN(network.WLAN.IF_STA)
    wlan.active(True)

    if wlan.isconnected():
        return wlan

    try:
        print("Conectando a rede Wi-Fi autorizada para sincronizar horario...")
        wlan.connect(ssid, senha)

        inicio = time.time()
        while not wlan.isconnected():
            if time.time() - inicio >= timeout_segundos:
                print("Aviso: timeout ao conectar Wi-Fi para NTP.")
                return None
            time.sleep_ms(250)

        print("Wi-Fi conectado para sincronizacao NTP.")
        return wlan
    except Exception as erro:
        print("Aviso: falha na conexao Wi-Fi para NTP:", erro)
        return None


def desconectar_wifi(wlan):
    if not wlan:
        return

    try:
        if wlan.isconnected():
            wlan.disconnect()
    except Exception as erro:
        print("Aviso: falha ao desconectar Wi-Fi apos NTP:", erro)


def sincronizar_horario(timeout_segundos=WIFI_TIMEOUT_SECONDS, desconectar_apos_sync=True):
    wlan = conectar_wifi(timeout_segundos)

    if not wlan:
        return False

    try:
        ntptime.host = NTP_HOST
        ntptime.settime()
        print("Horario sincronizado via NTP em UTC.")
        return True
    except Exception as erro:
        print("Aviso: falha ao sincronizar horario via NTP:", erro)
        return False
    finally:
        if desconectar_apos_sync:
            desconectar_wifi(wlan)
