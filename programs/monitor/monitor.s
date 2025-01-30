; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07
.define BREG		$9F00

; textbuffer variables
.define TBPR		$02
.define TBPL		$03
.define TB              $0200		; store textbuffer in page 2
.define CMDBUF          $0300           ; position of command buffer
.define CMDLENGTH       $0310           ; number of bytes in buffer, max 16
.define JUMPSTART       $0312
.define ROMSTART        $0400		; custom code to start a program on a different rom

.define LF		$0A		; LF character (line feed)
.define ESC		$1B		; VT100 escape character

; buffer addresses (ZP)
.define BUF1		$04
.define BUF2		$05
.define BUF3		$06
.define BUF4		$07
.define	BUF5		$08
.define BUF6		$09
.define BUF7		$0A
.define BUF8		$0B

; specific ZP addresses for the hexdump routine of the monitor
.define STARTADDR	$0C
.define ENDADDR		$0E
.define STRLB		$10		; string low byte
.define STRHB		$11		; string high byte
.define MALB		$14		; monitor address low byte
.define MAHB		$15		; monitor address high byte
.define NRLINES		$16		; number of lines to print by hexdump routine

.segment "CODE"

;-------------------------------------------------------------------------------
; Boot sequence
;-------------------------------------------------------------------------------
boot:                   ; reset vector points here
    sei                 ; disable interrupts
    cld                 ; clear decimal mode 

    ldx #$ff            ; initialize stack pointer to top of stack
    txs                 ; transfer x to stack pointer (sp)

    ldx #$00            ; prepare to clear the zero page
@nextbyte:
    stz $00,x           ; clear zero page by storing 0
    stz TB,x            ; clear textbuffer by storing 0
    inx                 ; increment x
    bne @nextbyte       ; loop until x overflows back to 0
    stz TBPL            ; reset textbuffer left pointer
    stz TBPR		; reset textbuffer right pointer
    stz CMDLENGTH       ; clear command length size

    jsr init_romstart
    jsr init_acia       ; initialize UART
    lda #<resetscroll
    sta STRLB
    lda #>resetscroll
    sta STRHB
    jsr stringout

    cli                 ; enable interrupts
    jmp main		; go to main routine

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001      ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts

;-------------------------------------------------------------------------------
; Copy romstart routine from ROM to RAM
;-------------------------------------------------------------------------------
init_romstart:
    ldx #0
@next:
    lda romstart,x
    sta ROMSTART,x
    inx
    cpx #$20
    bne @next

    lda #$FE
    sta JUMPSTART
    lda #$FF
    sta JUMPSTART+1
    lda #$6C		; optcode for indirect jump
    sta JUMPSTART-1
    rts

termbootstr:
    .byte ESC,"[2J",ESC,"[H"		; reset terminal
    .byte " ____             __           ____                      __   ___             ", LF
    .byte "/\  _`\          /\ \__       /\  _`\                   /\ \ /\_ \            ", LF
    .byte "\ \ \L\ \  __  __\ \ ,_\    __\ \ \/\_\  _ __    __     \_\ \\//\ \      __   ", LF
    .byte " \ \  _ <'/\ \/\ \\ \ \/  /'__`\ \ \/_/_/\`'__\/'__`\   /'_` \ \ \ \   /'__`\ ", LF
    .byte "  \ \ \L\ \ \ \_\ \\ \ \_/\  __/\ \ \L\ \ \ \//\ \L\.\_/\ \L\ \ \_\ \_/\  __/ ", LF
    .byte "   \ \____/\/`____ \\ \__\ \____\\ \____/\ \_\\ \__/.\_\ \___,_\/\____\ \____\", LF
    .byte "    \/___/  `/___/> \\/__/\/____/ \/___/  \/_/ \/__/\/_/\/__,_ /\/____/\/____/", LF
    .byte "               /\___/                                                          ", LF
    .byte "               \/__/                                                           ", LF
    .byte "  ____  ______     __      ___                                                 ", LF
    .byte " /'___\/\  ___\  /'__`\  /'___`\                                               ", LF
    .byte "/\ \__/\ \ \__/ /\ \/\ \/\_\ /\ \                                              ", LF
    .byte "\ \  _``\ \___``\ \ \ \ \/_/// /__                                             ", LF
    .byte " \ \ \L\ \/\ \L\ \ \ \_\ \ // /_\ \                                            ", LF
    .byte "  \ \____/\ \____/\ \____//\______/                                            ", LF
    .byte "   \/___/  \/___/  \/___/ \/_____/                                             ", LF
    .byte LF
    .byte "Press -M- to see a menu",LF
    .byte 0				; terminating char
