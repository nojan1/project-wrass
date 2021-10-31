import pygame
class HD44780U(object):
    def __init__(self):
        pygame.display.init()

        self.screen = pygame.display.set_mode((320, 240))

    def handle_events(self):
        for e in pygame.event.get():
            pass

    def command(self, e, rs, data):
        pass
