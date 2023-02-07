#coding=utf-8
#coding=gbk
from pynput import keyboard
from pynput.mouse import Button, Controller
import time
import threading
import pyscreenshot as ImageGrab
import numpy as np
import matplotlib.pyplot as plt
from graphDetect import *
from extraProgress import *

mouse = Controller()

global thread

playWorldBoss = True

test_input = (10, 100)
mouse_blank_pos = (731, 663)

account1_pos = (141, 755) #ynumikol
account2_pos = (309, 755) #126
account3_pos = (467, 755) #163

tab0_pos = (388, 5)
tab1_pos = (539, 5)
tab2_pos = (729, 5)
tab3_pos = (919, 5)

tab1_close_pos = (618, 14)
tab2_close_pos = (805, 14)
tab3_close_pos = (992, 14)

tab_refresh_pos = (114, 43)
close_warning_pos = (984, 265)

guild_icon_pos = (1079, 713)
guild_contribute_pos = (811, 305)
guild_contribute_close_pos = (1063, 167)
guild_close_pos = (1121, 163)
event_close_pos = (1120, 163)
boss_icon_pos = (1029, 162)
boss_fight_pos = (753, 668)

contribute_btn_pos = (735, 626)
contribute_confirm_pos = (686, 519)
#confirm_target = plt.imread("confirmtarget.png")
#open_target = plt.imread("opentarget.png")

def getMousePosition():
	print(mouse.position)

def click():
	mouse.press(Button.right)
	time.sleep(0.05)
	mouse.release(Button.right)
	#mouse.click(Button.right)

def clickPosition(pos, delay=0, wait=0,):
	mouse.position = pos
	time.sleep(0.2)
	time.sleep(delay)
	mouse.press(Button.right)
	time.sleep(0.05)
	mouse.release(Button.right)
	time.sleep(0.2)
	time.sleep(wait)


def pray():
	for num in range (1, 6):
		mouse.position = contribute_btn_pos
		time.sleep(0.2)
		click()
		time.sleep(1)
		mouse.position = contribute_confirm_pos
		time.sleep(0.2)
		click()
		time.sleep(1)

def fightBoss():
	current = mouse.position
	mouse.position = boss_pos
	time.sleep(0.1)
	click()
	time.sleep(0.1)
	mouse.position = current

def autoPrayThread():
	thread = threading.Thread(target=prayThread)
	thread.start()

def prayThread():
	print('pray thread will start in 5s')
	time.sleep(6)
	account1Progress() #ynumikol
	time.sleep(3)
	account2Progress() #126
	time.sleep(3)
	account3Progress() #163

def account1Progress():
	clickPosition(account1_pos, delay=1, wait=1)
	#list = [(269, 108), (377, 108), (493, 108), (596, 108)]
	list = [(269, 108), (377, 108), (493, 108), (596, 108)]
	num = 0
	for pos in list:
		clickPosition(tab0_pos, delay=1, wait=1) 
		clickPosition(pos, wait=2)#打开三个
		clickPosition(tab1_pos, wait=5)
		clickPosition(tab2_pos, wait=5)
		clickPosition(tab3_pos, wait=5)
		time.sleep(2)
		for j in range(1, 4):
			clickPosition(tab1_pos, delay=1, wait=2)
			num += 1
			prayProgress('account1: ' + str(num))
			clickPosition(tab1_close_pos, delay=1, wait=2)
		time.sleep(3)
	print('account 1 finished')
	return

def account2Progress():
	clickPosition(account2_pos, delay=1, wait=1)
	#list = [(269, 134), (377, 134), (493, 134), (596, 134)]
	list = [(269, 134), (377, 134), (493, 134), (596, 134)]
	num = 0
	for pos in list:
		clickPosition(tab0_pos, delay=1, wait=1)
		clickPosition(pos, wait=2)#打开三个
		clickPosition(tab1_pos, wait=5)
		clickPosition(tab2_pos, wait=5)
		clickPosition(tab3_pos, wait=5)
		time.sleep(2)
		for j in range(1, 4):
			clickPosition(tab1_pos, delay=1, wait=2)
			num += 1
			prayProgress('account2: ' + str(num))
			clickPosition(tab1_close_pos, delay=1, wait=2)
		time.sleep(3)

	#extra
	extra_pos = (108, 137)
	clickPosition(tab0_pos, delay=1, wait=1)
	clickPosition(extra_pos, wait=2)
	clickPosition(tab1_pos, wait=20)
	num += 1
	prayProgress('account2: ' + str(num))
	clickPosition(tab1_close_pos, delay=1, wait=2)
	print('account 2 finished')
	return

