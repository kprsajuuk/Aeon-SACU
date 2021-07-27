import pyscreenshot as ImageGrab
import numpy as np
import matplotlib.pyplot as plt

warning_target = plt.imread("warningtarget.png")
pray_target = plt.imread("praytarget.png")
bossicon_target = plt.imread("bossicontarget.png")
bossicon_target2 = plt.imread("bossicontarget2.png")
bossfinish_target = plt.imread("bossfinishtarget.png")
chest_target = plt.imread('chesttarget.png')
eventclose_target = plt.imread("eventclosetarget.png")

def detectWarningResult():
	im = ImageGrab.grab(bbox=(979,261,989,270))
	im.save("warningtemp.png")
	warning_temp = plt.imread("warningtemp.png")
	result = compareImg(warning_temp, warning_target)
	return result

def detectPrayResult():
	im = ImageGrab.grab(bbox=(697,617,708,640))
	im.save("praytemp.png")
	pray_temp = plt.imread("praytemp.png")
	result = compareImg(pray_temp, pray_target)
	return result

def detectBossIconResult():
	im = ImageGrab.grab(bbox=(1030,164,1044,176))
	im.save("bosstemp.png")
	boss_temp = plt.imread("bosstemp.png")
	result = compareImg(boss_temp, bossicon_target)
	if result:
		return result
	else:
		return compareImg(boss_temp, bossicon_target2)	

def detectBossFinishResult():
	im = ImageGrab.grab(bbox=(734,656,768,678))
	im.save("bossfinishtemp.png")
	bossfinish_temp = plt.imread("bossfinishtemp.png")
	result = compareImg(bossfinish_temp, bossfinish_target)
	return result

def detectChestAreaResult():
	im = ImageGrab.grab(bbox=(679,393,809,475))
	im.save("chesttemp.png")
	chest_temp = plt.imread("chesttemp.png")
	result = compareImg(chest_temp, chest_target)
	return result	

def detectEventCloseResult():
	im = ImageGrab.grab(bbox=(1111,154,1127,169))
	im.save("eventclosetemp.png")
	eventclose_temp = plt.imread("eventclosetemp.png")
	result = compareImg(eventclose_temp, eventclose_target)
	return result			

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
	if sim_rate >= 0.85:
		return True
	else:
		return False