#coding=utf-8
#coding=gbk
from pynput import keyboard
from pynput.mouse import Button, Controller
import pywifi
from pywifi import const
import time
import threading
import pyscreenshot as ImageGrab
import numpy as np
import matplotlib.pyplot as plt
import PIL.ImageGrab
from mss import mss
from PIL import Image

mouse = Controller()
wifi = pywifi.PyWiFi()
iface = wifi.interfaces()[0]

global thread

closeWhenFinished = True

open_pos = (579, 822)
confirm_pos = (890, 898)

close_pos = (1311, 263)
vault_pos = (1160, 439)

boss_pos = (970, 903)

refresh_pos = (563, 160)
guild_icon = (1175, 973)

game_close_pos = (270, 158)

confirm_bbox = (847,887,947,919)
open_bbox = (566,817,593,829)

#wifi_name = "bdsoft-cobot"
#wifi_pass = "78936479"

#wifi_name = "Xiaomi_HOBOT"
#wifi_pass = "serc1727"

#wifi_name = "zhu  wifi  5g"
#wifi_pass = "zhu889900"

#wifi_name = "bdsoft1104-AP"
#wifi_pass = "Bdsoft61137666"

#wifi_name = "bdsoft1104"
#wifi_pass = "Bdsoft61137666"


wifi_name = "PKUSE"
wifi_pass = "Bdsoft61137666"

#wifi_name = "sscz_2"
#wifi_pass = "blackhole"

test_input = (10, 100)
confirm_target = plt.imread("confirmtarget.png")
open_target = plt.imread("opentarget.png")

def getMousePosition():
	print(mouse.position)

def click():
	mouse.press(Button.left)
	time.sleep(0.05)
	mouse.release(Button.left)
	#mouse.click(Button.left)

def tryConnection(profile):
	iface.connect(profile)
	time.sleep(6)
	if not iface.status() == const.IFACE_CONNECTED:
		tryConnection(profile)

def connectWifi():
	profile = pywifi.Profile()
	profile.ssid = wifi_name
	profile.auth = const.AUTH_ALG_OPEN
	profile.akm.append(const.AKM_TYPE_WPA2PSK)
	profile.cipher = const.CIPHER_TYPE_CCMP
	profile.key = wifi_pass
	iface.remove_all_network_profiles()
	tmp_profile = iface.add_network_profile(profile)
	tryConnection(tmp_profile)

def pray():
	for num in range (1, 6):
		mouse.position = (950, 874)
		time.sleep(0.2)
		click()
		time.sleep(0.6)
		mouse.position = (884, 737)
		time.sleep(0.2)
		click()
		time.sleep(0.6)

def collect():
	mouse.position = confirm_pos #确定按钮 可能会变
	time.sleep(0.2)
	click()
	time.sleep(0.1)

	iface.disconnect()
	time.sleep(0.2)
	
	thread = threading.Thread(target=collectActionThread)
	thread.start()
	
	#profile = pywifi.Profile()
	#profile.ssid = 'bdsoft1104-AP'
	#profile.auth = const.AUTH_ALG_OPEN
	#profile.akm.append(const.AKM_TYPE_WPA2PSK)
	#profile.cipher = const.CIPHER_TYPE_CCMP
	#profile.key = 'Bdsoft61137666'
	#iface.remove_all_network_profiles()
	#tmp_profile = iface.add_network_profile(profile)
	#iface.connect(tmp_profile)

	'''
	mouse.position = (1510, 10) #打开wifi图标
	time.sleep(0.2)
	click()
	time.sleep(0.6)
	mouse.position = (1510, 104) #选中第二个Wi-Fi
	time.sleep(0.4)
	click()
	time.sleep(0.2)
	'''
	
def collectActionThread():
	time.sleep(0.2)
	mouse.position = open_pos #宝箱开启按钮 可能会变
	time.sleep(0.2)
	for num in range (1, 60):
		click()
		time.sleep(0.1)
	time.sleep(0.2)
	#mouse.position = (1477, 10) #点击右上角wifi图标
	#time.sleep(0.2) #点击右上角wifi图标
	#click() #点击右上角wifi图标
	#time.sleep(0.2) #点击右上角wifi图标
	mouse.position = confirm_pos #确定按钮 可能会变
	time.sleep(0.5)

	iface.disconnect()
	connectWifi()

def reopen():
	mouse.position = confirm_pos #确定按钮 可能会变
	time.sleep(0.1)
	click()
	time.sleep(0.1)
	mouse.position = close_pos
	time.sleep(0.2)
	click()
	mouse.position = vault_pos
	time.sleep(1)
	click()