newlinestr:
    .byte LF,0
resetscroll:
    .byte ESC,"[r",0
        
;-------------------------------------------------------------------------------
; MAIN routine
;
; Consumes the text buffer and executes commands when a RETURN is entered.
; Previous text can be removed using BACKSPACE
;-------------------------------------------------------------------------------
main:
    lda #<termbootstr   ; load lower byte
    sta STRLB
    lda #>termbootstr   ; load upper byte
    sta STRHB
@next:
    ldy #0
    lda (STRLB),Y
    cmp #0
    beq @exit
    jsr charout
    clc
    lda STRLB
    adc #1
    sta STRLB
    lda STRHB
    adc #0
    sta STRHB
    jmp @next
@exit:
    jsr newcmdline

loop:
    lda TBPL		; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq loop            ; if the same, do nothing
    ldx TBPL		; else, load left pointer
    lda TB,x		; load value stored in text buffer
    jsr chartoupper	; always convert character to upper case
    cmp #$0D		; check for carriage return
    beq exec
    cmp #$7F		; check for delete key
    beq backspace

    ldx CMDLENGTH       ; load command length
    cpx #$10
    beq exitloop        ; refuse to store when maxbuffer
    sta CMDBUF,x        ; store in position
    jsr charout		; if not, simply print character
    inc CMDLENGTH	; increment command length
exitloop:
    inc TBPL		; increment text buffer left pointer
    jmp loop

; user has pressed RETURN: try to interpret command execute it
exec:
    jsr parsecmd	; parse the command
    stz TBPL            ; reset text buffer
    stz TBPR
    stz CMDLENGTH	; reset command length
    jsr newcmdline	; provide new command line
    jmp loop

; user has pressed backspace: remove character from command buffer
backspace:
    lda CMDLENGTH	; skip if buffer is empty
    beq exitbp
    lda #$08
    jsr charout
    lda #' '
    jsr charout
    lda #$08
    jsr charout
    dec CMDLENGTH
exitbp:
    inc TBPL
    jmp loop

romstart:
    lda #2
    sta BREG
    jsr JUMPSTART-1
    lda #0
    sta BREG
    rts

;-------------------------------------------------------------------------------
; PARSECMD routine
;
; Parses the command buffer and executes the command based on the buffer
;-------------------------------------------------------------------------------
parsecmd:
    ldx #00
    lda CMDBUF,x
    cmp #'B'
    beq cmdchrambank	; change ram bank?
    cmp #'M'
    beq cmdshowmenu	; show the menu?
    cmp #'R'
    beq cmdrunfar	; run program?
    jsr hex4
    lda BUF2		; load high byte
    sta STARTADDR+1	; store in memory
    lda BUF3		; load low byte
    sta STARTADDR	; store in memory
    bcs errorhex	; try to parse the first four chars as 16-byte hex
    lda CMDBUF,X
    cmp #'.'
    beq cmdreadfar
    cmp #':'
    beq cmdwritefar
    jmp errorhex
    rts

errorhex:
    jsr newline
    lda #<@errorstr
    sta STRLB
    lda #>@errorstr
    sta STRHB
    jsr stringout
    rts

@errorstr:
    .asciiz "Error parsing hex address"

; jump table because instructions lie further in memory than +/- 128 bytes
cmdrunfar:
    jmp cmdrun

cmdreadfar:
    jmp cmdread

cmdwritefar:
    jmp cmdwrite

; change ram bank
cmdchrambank:
    rts

@str:
    .asciiz "Changing RAM bank to: "

; show a menu to the user
cmdshowmenu:
    jsr newline
    lda #<@str
    sta STRLB
    lda #>@str
    sta STRHB
    jsr stringout
    rts

