
PORTB = 0
PORTA = 1
DDRB = 2
DDRA = 3

class VIA(object):
    def __init__(self, first_address, memory):
        self.first_address = first_address
        self.output_changed = None

        self.DDRA = 0
        self.DDRB = 0
        self.PORTA = 0
        self.PORTB = 0

        addreses = [first_address+x for x in range(15)]
        memory.subscribe_to_write(addreses, self.OnWrite)
        memory.subscribe_to_read(addreses, self.OnRead)

        self.registers = [0x00] * 16

    def OnRead(self, addr):
        register_index = addr - self.first_address
        return self.registers[register_index]

    def OnWrite(self, addr, data):
        register_index = addr - self.first_address

        if register_index == PORTA:
            data = data & self.registers[DDRA]
        elif register_index == PORTB:
            data = data & self.registers[DDRB]

        print(f"Setting index {register_index} to {data}")
        self.registers[register_index] = data

        if self.output_changed != None:
            self.output_changed((self.registers[PORTA], self.registers[PORTB]))

    def SetOutputChanged(self, callback):
        self.output_changed = callback

    