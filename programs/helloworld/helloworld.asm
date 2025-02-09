; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

; textbuffer variables
.define TBPR		$02
.define TBPL		$03
.define TB              $0200		; store textbuffer in page 2
.define CMDBUF          $0300           ; position of command buffer
.define CMDLENGTH       $0310           ; number of bytes in buffer, max 16

.define LF		$0A		; LF character (line feed)
.define ESC		$1B		; VT100 escape character

; buffer addresses (ZP)
.define BUF1		$04
.define BUF2		$05
.define BUF3		$06
.define BUF4		$07
.define	BUF5		$08
.define BUF6		$09
.define STRLB  		$10		; string low byte
.define STRHB		$11		; string high byte
.define MALB		$14		; monitor address low byte
.define MAHB		$15		; monitor address high byte

.segment "CODE"

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
start:              ; reset vector points here
    lda #<hwstr		; load lower byte
    sta STRLB
    lda #>hwstr		; load upper byte
    sta STRHB
    jsr stringout
    rts

hwstr:
    .asciiz "Hello World!"

;-------------------------------------------------------------------------------
; STRINGOUT routine
; Garbles: A, Y
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
stringout:
    ldy #0
@nextchar:
    lda (STRLB),y	; load character from string
    beq @exit		; if terminating character is read, exit
    jsr charout		; else, print char
    iny			    ; increment y
    jmp @nextchar	; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAROUT routine
; Garbles: A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting. At 10 MhZ, we
; need to wait 1E7 * 10 / 115200 = 868 clock cycles. The combination of "DEC"
; and "BNE" both take 3 clock cyles, so we need about 173 iterations of these.
;-------------------------------------------------------------------------------
charout:
    pha			    ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #173		; initialize inner loop
@inner:
    dec             ; decrement A; 2 cycles
    bne @inner		; check if zero; 3 cycles
    pla
    rts

;-------------------------------------------------------------------------------
; interrupt service routine
;-------------------------------------------------------------------------------
isr:
    pha			    ; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; load byte
    phx
    ldx TBPR		; load pointer index
    sta TB,x        ; store character
    inc TBPR
    plx			    ; recover X
isr_exit:
    pla			    ; recover A
    rti

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word start         ; reset
    .word start         ; nmi
    .word isr           ; irq/brk
