#coding=utf-8
#coding=gbk
import sys
from pynput import keyboard
from pynput.mouse import Button, Controller
#from pynput.keyboard import Key
#from pynput.keyboard import Controller as keyController
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
import os

mouse = Controller()
#keyboardCtl = keyController()
wifi = pywifi.PyWiFi()
iface = wifi.interfaces()[0]

global thread

closeWhenFinished = True

open_pos = (579, 822)
confirm_pos = (890, 898)

close_pos = (1311, 263)
vault_pos = (1160, 439)

boss_pos = (970, 903)

refresh_pos = (563, 160) #刷新游戏的按钮
scroll_icon = (1402, 971)
guild_icon = (1183, 962)

game_close_pos = (270, 158)

confirm_bbox = (847,887,947,919)
open_bbox = (566,817,593,829)

start_game_pos = (791, 420) #开始游戏按钮
select_loa3_pos = (371, 311) #选择loa3的按钮
main_page_pos = (424, 181)   #点击"主页"
gtarcade_pos = (1076, 1075)

wifi_icon_pos = (1512, 12)
wifi_toggle_pos = (1748, 47)

task_open = (1443.0, 282.0)
task_close = (1507.0, 254.0)
left_arrow = (294.0, 586.0)
right_arrow = (1490.0, 586.0)
attack_5 = (1160.0, 659.0)
attack_10 = (1159.0, 551.0)
close_result = (1210.0, 312.0)
clost_task = (1264.0, 478.0)
l39 = [(1343, 377), (1383, 592), (1060, 453), (891, 597), (1120, 776), (844, 818), (599, 700), (379, 602)]
l38 = [(1395, 411),(1148, 448),(1268, 592),(1050, 683),(870, 594),(910, 409),(669, 433),(478, 570)]
l37=l38
l36 = [(772, 400),(529, 492),(569, 698),(807, 718),(973, 501),(1193, 405),(1378, 508),(1247, 683)]
l35 = [(520, 534),(708, 436),(912, 471),(767, 604),(812, 786),(1020, 670),(1167, 548),(1334, 643)]
l34 = [(546, 755),(715, 809),(886, 764),(1041, 788),(1213, 721),(1093, 574),(927, 596),(772, 556)]
l33=l39
l32=l38
l31=l39
l30 = [(654, 481),(407, 609),(694, 743),(894, 642),(967, 842),(1174, 851),(1108, 679),(1372, 648)]
l29=l39
l28 = [(720, 424),(530, 495),(569, 739),(849, 657),(1062, 506),(1335, 545),(1130, 737),(1343, 804)]
l27=l38
l26=l36
l25=l38
l24 = [(487, 574),(669, 433),(910, 413),(870, 600),(1039, 765),(1240, 732),(1214, 510),(1372, 445)]
l23=l38
l22=l28
l21 = [(526, 512),(546, 740),(760, 646),(947, 525),(999, 673),(1214, 510),(1240, 734),(1391, 658)]
l20=l39
task_list = [l39, l38, l37, l36, l35, l34, l33, l32, l31, l30, l29, l28, l27, l26, l25, l24, l23, l22, l21, l20]
#task_list = [l30, l29, l28, l27, l26, l25, l24, l23, l22, l21, l20]
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


#wifi_name = "PKUSE"
#wifi_pass = "Bdsoft61137666"

wifi_name = "sscz_8DE0"
#wifi_name = "sscz_2"
wifi_pass = "blackhole"

test_input = (10, 100)
confirm_target = plt.imread("confirmtarget.png")
open_target = plt.imread("opentarget.png")

wifiConnected = False
totalCollectCount = 195
restartCount = 0

def getMousePosition():
	print(mouse.position)

def click():
	mouse.press(Button.left)
	time.sleep(0.05)
	mouse.release(Button.left)
	#mouse.click(Button.left)

def tryConnection(profile):
	print('try con start')
	success = False
	count = 0
	while(not success):
		if (count > 12):
			os.system("networksetup -setairportpower en0 on") #重新打开wifi
			time.sleep(5)
			count = 0
		count += 1
		print("try time: " + str(count))
		try:
			iface.connect(profile)
			print('iface connected')
		except:
			print('iface connect error, connection attempt fail')
		time.sleep(4)
		print('compare')
		if not iface.status() == const.IFACE_CONNECTED:
			print('not equal')
		else:
			print('con success')
			success = True
			time.sleep(5)

def connectWifi():
	profile = pywifi.Profile()
	profile.ssid = wifi_name
	profile.auth = const.AUTH_ALG_OPEN
	profile.akm.append(const.AKM_TYPE_WPA2PSK)
	profile.cipher = const.CIPHER_TYPE_CCMP
	profile.key = wifi_pass
	iface.remove_all_network_profiles()
	tmp_profile = iface.add_network_profile(profile)
	#mouse.position = wifi_icon_pos
	#time.sleep(0.2)
	#click()
	#time.sleep(0.2)
	#mouse.position = confirm_pos
	time.sleep(0.2)
	tryConnection(tmp_profile)
	mouse.position = confirm_pos
	time.sleep(0.2)
	click()
	time.sleep(0.2)
	global wifiConnected
	wifiConnected = True

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

	os.system("networksetup -setairportpower en0 off") #直接关闭wifi
	global wifiConnected
	wifiConnected = False
	#iface.disconnect()
	time.sleep(1.6)
	
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
	time.sleep(0.1)
	os.system("networksetup -setairportpower en0 on") #重新打开wifi
	time.sleep(1)
	os.system("networksetup -setairportpower en0 on") #重新打开wifi
	#os.system("networksetup -setairportpower airport on") #重新打开wifi
	time.sleep(1)
	connectWifi()
	#iface.disconnect()

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

