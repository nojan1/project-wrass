from py65.devices.mpu65c02 import MPU as CMOS65C02
from py65.memory import ObservableMemory
from py65.monitor import Monitor
from py65.utils import console

from HD44780U import HD44780U
from via import VIA

def main():
	mem = ObservableMemory()

	for i in range(1024):
		mem[i] = 0xea

	mem[1024] = 0x4c

	hdd4478 = HD44780U()
	via = VIA(0x6000, mem)
	monitor = Monitor(mpu_type=CMOS65C02, memory=mem)

	RunLoop(monitor).start()
	hdd4478.handle_events()

from threading import Thread
class RunLoop(Thread):
	def __init__(self, monitor):
		Thread.__init__(self)
		self.monitor = monitor
	
	def run(self) -> None:
		try:
			self.monitor.cmdloop()
		except KeyboardInterrupt:
			self.monitor._output('')
			#console.restore_mode()

if __name__ == "__main__":
	main()