def fightBoss():
	current = mouse.position
	mouse.position = boss_pos
	time.sleep(0.1)
	click()
	time.sleep(0.1)
	mouse.position = current

def restartGuild():	
	connectWifi()
	time.sleep(1)
	mouse.position = refresh_pos
	time.sleep(1)
	click()
	time.sleep(60)
	mouse.position = guild_icon
	time.sleep(1)
	click()
	time.sleep(2)

def compareImg(a, b):
	if (a.shape[0] != b.shape[0]) or (a.shape[1] != b.shape[1]) or (a.shape[2] != b.shape[2]):
		print('image dimension error')
		return False
	len1 = a.shape[0]
	len2 = a.shape[1]
	total_num = len1 * len2
	equal_num = 0
	for i in range(len1):
		for j in range(len2):
			obj_a = a[i][j]
			obj_b = b[i][j]
			diff = abs(obj_a[0] - obj_b[0]) + abs(obj_a[1] - obj_b[1]) + abs(obj_a[2] - obj_b[2])
			if diff < 0.1:
				equal_num += 1
	sim_rate = equal_num / total_num
	#print(sim_rate);
	if sim_rate >= 0.9:
		return True
	else:
		return False


def test():
	#im = ImageGrab.grab(bbox=(566,817,593,829))
	#im.save("test.png")
	#rgb = PIL.ImageGrab.grab().load()[2042,656]
	#print(rgb)
	for i in range(125):
		time.sleep(0.4)
		with mss() as sct:
			monitor = sct.monitors[1]
			pixel = sct.grab((1017, 326, 1018, 327)).pixels[0][0]
			print(pixel)
			#mss.tools.to_png(im.rgb, im.size, output="testscreenshot.png")
			#rgb = Image.frombytes('RGB', sct_img.size, sct_img.bgra, 'raw', 'BGRX')
			#print(rgb[100, 100])
		#rgb = PIL.ImageGrab.grab().load()[2042,656]
		
	#print(PIL.ImageGrab.grab().size)
	print('finish')
	return

def autoCollect():
	thread = threading.Thread(target=autoCollectThread)
	thread.start()

def autoCollectThread():
	time.sleep(10)
	auto_count = 0
	for i in range(195):
		collect()
		time.sleep(11) #collect中会开启单独的autoCollect线程，那个线程大概会执行10s，所以这里等待10s以上再进行下一步
		detectFinish()
		#mouse.position = confirm_pos #delay for wifi panel close
		#time.sleep(0.2) #delay for wifi panel close
		#click() #delay for wifi panel close
		time.sleep(3)
		auto_count = auto_count + 1
		print(auto_count)
		if auto_count == 195:
			print('reached 195')
			break
		detectReady()#是否准备领取下一个箱子
	if closeWhenFinished:
		mouse.position = game_close_pos
		time.sleep(1)
		click()
	return

def detectFinish():
	#for i in range(20):
	#	im = ImageGrab.grab(bbox=confirm_bbox)
	#	im.save("confirmtemp.png")
	#	confirmtemp = plt.imread("confirmtemp.png")
	#	result = compareImg(confirmtemp, confirm_target)
	#	time.sleep(3)
	#	if result:
	#		break
	#finish = False
	for i in range(125):
		time.sleep(0.4)
		with mss() as sct:
			monitor = sct.monitors[1]
			pixel = sct.grab((1017, 326, 1018, 327)).pixels[0][0] #截取一个2x2的像素，取第1个点
		if pixel != (117, 71, 73):
			time.sleep(4)
			break


def detectReady():
	loading = True
	count = 0
	while loading:
		if count >= 6:
			restartGuild()
			time.sleep(10)
		reopen()
		time.sleep(2)
		for i in range(10):
			im = ImageGrab.grab(bbox=open_bbox)
			im.save("opentemp.png")
			opentemp = plt.imread("opentemp.png")
			result = compareImg(opentemp, open_target)
			time.sleep(3)
			if result:
				loading = False
				break	
		count += 1

def on_press(key):
	try:
		if key.char == 'p':
			return False;
		elif key.char == 'q':
			getMousePosition()
		elif key.char == 'f':
			pray()
		elif key.char == 'x':
			collect()
		elif key.char == 'z':
			reopen()
		elif key.char == 'b':
			fightBoss()
		elif key.char == 'u':
			autoCollect()
		elif key.char == 't':
			test()
	except:
		print('unknown input key')

def on_release(key):
	return;

with keyboard.Listener(
		on_press = on_press,
		on_release = on_release
	) as listener:
	listener.join()