@str:
    .byte LF,"Commands:",LF,LF
    .byte "  XXXX.[XXXX]         list memory contents",LF
    .byte "  XXXX: XX [XX]       change memory contents ",LF
    .byte "  R XXXX              run from address",LF
    .byte "  B XX                change RAM bank",LF
    .byte "  M                   show this menu",LF
    .byte 0

; run program starting at address
cmdrun:
    rts

cmdread:
    inx
    jsr hex4
    lda BUF2		; load high byte
    sta ENDADDR+1	; store in memory
    lda BUF3		; load low byte
    sta ENDADDR		; store in memory
    bcs @error
    jsr hexdump
    rts

@error:
    jmp errorhex

cmdwrite:
    rts

;-------------------------------------------------------------------------------
; HEX4 routine
;
; Try to convert 4 characters to a 16 bit hexadecimal address
; Store high byte in BUF2 and low byte in BUF3
;
;-------------------------------------------------------------------------------
hex4:
    jsr hex42
    bcs @exit
    sta BUF2
    inx
    inx
    jsr hex42
    bcs @exit
    sta BUF3
    inx
    inx
@exit:
    rts

hex42:
    phx
    lda CMDBUF,x	; load high byte
    tay
    inx
    lda CMDBUF,x	; load low byte
    tax
    tya
    jsr char2num
    plx
    rts

;-------------------------------------------------------------------------------
; HEXDUMP routine
;
;-------------------------------------------------------------------------------
hexdump:
    ; setup variables
    lda STARTADDR	; set start address
    sta MALB
    lda STARTADDR+1
    sta MAHB
    
    ; calculate the number of lines to be printed
    sec			; clear carry flag before starting subtraction
    lda ENDADDR		; load low byte of end address
    sbc STARTADDR	; subtract low byte of end address
    sta NRLINES
    lda ENDADDR+1	; load high byte
    sbc	STARTADDR+1	; subtract low byte
    sta NRLINES+1

    ; divide the result by 16, which is the number of lines that are going
    ; to be printed
    and #$0F		; take low nibble to transfer to low byte
    asl			; shift left by 4
    asl
    asl
    asl
    sta BUF1		; store temporarily
    lda NRLINES		; load low nibble
    lsr
    lsr
    lsr
    lsr
    ora BUF1		; place upper nibble
    sta NRLINES		; store in low byte
    lda NRLINES+1
    lsr
    lsr
    lsr
    lsr
    sta NRLINES+1	; store
@nextline:
    jsr newline		; start with a new line (first segment: addr)
    lda MAHB		; load high byte of memory address
    jsr printhex	; print it
    lda MALB		; load low byte of memory address
    jsr printhex	; print it
    lda #' '		; load space
    jsr charout		; print it twice
    jsr charout
    ldy #0		; number of bytes to print (second segment)
@nextbyte:
    phy			; put y on stack as printhex garbles it
    lda (MALB),y	; load byte
    jsr printhex	; print byte in hex format, garbles y
    lda #' '		; add space
    jsr charout
    ply			; restore y from stack
    iny
    cpy #8		; check if halfway
    bne @skip		; if not, skip
    lda #' '		; print two spaces to seperate 8 bit segments
    jsr charout
    jsr charout
@skip:
    cpy #16		; check if 16 bytes are printed
    bne @nextbyte	; if not, next byte
    lda #' '		; else space
    jsr charout
    lda #'|'		; add nice delimeter
    jsr charout
    ldy #0		; number of bytes to print (third segment)
@nextchar:
    phy			; y will be garbed in charout routine
    lda (MALB),y	; load byte again
    cmp #$1F		; check if value is less than $20
    bcc @printdot	; if so, print a dot
    cmp #$7F		; check if value is greater than or equal to $7F
    bcs @printdot	; if so, print a dot
    jmp @next
@printdot:
    lda #'.'		; load dot character
