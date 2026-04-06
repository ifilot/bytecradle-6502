;
; Global symbol imports used across multiple .s files
; This file should be included to access shared subroutines
;

.import _getch
.import _putch
.import _puthex
.import bcos_get_abi_major
.import bcos_get_abi_minor
.import bcos_reserved
.import char2nibble
.import char2num
.import chartoupper
.import clearline
.import getch
.import getpos
.import ischarvalid
.import isr
.import makecrctable
.import newcmdline
.import newline
.import printnibble
.import putch
.import putdec
.import putds
.import puthex
.import putspace
.import putstr
.import putstrnl
.import puttab
