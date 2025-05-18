.PSC02

.include "constants.inc"
.include "functions.inc"

.export mainmenu

.import memtest
.import numbertest
.import sieve
.import startchess
.import monitor
.import asciitest
.import ansitest
.import blinkenlights
.import strobe

.import gitid

.define MENUWIDTH 45

;-------------------------------------------------------------------------------
; MAIN MENU
;
; BUF1 is used to store keypress
; BUF 7:6 is used to store reference to menu entries
;-------------------------------------------------------------------------------
mainmenu:
    lda #<mainmenu_entries
    sta BUF6
    lda #>mainmenu_entries
    sta BUF7
    lda #<mainmenu_table
    ldx #>mainmenu_table
    jsr buildmenu
    jmp mainmenu

;-------------------------------------------------------------------------------
; BUILDMENU routine
; 
; Input: X:A is pointer to menutable
;        BUF 7:6 is pointer to menu entries
;-------------------------------------------------------------------------------
buildmenu:
    jsr printmenu
@loop:
    jsr getch
    cmp #0
    beq @loop
    sta BUF1
    ldy #0
@next:
    lda (BUF6),y            ; load menu key
    cmp #0
    beq @loop
    cmp BUF1                ; compare with keypress
    beq @run                ; if equal, run menu item
    iny                     ; increment y by 3
    iny
    iny
    jmp @next
@run:
    iny
    lda (BUF6),y
    sta BUF2
    iny
    lda (BUF6),y
    sta BUF3
    jmp (BUF2)
    jmp @loop

;-------------------------------------------------------------------------------
; PRINT MENU ROUTINE
;
; print menu using a pointer X:A to lines table
;
; BUF1-3 is used by printmenuline
; BUF1 is also used by this routine, but does not overlap
; BUF5:BUF4 stores pointer to lines table (this routine)
;-------------------------------------------------------------------------------
printmenu:
    sta BUF4
    stx BUF5
    ldy #0
@next_line:
    phy
    lda (BUF4),y            ; load lower byte of string
    beq @done               ; check if zero, if so done
    sta BUF1                ; else, store in buffer
    iny
    lda (BUF4),y            ; load upper byte of string
    tax
    and BUF1
    cmp #$FF
    beq @dashedline
@regular:
    lda BUF1                ; load lower byte
    jsr printmenuline
@cont:
    ply
    iny
    iny
    jmp @next_line
@dashedline:
    jsr printdashedline
    jmp @cont
@done:
    ply                     ; clean stack
    rts

; MAIN MENU STRINGS
.align 2
mainmenu_table:
    .byte $FF, $FF              ; dashed line
    .byte <@titlestr,           >@titlestr
    .byte $FF, $FF              ; dashed line
    .byte <@strram,             >@strram
    .byte <@strrom,             >@strrom
    .byte <@strio,              >@strio
    .byte <@stracia,            >@stracia
    .byte $FF, $FF              ; dashed line
    .byte <@strmenu,            >@strmenu
    .byte <@strempty,           >@strempty
    .byte <@strmenutests,       >@strmenutests
    .byte <@strmenuapps,        >@strmenuapps
    .byte <@strmenugames,       >@strmenugames
    .byte <@strmonitor,         >@strmonitor
    .byte <@strdaughterboards,  >@strdaughterboards
    .byte $FF, $FF              ; dashed line
    .byte 0

@titlestr:
    .asciiz "BYTECRADLE /TINY/ ROM"
@strram:
    .asciiz "RAM  : 0x0000 - 0x7EFF"
@strrom:
    .asciiz "ROM  : 0x8000 - 0xFFFF"
@strio:
    .asciiz "IO   : 0x7F00 - 0x7FFF"
@stracia:
    .asciiz "ACIA : 0x7F04 - 0x7F0F"
@strmenu:
    .asciiz "    SELECT CATEGORY"
@strmenutests:
    .asciiz "(t) Test routines"
@strmenuapps:
    .asciiz "(a) Applications"
@strmenugames:
    .asciiz "(g) Games"
@strmonitor:
    .asciiz "(m) Monitor"
@strdaughterboards:
    .asciiz "(d) Daughterboards"
@strempty:
    .asciiz ""

; MAIN MENU ENTRIES
mainmenu_entries:
    .byte 't', <testmenu,           >testmenu
    .byte 'g', <gamesmenu,          >gamesmenu
    .byte 'a', <appmenu,            >appmenu
    .byte 'm', <runmonitor,         >runmonitor
    .byte 'd', <daughterboardmenu,  >daughterboardmenu
    .byte 0

;-------------------------------------------------------------------------------
; TEST MENU
;-------------------------------------------------------------------------------
testmenu:
    lda #<testmenu_entries
    sta BUF6
    lda #>testmenu_entries
    sta BUF7
    lda #<testmenu_table
    ldx #>testmenu_table
    jsr buildmenu
    jmp testmenu

; TEST MENU STRINGS
.align 2
testmenu_table:
    .byte $FF, $FF                      ; dashed line
    .byte <@titlestr,       >@titlestr
    .byte $FF, $FF                      ; dashed line
    .byte <@strasciitest,   >@strasciitest
    .byte <@strtansitest,   >@strtansitest
    .byte <@strnumbertest,  >@strnumbertest
    .byte <@strmemorytest,  >@strmemorytest
    .byte <@strback,        >@strback
    .byte $FF, $FF                      ; dashed line
    .byte 0

@titlestr:
    .asciiz "CATEGORY: TESTS"
