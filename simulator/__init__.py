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

	hdd4478 = HD44780U()

	via = VIA(0x6000, mem)
	via.SetOutputChanged(lambda x: lcd_mapping(x, hdd4478))

	def hdd4478_data_out(data):
		mem._subject[0x6000] = data

	hdd4478.on_data_returned = hdd4478_data_out

	monitor = Monitor(mpu_type=StepAwareCMOS65C02, memory=mem)

	monitor._mpu.on_step = hdd4478.handle_events

	try:
		monitor.cmdloop()
	except KeyboardInterrupt:
		monitor._output('')
		#console.restore_mode()

def lcd_mapping(updated_state, hdd4478):
	(PORTA, PORTB) = updated_state

	e = (PORTA & 0b10000000) >> 7
	rw = (PORTA & 0b01000000) >> 6
	rs = (PORTA & 0b00100000) >> 5

	hdd4478.command(e, rw, rs, PORTB)

if __name__ == "__main__":
	main()
