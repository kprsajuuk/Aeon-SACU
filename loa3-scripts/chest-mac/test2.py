import time
import pywifi
from pywifi import const

wifi = pywifi.PyWiFi()

iface = wifi.interfaces()[0]

iface.disconnect()
time.sleep(0.5)

profile = pywifi.Profile()
profile.ssid = 'bdsoft-cobot'
profile.auth = const.AUTH_ALG_OPEN
profile.akm.append(const.AKM_TYPE_WPA2PSK)
profile.cipher = const.CIPHER_TYPE_CCMP
profile.key = '78936479'

iface.remove_all_network_profiles()
tmp_profile = iface.add_network_profile(profile)

iface.connect(tmp_profile)