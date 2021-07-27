from pynput import keyboard
from pynput.mouse import Button, Controller
import pyscreenshot as ImageGrab
import time
from graphDetect import *

mouse = Controller()

trial_target = plt.imread("trialtarget.png")
trial_target2 = plt.imread("trialtarget2.png")
add_target = plt.imread("addtarget.png")

trial_icon_pos = (859, 170)
trial_exp_pos = (814, 189)
trial_add_pos = (635, 661)
trial_buy_pos = (891, 364)
trial_buy_confirm_pos = (668, 496)
trial_buy_close_pos = (941, 279)
trial_execute_pos = (976, 657)
trial_claim_pos = (732, 390)
trial_close_pos = (1118, 146)


super_login_icon_pos = (1028, 419)
super_claim = (438, 663)
super_random = (1053, 670)
super_scroll = (1146, 467)
super_money_select = (800, 450)
super_daily_claim = (864, 663)
super_close = (1140, 164)
rose_icon = (345, 232)
rose_money_select = (563, 402)
rose_claim = (732, 686)
rose_claim_confirm = (677, 510)
rose_close = (1141, 165)


def clickPosition(pos, delay=0, wait=0,):
	mouse.position = pos
	time.sleep(0.2)
	time.sleep(delay)
	mouse.press(Button.right)
	time.sleep(0.05)
	mouse.release(Button.right)
	time.sleep(0.2)
	time.sleep(wait)

def detectTrialReslt():
	im = ImageGrab.grab(bbox=(851,166,863,169))	
	im.save("trialtemp.png")
	trial_temp = plt.imread("trialtemp.png")
	result = compareImg(trial_temp, trial_target)
	if result:
		return result
	else:
		return compareImg(trial_temp, trial_target2)

def detectAddResult():
	im = ImageGrab.grab(bbox=(627,656,641,669))
	im.save("addtemp.png")
	add_temp = plt.imread("addtemp.png")
	result = compareImg(add_temp, add_target)
	return result

def trialProgress():
	if not detectTrialReslt():
		print('未检测到试炼按钮')
		return
	clickPosition(trial_icon_pos, delay=1, wait=2)
	clickPosition(trial_exp_pos, delay=1, wait=1)
	clickPosition(trial_execute_pos, delay=1, wait=2.2)

	for i in range(1, 30):
		if detectAddResult():
			clickPosition(trial_claim_pos, delay=1, wait=2)
			clickPosition(trial_add_pos, delay=1, wait=1)
			clickPosition(trial_buy_pos, delay=1, wait=1)
			clickPosition(trial_buy_confirm_pos, delay=1, wait=1)
			clickPosition(trial_buy_close_pos, delay=1, wait=1)
			clickPosition(trial_execute_pos, delay=1, wait=3)
			break
		time.sleep(10)
		
	
	clickPosition(trial_close_pos, delay=1, wait=1)

def monthEventProgress():
	clickPosition(super_login_icon_pos, delay=1, wait=5)
	clickPosition(super_claim, delay=1, wait=2)
	clickPosition(super_random, delay=1, wait=1)
	clickPosition(super_scroll, delay=1, wait=1)
	clickPosition(super_money_select, delay=1, wait=1)
	clickPosition(super_daily_claim, delay=1, wait=3)
	clickPosition(super_close, delay=1, wait=1)
	clickPosition(rose_icon, delay=1, wait=3)
	clickPosition(rose_money_select, delay=1, wait=1)
	clickPosition(rose_claim, delay=1, wait=1)
	clickPosition(rose_claim_confirm, delay=1, wait=2)
	clickPosition(rose_close, delay=1, wait=1)

def openSuperLogin():
	icon_pos1 = (512,353,527,364)
	icon_pos2 = (512,353,527,364)
	icon_pos3 = (566,354,583,364)
	icon_pos4 = (512,353,527,364)

	im = ImageGrab.grab(bbox=icon_pos1)	
	im.save("supertemp.png")
	super_temp = plt.imread("supertemp.png")
	super_target = plt.imread("supertarget_pos1.png")
	result = compareImg(super_temp, super_target)
	if result:
		clickPosition(super_login_icon_pos, delay=1, wait=4)
		return result
	else:
		return compareImg(super_temp, super_target)

	
	