@next:
    jsr charout		; print character
    ply			; restore y
    iny
    cpy #16		; check if 16 characters have been consumed
    bne @nextchar	; if not, next character
    lda #'|'		; else print terminating char
    jsr charout
    lda MALB		; load low byte of monitor address
    clc			; prepare for add (clear carry)
    adc #16		; add 16
    sta MALB		; store in low byte
    lda MAHB		; load high byte
    adc #0		; add with carry (if there is a carry)
    sta MAHB		; store back in high byte
    lda NRLINES
    ora NRLINES+1
    beq @exit		; if zero, then exit, else decrement
    lda NRLINES
    sec			; set carry flag for subtraction
    sbc #1		; subtract 1 from low byte of NRLINES
    sta NRLINES		; store
    bcs @nextlinefar	; if carry set, no borrow and continue
    dec NRLINES+1
@nextlinefar:
    jmp @nextline
@exit:
    rts

;-------------------------------------------------------------------------------
; NEWLINE routine
;
; print new line to the screen
;-------------------------------------------------------------------------------
newline:
    lda #<newlinestr	; load lower byte
    sta STRLB
    lda #>newlinestr	; load upper byte
    sta STRHB
    jsr stringout
    rts

;-------------------------------------------------------------------------------
; NEWCMDLINE routine
; Garbles: X,y
;
; Moves the cursor to the next line
;-------------------------------------------------------------------------------
newcmdline:
    jsr newline
    lda #'@'
    jsr charout
    lda #':'
    jsr charout
    rts

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
    iny			; increment y
    jmp @nextchar	; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAR2NUM routine
;
; convert characters stored in a,x to a single number stored in A;
; sets C on an error, assume A contains high byte and X contains low byte
;-------------------------------------------------------------------------------
char2num:
    jsr char2nibble
    bcs @exit		; error on carry set
    asl a		; shift left 4 bits to create higher byte
    asl a
    asl a
    asl a
    sta BUF1		; store in buffer on ZP
    txa			; transfer lower byte from X to A
    jsr char2nibble	; repeat
    bcs @exit		; error on carry set
    ora BUF1		; combine nibbles
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAR2NIBBLE routine
;
; convert hexcharacter stored in a to a numerical value
; sets C on an error
;-------------------------------------------------------------------------------
char2nibble:
    cmp #'0'		; is >= '0'?
    bcc @error		; if not, throw error 
    cmp #'9'+1		; is > '9'?
    bcc @conv		; if not, char between 0-9 -> convert
    cmp #'A'		; is >= 'A'?
    bcc @error		; if not, throw error
    cmp #'F'+1		; is > 'F'?
    bcs @error          ; if so, throw error
    sec
    sbc #'A'-10		; subtract
    jmp @exit
@conv:
    sec
    sbc #'0'
    jmp @exit
@error:
    sec			; set carry
    rts
@exit:
    clc
    rts

;-------------------------------------------------------------------------------
; PRINTHEX routine
;
; print a byte loaded in A to the screen in hexadecimal formatting
;-------------------------------------------------------------------------------
printhex:
    sta BUF1
    lsr	a		; shift right; MSB is always set to 0
    lsr a
    lsr a
    lsr a
    jsr printnibble
    lda BUF1
    and #$0F
    jsr printnibble
    rts

;-------------------------------------------------------------------------------
; PRINTNIBBLE routine
;
; print the four LSB of the value in A to the screen; assumess that the four MSB
; of A are already reset
;-------------------------------------------------------------------------------
printnibble:
    cmp #10
    bcs @alpha
    adc #'0'
    jmp @exit
@alpha:
    clc
    adc #'A'-10
@exit:
    jsr charout
    rts

;-------------------------------------------------------------------------------
; CHARTOUPPER
;
; Convert a character in A, if lowercase, to uppercase
;-------------------------------------------------------------------------------
chartoupper:
    cmp #'a'
    bcc @notlower
    cmp #'z'+1
    bcs @notlower
    sec
    sbc #$20
@notlower:
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
    pha			; preserve A
    sta ACIA_DATA	; write the character to the ACIA data register
    lda #173		; initialize inner loop
@inner:
    dec                 ; decrement A; 2 cycles
    bne @inner		; check if zero; 3 cycles
    pla
    rts

;-------------------------------------------------------------------------------
; interrupt service routine
;-------------------------------------------------------------------------------
isr:
    pha			; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; load byte
    phx
    ldx TBPR		; load pointer index
    sta TB,x            ; store character
    inc TBPR
    plx			; recover X
isr_exit:
    pla			; recover A
    rti

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word isr           ; irq/brk
