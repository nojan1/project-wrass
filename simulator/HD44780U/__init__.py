import pygame

COLS = 20
ROWS = 2

BLACK_BORDER_WIDTH = 15
DESIRED_FONT_SIZE = 48
CHAR_CELL_SPACING = 8
LCD_BACKGROUND = (0, 100, 0)
CHAR_CELL_FOREGROUND_COLOR=(10,10,10)
CHAR_CELL_BACKGROUND_COLOR=(0,180,0)

class HD44780U(object):
    def __init__(self):
        pygame.init()

        #self.font = pygame.font.SysFont("monospace", DESIRED_FONT_SIZE, bold=True)
        self.font = pygame.font.Font("HD44780U/VCR_OSD_MONO_1.001.ttf", DESIRED_FONT_SIZE)

        (font_width, font_height) = self.font.size("H")
        self.char_cell_width = font_width + 2
        self.char_cell_height = font_height + 2

        self.total_width = (BLACK_BORDER_WIDTH * 2) + (self.char_cell_width * COLS) + (CHAR_CELL_SPACING * (COLS + 1))
        self.total_height = (BLACK_BORDER_WIDTH * 2) + (self.char_cell_height * ROWS) + (CHAR_CELL_SPACING * (ROWS + 1))
        self.screen = pygame.display.set_mode((self.total_width, self.total_height))

        self.last_e = 0

        self.char_buffer = [" "] * (COLS * ROWS)
        self.position = 0

        self.on_data_returned = None

        self.draw()

    def draw(self):
        self.screen.fill((0,0,0))
        self.screen.fill(LCD_BACKGROUND, (BLACK_BORDER_WIDTH, BLACK_BORDER_WIDTH, self.total_width - (BLACK_BORDER_WIDTH * 2), self.total_height - (BLACK_BORDER_WIDTH * 2)))

        for i,c in enumerate(self.char_buffer):
            x_pos = BLACK_BORDER_WIDTH + ((CHAR_CELL_SPACING + self.char_cell_width) * (i % COLS)) + CHAR_CELL_SPACING
            y_pos = BLACK_BORDER_WIDTH + ((CHAR_CELL_SPACING + self.char_cell_height) * int(i / COLS)) + CHAR_CELL_SPACING

            self.screen.fill(CHAR_CELL_BACKGROUND_COLOR, (x_pos, y_pos, self.char_cell_width, self.char_cell_height))

            font_surface = self.font.render(c, False, CHAR_CELL_FOREGROUND_COLOR)
            self.screen.blit(font_surface, (x_pos + 1, y_pos + 1))

        pygame.display.flip()

    def handle_events(self):
        for _ in pygame.event.get():
            pass

        pygame.display.update()

    def command(self, e, rw, rs, data):
        print(f"got command e:{e}, last_e:{self.last_e}, rw: {rw}, rs: {rs}, data: {data}")
        if self.last_e == 0 and e == 1:
            self._process_command(rw, rs, data)                
            
        self.last_e = e
        self.draw()

    def _process_command(self, rw, rs, data):
        print(f"Processing command rw: {rw}, rs: {rs}, data: {data}")

        if rs == 0:
            #Instruction
            if rw == 1:
                #Output busy flag
                data_out = self.position & 0x7
                if self.on_data_returned != None:
                    self.on_data_returned(data_out)
            elif data == 1:
                # Clear home
                self.position = 1
                for i in range(COLS * ROWS):
                    self.char_buffer[i] = " "
        else:
            #Data
            if rw ==0:
                print(f"Wrote {data} to {self.position}")
                self.char_buffer[self.position] = self._get_char(data)
                self.position += 1
            else:
                print(f'Reading {self.char_buffer[self.position]}')

    def _get_char(self, data):
        return chr(data)