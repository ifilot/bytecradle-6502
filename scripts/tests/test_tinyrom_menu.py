"""Run with python3 scripts/tests/test_tinyrom_menu.py (requires cc65 and py65).

Assemble in a temporary directory and execute real 65C02 code. Only serial
putch/getch are intercepted; menu rendering, dispatch, and stack operations run.
"""
from collections import deque
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

from py65.devices.mpu65c02 import MPU

SOURCE = Path(__file__).resolve().parents[2] / 'src/environments/tinyrom'


class MenuTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix='tinyrom-test-')
        cls.addClassCleanup(cls.temp.cleanup)
        build = Path(cls.temp.name)
        for source in SOURCE.iterdir():
            if source.suffix in ('.s', '.inc', '.cfg'):
                shutil.copy2(source, build / source.name)
        (build / 'gitid.s').write_text('.export gitid\n.segment "DATA"\ngitid: .asciiz "test"\n')
        objects = []
        for source in sorted(build.glob('*.s')):
            obj = source.with_suffix('.o').name
            subprocess.run(['ca65', '-g', source.name, '-o', obj], cwd=build, check=True)
            objects.append(obj)
        linked = subprocess.run(['ld65', '-C', 'rom.cfg', '-o', 'rom.bin',
                                 '--dbgfile', 'rom.dbg', *objects], cwd=build,
                                check=True, capture_output=True, text=True)
        if linked.stderr:
            raise AssertionError(linked.stderr)
        cls.rom = (build / 'rom.bin').read_bytes()
        cls.symbols = dict((name, int(value, 16)) for name, value in re.findall(
            r'^sym\s+.*?name="([^"]+)".*?val=0x([0-9A-Fa-f]+)',
            (build / 'rom.dbg').read_text(), re.M))

    def setUp(self):
        self.cpu = MPU()
        self.cpu.memory[0x8000:] = self.rom
        self.keys = deque()
        self.output = []

    def run_until_idle(self, keys='', stop=None):
        self.keys.extend(map(ord, keys))
        for _ in range(2_000_000):
            if self.cpu.pc == stop:
                return
            if self.cpu.pc == self.symbols['putch']:
                self.output.append(chr(self.cpu.a))
                self.cpu.pc = (self.cpu.stPopWord() + 1) & 0xffff
            elif self.cpu.pc == self.symbols['getch']:
                if not self.keys:
                    return
                self.cpu.a = self.keys.popleft()
                self.cpu.pc = (self.cpu.stPopWord() + 1) & 0xffff
            else:
                self.cpu.step()
        self.fail('CPU did not return or wait for input')

    def print_table(self, address):
        self.cpu.a, self.cpu.x = address & 255, address >> 8
        self.cpu.pc = self.symbols['printmenu']
        self.cpu.sp = 255
        self.cpu.stPushWord(0x02ff)
        self.output.clear()
        self.run_until_idle(stop=0x0300)
        self.assertEqual(self.cpu.pc, 0x0300)
        self.assertEqual(self.cpu.sp, 255)
        return ''.join(self.output)

    def test_every_string_offset_and_table_page_crossing(self):
        for offset in range(256):
            address = 0x3000 + offset
            self.cpu.memory[address:address + 6] = b'HELLO\0'
            # The first pointer itself straddles a page boundary.
            self.cpu.memory[0x20ff:0x2105] = [address & 255, address >> 8, 255, 255, 0, 0]
            self.assertEqual(self.print_table(0x20ff),
                             '| HELLO' + ' ' * 40 + '|\r\n+' + '-' * 46 + '+\r\n')

    def test_all_real_tables(self):
        for name in ('mainmenu_table', 'testmenu_table', 'gamesmenu_table',
                     'appmenu_table', 'daughterboardmenu_table', 'pispigottable',
                     'gameoflifetable', 'startingpositiontable'):
            address = self.symbols[name]
            expected = []
            for offset in range(0, 256, 2):
                lo, hi = self.cpu.memory[address + offset:address + offset + 2]
                pointer = lo + (hi << 8)
                if pointer == 0:
                    break
                if pointer == 0xffff:
                    expected.append('+' + '-' * 46 + '+\r\n')
                else:
                    chars = []
                    while self.cpu.memory[pointer]:
                        chars.append(chr(self.cpu.memory[pointer]))
                        pointer += 1
                    text = ''.join(chars)
                    self.assertLessEqual(len(text), 45)
                    expected.append('| ' + text.ljust(45) + '|\r\n')
            else:
                self.fail(f'{name} has no terminator')
            self.assertEqual(self.print_table(address), ''.join(expected), name)

    def test_navigation_and_application_returns(self):
        self.cpu.pc = self.symbols['mainmenu']
        self.run_until_idle()
        baseline = self.cpu.sp
        for _ in range(150):
            # All categories, an ordinary RTS application, monitor Q, Pi Q,
            # Conway B, and Conway special-menu B followed by B.
            for sequence in ('tb', 't1b', 'gb', 'ab', 'db', 'mq\r', 'a2qb', 'g2bb', 'g2mbbb'):
                self.run_until_idle(sequence)
                self.assertEqual(self.cpu.sp, baseline, sequence)
                self.assertEqual(self.cpu.memory[7] + 256 * self.cpu.memory[8],
                                 self.symbols['mainmenu_entries'], sequence)
                self.output.clear()

    def test_conway_start_step_and_quit(self):
        self.cpu.pc = self.symbols['mainmenu']
        self.run_until_idle()
        baseline = self.cpu.sp
        # A terminal cursor report supplies screen size; place a cell and step.
        self.run_until_idle('g2 \x1b[24;80R x\x1b[1;2Rrqb')
        self.assertEqual(self.cpu.sp, baseline)
        self.assertIn('CONWAYS GAME OF LIFE', ''.join(self.output))
        self.assertEqual(self.cpu.memory[7] + 256 * self.cpu.memory[8],
                         self.symbols['mainmenu_entries'])
        self.run_until_idle('g2m1\x1b[24;80Rqb')
        self.assertEqual(self.cpu.sp, baseline)
        self.assertEqual(self.cpu.memory[7] + 256 * self.cpu.memory[8],
                         self.symbols['mainmenu_entries'])


if __name__ == '__main__':
    unittest.main()