def account3Progress():
	clickPosition(account3_pos, delay=1, wait=1)
	#list = [(269, 166), (377, 166), (493, 166), (596, 166)]
	list = [(269, 166), (377, 166), (493, 166), (596, 166)]
	num = 0
	for pos in list:
		clickPosition(tab0_pos, delay=1, wait=1)
		clickPosition(pos, wait=2)#打开三个
		clickPosition(tab1_pos, wait=5)
		clickPosition(tab2_pos, wait=5)
		clickPosition(tab3_pos, wait=5)
		time.sleep(2)
		for j in range(1, 4):
			clickPosition(tab1_pos, delay=1, wait=2)
			num += 1
			prayProgress('account3: ' + str(num))
			clickPosition(tab1_close_pos, delay=1, wait=2)
		time.sleep(3)

	#extra
	extra_pos = (108, 163)
	clickPosition(tab0_pos, delay=1, wait=1)
	clickPosition(extra_pos, wait=2)
	clickPosition(tab1_pos, wait=5)
	clickPosition(tab2_pos, wait=5)
	for j in range(1, 3):
			clickPosition(tab1_pos, delay=1, wait=2)
			num += 1
			prayProgress('account3: ' + str(num))
			clickPosition(tab1_close_pos, delay=1, wait=2)
	clickPosition(tab1_close_pos, delay=1, wait=2)
	print('account 3 finished')
	#打开两个
	return

def prayProgress(gameid):
	reachChest = False
	while not reachChest:
		openPageProgress()
		clickPosition(close_warning_pos, delay=1, wait=2)
		for x in range (1, 8):
			clickPosition(guild_icon_pos, delay=10, wait=3)
			clickPosition(guild_contribute_pos, delay=1, wait=3)
			if detectChestAreaResult():
				reachChest = True
				break
			if x >= 3:
				clickPosition(tab_refresh_pos, delay=1, wait=10)
				break
			time.sleep(3)

	for j in range(1, 6):
		pray()
		mouse.position = mouse_blank_pos
		time.sleep(1)
		if detectPrayResult():
			print(gameid + ' 已完成')
			break
		#判断pray是否完结，完结就break
	clickPosition(guild_contribute_close_pos, delay=1, wait=1)
	clickPosition(guild_close_pos, delay=1, wait=0.2)
	mouse.position = mouse_blank_pos
	time.sleep(1)
	if detectEventCloseResult():
		clickPosition(event_close_pos, delay=1, wait=1)
	mouse.position = mouse_blank_pos
	time.sleep(1)
	
	trialProgress()
	mouse.position = mouse_blank_pos
	time.sleep(1)

	#monthEventProgress()
	#mouse.position = mouse_blank_pos
	#time.sleep(1)
	#判断boss icon是否存在，在就点不在直接return
	if not playWorldBoss or not detectBossIconResult():
		print(gameid + ' 未进入')
		return
	clickPosition(boss_icon_pos, delay=1, wait=10)
	for k in range(1, 15):
		clickPosition(boss_fight_pos, delay=1, wait=9)
		if detectBossFinishResult():
			break
		
def openPageProgress():
	loading = True
	while loading:
		time.sleep(5)
		for i in range(1, 10): 
			if detectWarningResult():
				time.sleep(2)
				loading = False
				break
			time.sleep(5)
		if loading:
			clickPosition(tab_refresh_pos, delay=1, wait=1)
			time.sleep(5)
	return

def test():
	#monthEventProgress()
	#prayProgress()
	#print(detectWarningResult())
	#im = ImageGrab.grab(bbox=(627,656,641,669))
	#im.save("test.png")
	#trialProgress()
	return

def on_press(key):
	try:
		if key.char == 'p':
			return False
		elif key.char == 'q':
			getMousePosition()
		elif key.char == 'g':
			autoPrayThread()
		elif key.char == 't':
			test()
	except:
		print('unknown input key')

def on_release(key):
	return

with keyboard.Listener(
		on_press = on_press,
		on_release = on_release
	) as listener:
	listener.join()