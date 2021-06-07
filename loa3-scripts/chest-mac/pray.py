#coding=utf-8
#coding=gbk
from pynput import keyboard
from pynput.mouse import Button, Controller
import time
import threading
import pyscreenshot as ImageGrab
import numpy as np
import matplotlib.pyplot as plt

mouse = Controller()

global thread

open_pos = (579, 822)
confirm_pos = (890, 898)

close_pos = (1311, 263)
vault_pos = (1160, 439)

boss_pos = (970, 903)

test_input = (10, 100)

account1_pos = (10, 100)
account2_pos = (10, 100)
account3_pos = (10, 100)

tab1_pos = (10, 100)
tab2_pos = (10, 100)
tab3_pos = (10, 100)

tab1_close_pos = (10, 100)
tab2_close_pos = (10, 100)
tab3_close_pos = (10, 100)

guild_icon_pos = (10, 100)
guild_contribute_pos = (10, 100)
boss_icon_pos = (10, 100)
#confirm_target = plt.imread("confirmtarget.png")
#open_target = plt.imread("opentarget.png")

def getMousePosition():
	print(mouse.position)

def click():
	mouse.press(Button.left)
	time.sleep(0.05)
	mouse.release(Button.left)
	#mouse.click(Button.left)

def clickPosition(position):
	mouse.position = position
	time.sleep(0.2)
	mouse.press(BUtton.left)
	time.sleep(0.05)
	mouse.release(Button.left)
	time.sleep(0.2)


def pray():
	for num in range (1, 6):
		mouse.position = (950, 874)
		time.sleep(0.2)
		click()
		time.sleep(1)
		mouse.position = (884, 737)
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
			sum_a = a[i][j][0] + a[i][j][1] + a[i][j][2]
			sum_b = b[i][j][0] + b[i][j][1] + b[i][j][2]
			if sum_a == sum_b:
				equal_num += 1
	sim_rate = equal_num / total_num
	#print(sim_rate);
	if sim_rate >= 0.98:
		return True
	else:
		return False


def test():
	#im = ImageGrab.grab(bbox=(532,808,627,841))
	#im.save("opentarget.png")
	return

def on_press(key):
	try:
		if key.char == 'p':
			return False;
		elif key.char == 'q':
			getMousePosition()
		elif key.char == 'f':
			pray()
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