@strasciitest:
    .asciiz "(1) Test ASCII"
@strtansitest:
    .asciiz "(2) Test ANSI"
@strnumbertest:
    .asciiz "(3) Number test"
@strmemorytest:
    .asciiz "(4) Memory test"
@strback:
    .asciiz "(b) Back"

; TEST MENU ENTRIES
testmenu_entries:
    .byte '1', <asciitest,      >asciitest
    .byte '2', <ansitest,       >ansitest
    .byte '3', <numbertest,     >numbertest
    .byte '4', <memtest,        >memtest
    .byte 'b', <mainmenu,       >mainmenu
    .byte 0

;-------------------------------------------------------------------------------
; GAMES MENU
;-------------------------------------------------------------------------------
gamesmenu:
    lda #<gamesmenu_entries
    sta BUF6
    lda #>gamesmenu_entries
    sta BUF7
    lda #<gamesmenu_table
    ldx #>gamesmenu_table
    jsr buildmenu
    jmp gamesmenu

; GAMES MENU STRINGS
.align 2
gamesmenu_table:
    .byte $FF, $FF                      ; dashed line
    .byte <@titlestr,       >@titlestr
    .byte $FF, $FF                      ; dashed line
    .byte <@strmicrochess,  >@strmicrochess
    .byte <@strback,        >@strback
    .byte $FF, $FF                      ; dashed line
    .byte 0

@titlestr:
    .asciiz "CATEGORY: GAMES"
@strmicrochess:
    .asciiz "(1) Micro chess"
@strback:
    .asciiz "(b) Back"

; GAMES MENU ENTRIES
gamesmenu_entries:
    .byte '1', <startchess,     >startchess
    .byte 'b', <mainmenu,       >mainmenu
    .byte 0

;-------------------------------------------------------------------------------
; APPLICATIONS MENU
;-------------------------------------------------------------------------------
appmenu:
    lda #<appmenu_entries
    sta BUF6
    lda #>appmenu_entries
    sta BUF7
    lda #<appmenu_table
    ldx #>appmenu_table
    jsr buildmenu
    jmp appmenu

; APP MENU STRINGS
.align 2
appmenu_table:
    .byte $FF, $FF                      ; dashed line
    .byte <@titlestr,       >@titlestr
    .byte $FF, $FF                      ; dashed line
    .byte <@strsieve,       >@strsieve
    .byte <@strback,        >@strback
    .byte $FF, $FF                      ; dashed line
    .byte 0

@titlestr:
    .asciiz "CATEGORY: APPLICATIONS"
@strsieve:
    .asciiz "(1) Sieve of Eratosthenes"
@strback:
    .asciiz "(b) Back"

; APP MENU ENTRIES
appmenu_entries:
    .byte '1', <sieve,          >sieve
    .byte 'b', <mainmenu,       >mainmenu
    .byte 0

;-------------------------------------------------------------------------------
; MONITOR
;-------------------------------------------------------------------------------
runmonitor:
    jsr monitor
    jmp mainmenu

;-------------------------------------------------------------------------------
; DAUGHTERBOARD MENU
;-------------------------------------------------------------------------------
daughterboardmenu:
    lda #<daughterboardmenu_entries
    sta BUF6
    lda #>daughterboardmenu_entries
    sta BUF7
    lda #<daughterboardmenu_table
    ldx #>daughterboardmenu_table
    jsr buildmenu
    jmp daughterboardmenu

.align 32
daughterboardmenu_table:
    .byte $FF, $FF                      ; dashed line
    .byte <@titlestr,           >@titlestr
    .byte $FF, $FF                      ; dashed line
    .byte <@strblinkenlights,   >@strblinkenlights
    .byte <@strstrobe,          >@strstrobe
    .byte <@strback,            >@strback
    .byte $FF, $FF                      ; dashed line
    .byte 0

@titlestr:
    .asciiz "CATEGORY: DAUGHTERBOARDS"
@strblinkenlights:
    .asciiz "(1) Blinkenlights"
@strstrobe:
    .asciiz "(2) Strobe"
@strback:
    .asciiz "(b) Back"

;-------------------------------------------------------------------------------
; DAUGHTERBOARD MENU TABLE
;-------------------------------------------------------------------------------
.align 16
daughterboardmenu_entries:
    .byte '1', <blinkenlights,  >blinkenlights
    .byte '2', <strobe,         >strobe
    .byte 'b', <mainmenu,       >mainmenu
    .byte 0

;-------------------------------------------------------------------------------
; PRINTDASHEDLINE routine for menu
;-------------------------------------------------------------------------------
printdashedline:
    lda #'+'
    jsr putch
    ldx #(MENUWIDTH+1)
    lda #'-'
    jsr putrepch
    lda #'+'
    jsr putch
    jsr newline
    rts

;-------------------------------------------------------------------------------
; PRINT MENU LINE
;
; A:X is a pointer to a string
;
; BUF2:BUF1 is used to store string pointer (done in strlen routine)
; BUF3 stores number of bytes in string
;-------------------------------------------------------------------------------
printmenuline:
    jsr strlen      ; also stores string pointer in BUF1 and BUF2
    sta BUF3        ; stores number of bytes
    lda #'|'
    jsr putch
    jsr putspace
    lda BUF1
    ldx BUF2
    jsr putstr
    lda #MENUWIDTH
    sec
    sbc BUF3
    tax             ; store number of times character has to be repeated
    lda #' '        ; print spaces to complete line
    jsr putrepch
    lda #'|'
    jsr putch
    jsr newline
    rts
