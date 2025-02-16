; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------

.export   _init, _exit
.import   _main, _putchar

.export   __STARTUP__ : absolute = 1                    ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__ 			        ; Linker generated

.import    copydata, zerobss, initlib, donelib, init_system

.include  "zeropage.inc"

.segment  "STARTUP"

;-------------------------------------------------------------------------------
; Set hardware stack
;-------------------------------------------------------------------------------
_init:
	ldx #$FF
	txs
	cld
;-------------------------------------------------------------------------------
; Initialize softstack pointer
;-------------------------------------------------------------------------------
 	lda #<(__RAM_START__ + __RAM_SIZE__)
    sta sp
    lda #>(__RAM_START__ + __RAM_SIZE__)
    sta sp+1

;-------------------------------------------------------------------------------
; Initialize memory
;-------------------------------------------------------------------------------
    jsr zerobss                 ; Clear BSS segment
    jsr copydata                ; Initialize DATA segment
    jsr initlib                 ; Run constructors

;-------------------------------------------------------------------------------
; Initialize system (UART)
;-------------------------------------------------------------------------------
    jsr init_system

;-------------------------------------------------------------------------------
; Run main routine
;-------------------------------------------------------------------------------
    jsr _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break
;-------------------------------------------------------------------------------
_exit:    
    jsr donelib                 ; Run destructors
    rts
