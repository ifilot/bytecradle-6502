; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------

.import __HEADER_LOAD__                     ; import start location

.export   _init, _exit
.import   _main, _charout

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__       ; Linker generated

.import    copydata, zerobss, initlib, donelib

.include  "zeropage.inc"

; ---------------------------------------------------------------------------

.segment "HEADER"

.word __HEADER_LOAD__

; ---------------------------------------------------------------------------

.segment  "STARTUP"

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer
; ---------------------------------------------------------------------------
_init:

          LDA     #<(__RAM_START__ + __RAM_SIZE__)
          STA     sp
          LDA     #>(__RAM_START__ + __RAM_SIZE__)
          STA     sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage
; ---------------------------------------------------------------------------

          JSR     zerobss              ; Clear BSS segment
          JSR     copydata             ; Initialize DATA segment
          JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------
; Call main()
; ---------------------------------------------------------------------------

          JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break
; ---------------------------------------------------------------------------

_exit:    JSR     donelib              ; Run destructors
          RTS