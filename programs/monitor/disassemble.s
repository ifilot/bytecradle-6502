.include "constants.inc"
.include "functions.inc"

.export disassemble
.export disassembleline
.export printhexvals

.import optcodes

.segment "CODE"

;-------------------------------------------------------------------------------
; DISASSEMBLE routine
;-------------------------------------------------------------------------------
disassemble:
    lda #>@str
    ldx #<@str
    jsr putstrnl
    ldx #0
@nextoptcode:
    phx
    jsr disassembleline
    jsr printhexvals
    jsr newline

    ; increment address
    clc
    lda STARTADDR
    adc BUF8
    sta STARTADDR
    lda STARTADDR+1
    adc #0
    sta STARTADDR+1

    ; check if 16 instructions have been printed
    plx
    inx
    cpx #16
    bne @nextoptcode
rts

@str:
    .asciiz " > DISASSEMBLING memory:"

;-------------------------------------------------------------------------------
; DISASSEMBLELINE routine
;
; Completely reset the line and print the instruction
;
; BUF2 - low byte or value
; BUF3 - upper byte or value
; BUF6 - address mode
; BUF7 - optcode
;
; Uses:
; BUF4 - optcode table pointer (LB)
; BUF5 - optcode table pointer (HB)
; BUF8 - number of operands (bytes)
;-------------------------------------------------------------------------------
disassembleline:
    lda #>@clearline
    ldx #<@clearline
    jsr putstr
    jsr puttab
    lda STARTADDR+1
    jsr puthex
    lda STARTADDR
    jsr puthex
    lda #':'
    jsr putchar
    lda #' '
    jsr putchar

    ; grab mnemonic from optcode table
    ; calculate offset in BUF4:5
    lda (STARTADDR)         ; grab optcode
    sta BUF7
    stz BUF5
    asl                     ; multiply by 2
    rol BUF5
    asl                     ; multiply by 4
    rol BUF5
    asl                     ; multiply by 8
    rol BUF5
    sta BUF4                ; store low byte (high byte in BUF4)

    ; load optcode information
    lda #<optcodes          ; load low byte of table address
    clc
    adc BUF4                ; add offset low byte
    sta BUF4                ; store
    lda #>optcodes          ; load high byte of table address
    adc BUF5                ; add offset high byte
    sta BUF5                ; store

    ; store number of params and addressing mode
    ldy #4
    lda (BUF4),y            ; load number of params
    sta BUF8
    iny
    lda (BUF4),y            ; load address mode
    sta BUF6

    ; read bytes following optcode
    lda BUF8
    cmp #1
    beq @continue
    ldy #1
    lda (STARTADDR),y
    sta BUF2
    lda BUF8
    cmp #2
    beq @continue
    iny
    lda (STARTADDR),y
    sta BUF3

@continue:
    ; print mnemonic
    ldy #0
@next:
    lda (BUF4),y
    jsr putchar
    iny
    cpy #4
    bne @next
    cmp #' '                ; check if last char was space
    beq @printoperands
    lda #' '                ; if not, print a space
    jsr putchar

    ; now print operands
@printoperands:
    ldy #4
    lda (BUF4),y            ; grab number of operands
    sta BUF8                ; store in BUF8
    cmp #1                  ; only one byte?
    beq @nothing

    ldy #5
    lda (BUF4),y             ; load address mode
    cmp #$01                 ; absolute address mode?
    beq @abs
    cmp #$02                 ; absolute, x?
    beq @absx
    cmp #$03                 ; absolute, y?
    beq @absy
    cmp #$04                 ; accumulator
    beq @nothing
    cmp #$05                 ; immediate?
    beq @im
    cmp #$06                 ; indirect x
    beq @indx
    cmp #$07                 ; indirect y
    beq @indy
    cmp #$08                 ; indirect (only for jump)
    beq @ind
    cmp #$09                 ; relative?
    beq @relzp
    cmp #$0A                 ; zero page?
    beq @relzp
    cmp #$0B                 ; zero page,x
    beq @zpx
    cmp #$0C                 ; zero page,y
    beq @zpy
    cmp #$0D                 ; zero page indirect
    beq @zpind
    cmp #$0E                 ; absoluteindexedindirect
    beq @absind
    cmp #$0F                 ; zeropagerelative
    beq @zprel
    jmp @nothing

@nothing:                   ; print nothing ($00, $04)
    jsr puttab
    rts
@abs:                       ; print absolute ($01)
    jsr @putop4
    rts
@absx:                      ; print absolute,x ($02)
    jsr @putop4
    jsr @putcommax
    rts
@absy:                      ; print absolute,y ($03)
    jsr @putop4
    jsr @putcommay
    rts
@im:                        ; immediate ($05)
    lda #'#'
    jsr putchar
    jsr @putop2
    rts
@indx:                      ; print indirect x ($06)
    jsr @putinx
    rts
@indy:                      ; print indirect y ($07)
    jsr @putiny
    rts
@ind:                       ; print indirect ($08)
    jsr @putin4
    rts
@relzp:                     ; print relative ($09) or zeropage ($0A)
    jsr @putop2
    rts
@zpx:                       ; print zeropage,x ($0B)
    jsr @putinx
    rts
@zpy:                       ; print zeropage,x ($0C)
    jsr @putiny
    rts
@zpind:                     ; print zeropage indirect ($0D)
    lda #'('
    jsr putchar
    jsr @putop2
    lda #')'
    jsr putchar
    rts
@absind:                    ; print absolute indexed indirect ($0E)
    lda #'('
    jsr @putop4
    jsr @putcommax
    lda #')'
    jsr putchar
@zprel:
    lda BUF3
    jsr puthex
    lda #','
    jsr putchar
    lda BUF2
    jsr puthex
    rts

; print address low byte
@putop2:
    lda BUF2
    jsr puthex
    rts

; print address
@putop4:
    lda BUF3
    jsr puthex
    lda BUF2
    jsr puthex
    rts

; print address between round parentheses
@putin4:
    lda #'('
    jsr putchar
    jsr @putop4
    lda #')'
    jsr putchar
    rts

; print address between round parentheses
@putinx:
    lda #'('
    jsr putchar
    jsr @putop2
    jsr @putcommax
    lda #')'
    jsr putchar
    rts

; print address between round parentheses
@putiny:
    lda #'('
    jsr putchar
    jsr @putop2
    lda #')'
    jsr putchar
    jsr @putcommay
    rts

; print ",X"
@putcommax:
    lda #','
    jsr putchar
    lda #'X'
    jsr putchar
    rts

; print ",Y"
@putcommay:
    lda #','
    jsr putchar
    lda #'Y'
    jsr putchar
    rts

@clearline:
    .byte ESC, "[2K", $0D, $00

;-------------------------------------------------------------------------------
; PRINTHEXVALS routine
;
; Print hex values to the screen. This function must be called after
; printinstruction and assumes that the following information is present
; in the buffer:
;
; BUF2 - low byte or value
; BUF3 - upper byte
; BUF4 - optcode table pointer (LB)
; BUF5 - optcode table pointer (HB)
; BUF6 - address mode
; BUF7 - optcode
; BUF8 - number of operands (bytes)
;-------------------------------------------------------------------------------
printhexvals:
    jsr puttab

    lda BUF7
    jsr puthex

    lda BUF8
    cmp #1
    beq @exit
    cmp #2
    beq @skipupper
    lda #' '
    jsr putchar
    lda BUF3
    jsr puthex
@skipupper:
    lda #' '
    jsr putchar
    lda BUF2
    jsr puthex
@exit:
    rts
