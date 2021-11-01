from py65.devices.mpu65c02 import MPU as CMOS65C02
from py65.memory import ObservableMemory
from py65.monitor import Monitor
from py65.utils import console

from HD44780U import HD44780U
from via import VIA

class StepAwareCMOS65C02(CMOS65C02):
	def __init__(self, *args, **kwargs):
		CMOS65C02.__init__(self, *args, **kwargs)

		self.on_step = None

	def step(self):
		if self.on_step != None:
			self.on_step()

		CMOS65C02.step(self)
		return self

def main():
	mem = ObservableMemory()

	for i in range(1024):
		mem[i] = 0xea

	mem[1024] = 0x4c

	hdd4478 = HD44780U()
	via = VIA(0x6000, mem)
	via.SetOutputChanged(lambda x: lcd_mapping(x, hdd4478))

	monitor = Monitor(mpu_type=StepAwareCMOS65C02, memory=mem)

	monitor._mpu.on_step = hdd4478.handle_events

	try:
		monitor.cmdloop()
	except KeyboardInterrupt:
		monitor._output('')
		#console.restore_mode()

def lcd_mapping(updated_state, hdd4478):
	(PORTA, PORTB) = updated_state
	print(f"Got updated state {updated_state}")
	hdd4478.command(0, 1, 0x55)

if __name__ == "__main__":
	main()
