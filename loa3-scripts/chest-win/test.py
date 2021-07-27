import time
print("Hello, World!");

def fuck(pos, wait=2):
	print(pos)
	time.sleep(wait)
	print("wait finish")
	
fuck(wait=5, pos=100)