def restartGuild(restartWifi=True):	
	print('====================restart guild!======================')
	global restartCount
	restartCount = restartCount + 1
	if restartWifi:
		os.system("networksetup -setairportpower en0 on") #防止wifi因意外情况被关闭
		time.sleep(0.3)
		connectWifi()
	time.sleep(8)
	mouse.position = refresh_pos
	time.sleep(1)
	click()
	time.sleep(50)
	mouse.position = scroll_icon
	time.sleep(1)
	click()
	time.sleep(2)
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
	#os._exit(0)
	print(wifiConnected)
	#restartGuild()
	#im = ImageGrab.grab(bbox=(566,817,593,829))
	#im.save("test.png")
	#rgb = PIL.ImageGrab.grab().load()[2042,656]
	#print(rgb)
	#for i in range(125):
	#	time.sleep(0.4)
	#	with mss() as sct:
	#		monitor = sct.monitors[1]
	#		pixel = sct.grab((1017, 326, 1018, 327)).pixels[0][0]
	#		print(pixel)
			#mss.tools.to_png(im.rgb, im.size, output="testscreenshot.png")
			#rgb = Image.frombytes('RGB', sct_img.size, sct_img.bgra, 'raw', 'BGRX')
			#print(rgb[100, 100])
		#rgb = PIL.ImageGrab.grab().load()[2042,656]
		
	#print(PIL.ImageGrab.grab().size)
	#keyboardCtl.press('p')
	#keyboardCtl.release('p')

def startAndCollect():
	print('start in 10s')
	time.sleep(11)
	mouse.position = gtarcade_pos
	time.sleep(1)
	click()
	time.sleep(5)
	mouse.position = main_page_pos
	time.sleep(1)
	click()
	time.sleep(5)
	mouse.position = select_loa3_pos
	time.sleep(1)
	click()
	time.sleep(5)
	mouse.position = start_game_pos
	time.sleep(1)
	click()
	time.sleep(5)
	restartGuild(False)
	time.sleep(10)
	reopen()
	time.sleep(2)
	autoCollect()

def autoCollect():
	if len(sys.argv) > 1:
		global totalCollectCount 
		totalCollectCount = int(sys.argv[1])
	thread = threading.Thread(target=autoCollectThread)
	thread.start()

def autoCollectThread():
	print('auto collect start in 10s')
	time.sleep(10)
	auto_count = 0
	for i in range(195):
		collect()
		time.sleep(11) #collect方法里1的collectActionThread线程大概会执行10s，所以这里等待10s以上再进行下一步
		detectFinish()
		#mouse.position = confirm_pos #delay for wifi panel close
		#time.sleep(0.2) #delay for wifi panel close
		#click() #delay for wifi panel closep
		time.sleep(3)
		auto_count = auto_count + 1
		print(auto_count)
		if auto_count == totalCollectCount:
			print('reached ' + str(totalCollectCount))
			print('total restart:')
			print(restartCount)
			break
		detectReady()#是否准备领取下一个箱子
		time.sleep(3)
	if closeWhenFinished:
		mouse.position = game_close_pos
		time.sleep(1)
		click()
		time.sleep(10)
		os._exit(0)
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
	print("detecting finish......")
	count = 0
	while(not wifiConnected):
		time.sleep(5)
		count += 1
	print("detection done!")
	time.sleep(5)
	#for i in range(200):
	#	time.sleep(0.4)
	#	with mss() as sct:
	#		monitor = sct.monitors[1]
	#		pixel = sct.grab((1017, 326, 1018, 327)).pixels[0][0] #截取一个2x2的像素，取第1个点
	#	if pixel != (117, 71, 73):
	#		time.sleep(4)
	#		break


def detectReady():
	loading = True
	count = 0
	while loading:
		if count >= 2:
			time.sleep(5)
			restartGuild()
			time.sleep(5)
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

def tripForExp():
	print("trip for exp starting in 5s")
	time.sleep(5)
	thread = threading.Thread(target=tripThread)
	thread.start()

def tripThread():
	mouse.position = task_open
	time.sleep(1)
	click()
	time.sleep(0.5)
	click()
	time.sleep(3)
	for task in task_list:
		for i in task:
			mouse.position = i
			time.sleep(0.5)
			click()
			time.sleep(3)
			mouse.position = attack_5
			time.sleep(0.5)
			click()
			time.sleep(7)
			mouse.position = close_result
			time.sleep(0.5)
			click()
			time.sleep(1.5)
			mouse.position = attack_10
			time.sleep(0.5)
			click()
			time.sleep(10)
			mouse.position = close_result
			time.sleep(0.5)
			click()
			time.sleep(1.5)
			mouse.position = clost_task
			time.sleep(0.5)
			click()
			time.sleep(1.5)
		mouse.position = left_arrow
		time.sleep(0.5)
		click()
		time.sleep(2)
	time.sleep(4)
	mouse.position = task_close
	time.sleep(1)
	click()
	time.sleep(3)
	return



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
		elif key.char == 'l':
			tripForExp()
		elif key.char == 't':
			test()
		elif key.char == 'o':
			startAndCollect()
	except:
		print('unknown input key')

def on_release(key):
	return;

with keyboard.Listener(
		on_press = on_press,
		on_release = on_release
	) as listener:
	listener.join()