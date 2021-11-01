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

        self.last_instruction = 0x00
        self.last_data = 0x00
        self.last_rw = 0x00
        self.last_rs = 0x00
        self.last_e = 0x00

        self.char_buffer = [" "] * (COLS * ROWS)
        self.char_buffer[0] = "H"
        self.char_buffer[1] = "e"
        self.char_buffer[2] = "l"
        self.char_buffer[3] = "l"
        self.char_buffer[4] = "o"

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
        for e in pygame.event.get():
            pass

    def command(self, e, rw, rs, data):
        pass
