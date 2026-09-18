.PSC02

; Zero-page memory layout
HEIGHT            = $40      ; 1 byte
HEIGHTMIN1        = $41      ; 1 byte
WIDTH             = $42      ; 1 byte
WIDTHMIN1         = $43      ; 1 byte
WIDTHHEIGHTMIN1   = $44      ; 2 bytes
ROW               = $46      ; 1 byte
COL               = $47      ; 1 byte
INDEX             = $48      ; 2 bytes 
NUMPOINTS         = $4A      ; 2 bytes
ARRAYPTR          = $4D      ; 2 bytes
ZPBUF1            = $51      ; 2 bytes
ZPBUF2            = $53      ; 2 bytes
READBUF           = $55      ; 7 bytes
XPOS              = $5C      ; 1 byte
YPOS              = $5D      ; 1 byte
XMARGIN           = $5E      ; 1 byte
YMARGIN           = $5F      ; 1 byte

; array memory allocations
ARRAY    = $0400     ; max 31486 bytes 0400 - 7EFE

; import and exporting functions / constants
.include "constants.inc"
.include "functions.inc"
.import printmenu
.export rungameoflife

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "CODE"

; game of life main menu table
.align 3
gameoflifetable:
    .byte $FF, $FF                            ; dashed line
    .byte <@gameoflifestr,  >@gameoflifestr
    .byte $FF, $FF                            ; dashed line
    .byte <@creditstr,      >@creditstr
    .byte <@davidstr,       >@davidstr
    .byte <@startstr,       >@startstr
    .byte <@backstr,        >@backstr
    .byte $FF, $FF                            ; dashed line
    .byte <@controlstr,     >@controlstr
    .byte $FF, $FF                            ; dashed line
    .byte <@controlstr1,    >@controlstr1
    .byte <@controlstr2,    >@controlstr2
    .byte <@controlstr3,    >@controlstr3
    .byte <@controlstr4,    >@controlstr4
    .byte <@controlstr5,    >@controlstr5
    .byte <@controlstr6,    >@controlstr6
    .byte <@exitstr,        >@exitstr
    .byte $FF, $FF                            ; dashed line
    .byte 0

; game of life strings used in main menu
@gameoflifestr:
    .asciiz "CONWAYS GAME OF LIFE"
@creditstr:
    .asciiz "DEVISED BY JOHN HORTON CONWAY"
@davidstr:
    .asciiz "IMPLEMENTED BY DAVID WARRAND"
@startstr:
    .asciiz "(SPACE) TO BEGIN PROGRAM"
@backstr:
    .asciiz "(B) TO GO BACK"
@exitstr:
    .asciiz "(Q) TO QUIT"
@controlstr:
    .asciiz "CONTROLS"
@controlstr1:
    .asciiz "(M) SPECIAL STARTING POSITIONS MENU"
@controlstr2:
    .asciiz "(W,A,S,D) TO MOVE AROUND"
@controlstr3:
    .asciiz "(SPACE) TO START, TO PLACE OR REMOVE A CELL"
@controlstr4:
    .asciiz "(R) TO RUN THE GAME OF LIFE"
@controlstr5:
    .asciiz "(X) TO RUN FOR ONE STEP"
@controlstr6:
    .asciiz "(P) TO PAUSE"

; special starting position menu table
.align 3
startingpositiontable:
    .byte $FF, $FF                                          ; dashed line
    .byte <@startingpositionsstr,  >@startingpositionsstr
    .byte $FF, $FF                                          ; dashed line
    .byte <@positionsstr,          >@positionsstr
    .byte <@positionsstr2,         >@positionsstr2
    .byte <@positionsstr3,         >@positionsstr3
    .byte $FF, $FF                                          ; dashed line
    .byte <@gliderstr,             >@gliderstr
    .byte <@pulsarstr,             >@pulsarstr
    .byte <@hwssstr,               >@hwssstr
    .byte <@rpentominostr,         >@rpentominostr
    .byte <@gospergunstr,          >@gospergunstr
    .byte <@thanksstr,             >@thanksstr
    .byte $FF, $FF                                          ; dashed line
    .byte 0

; special starting positions strings used in special menu
@startingpositionsstr:
    .asciiz "SPECIAL STARTING POSITIONS MENU"
@positionsstr:
    .asciiz "These starting positions behave in special"
@positionsstr2:
    .asciiz "ways. Try them and watch the magic of the"
@positionsstr3:
    .asciiz "game of life. These are just a few of many"
@positionsstr4:
    .asciiz "famous starting postions"
@gliderstr:
    .asciiz "(1) Glider"
@pulsarstr:
    .asciiz "(2) Pulsar"
@hwssstr:
    .asciiz "(3) Heavy weight spaceship"
@rpentominostr:
    .asciiz "(4) R-pentomino"
@gospergunstr:
    .asciiz "(5) Gosper glider gun"
@thanksstr:
    .asciiz "(6) Thanks"

; coordinates of special stating positions
; formating of coordinates
; width, height, x + 1, y + 1, etc, 0
glider:
    .byte 3, 3, 2, 1, 3, 2, 1, 3, 2, 3, 3, 3, 0
pulsar:
    .byte 13, 13, 3, 5, 4, 5, 5, 5, 9, 5, 10, 5, 11, 5, 1, 7, 6, 7, 8, 7, 13, 7
    .byte 1, 8, 6, 8, 8, 8, 13, 8, 1, 9, 6, 9, 8, 9, 13, 9, 3, 11, 4, 11, 5, 11
    .byte 9, 11, 10, 11, 11, 11, 0
hwss:
    .byte 7, 5, 4, 1, 2, 2, 6, 2, 1, 3, 1, 4, 1, 5, 2, 5, 3, 5, 4, 5, 5, 5, 6, 5
    .byte 7, 4, 0
rpentomino:
    .byte 3, 3, 2, 1, 3, 1, 1, 2, 2, 2, 2, 3, 0
gospergun:
    .byte 31, 9, 1, 5, 2, 5, 1, 6, 2, 6, 13, 3, 14, 3, 12, 4, 11, 5, 11, 6, 11
    .byte 7, 12, 8, 13, 9, 14, 9, 15, 6, 16, 4, 16, 8, 17, 5, 17, 6, 17, 7, 18
    .byte 6, 21, 3, 22, 3, 21, 4, 22, 4, 21, 5, 22, 5, 23, 2, 23, 6, 25, 1, 25
    .byte 2, 25, 6, 25, 7, 35, 3, 36, 3, 35, 4, 36, 4, 0
thanks:
    .byte 30, 12, 1, 1, 2, 1, 3, 1, 4, 1, 5, 1, 3, 2, 3, 3, 3, 4, 3, 5, 8, 1, 8
    .byte 2, 8, 3, 8, 4, 8, 5, 9, 3, 10, 3, 11, 1, 11, 2, 11, 3, 11, 4, 11, 5
    .byte 14, 2, 14, 3, 14, 4, 14, 5, 15, 1, 16, 1, 15, 3, 16, 3, 17, 2, 17, 3
    .byte 17, 4, 17, 5, 20, 1, 20, 2, 20, 3, 20, 4, 20, 5, 21, 2, 22, 3, 23, 4
    .byte 24, 1, 24, 2, 24, 3, 24, 4, 24, 5, 27, 1, 27, 2, 27, 3, 27, 4, 27, 5
    .byte 28, 3, 29, 2, 29, 4, 30, 1, 30, 5, 2, 7, 2, 8, 2, 9, 2, 10, 3, 11, 4
    .byte 11, 5, 7, 5, 8, 5, 9, 5, 10, 8, 10, 9, 10, 9, 11, 8, 12, 14, 7, 15, 7
    .byte 16, 7, 15, 8, 15, 9, 15, 10, 15, 11, 14, 11, 16, 11, 19, 7, 19, 8, 20
    .byte 9, 20, 10, 21, 11, 22, 10, 22, 9, 23, 8, 23, 7, 26, 8, 26, 9, 26, 10
    .byte 27, 11, 28, 11, 27, 7, 28, 7, 29, 8, 29, 9, 29, 10, 0

;-------------------------------------------------------------------------------
; RUNGAMEOFLIFE routine
; Garbles: A, X
; Uses: gameoflifetable
;
; Main menu of the Game of Life program
; Waits for spacebar to begin, 'M' to open special menu, or 'B' to exit.
;-------------------------------------------------------------------------------
rungameoflife:
    lda #<gameoflifetable           ; Load low byte of gameoflifetable
    ldx #>gameoflifetable           ; Load high byte
    jsr printmenu                   ; Print program title/menu
@start:
    jsr getch                       ; Wait for user input
    cmp #0
    beq @start                      ; Ignore null characters
    cmp #' '
    beq @initializegame                    ; If spacebar, start game
    jsr chartoupper
    cmp #'M'                        ; If 'M' go to special menu
    beq @specialmenu
    cmp #'B'
    bne @start                      ; If not 'B', loop again
    jmp @exit                       ; Exit on 'B'
@specialmenu:
    jsr specialmenu                 ; Enter special menu loop
    jsr initializegame              ; Initialize the game array, and screen
    jsr generatestartingposition    ; Generates the special structure
    jsr usercontrol                 ; Enter interactive user control mode
    jmp @exit
@initializegame:
    jsr initializegame              ; Initialize the game array, and screen
    jsr usercontrol                 ; Enter interactive user control mode
@exit:
    jsr newline                     ; Print newline before exiting
    rts

;-------------------------------------------------------------------------------
; SPECIALMENU routine
; Garbles: A, X
; Uses: startingpositiontable, glider, pulsar, hwss, rpentomino, gospergun,
;       thanks
;
; Special menu of the Game of Life program
; Waits for 1 - 6 to be pressed to choose a starting structure or 'B' to exit.
;-------------------------------------------------------------------------------
specialmenu:
    lda #<startingpositiontable     ; Load low byte of startingpositiontable
    ldx #>startingpositiontable     ; Load high byte
    jsr printmenu                   ; Print special menu
@menuoptions:
    jsr getch                       ; Wait for user input
    cmp #0
    beq @menuoptions                ; Ignore null characters
    jsr chartoupper
    cmp #'B'                        ; Exit if 'B' is pressed
    beq @exit
    cmp #'1'                        ; 1 - 6 go to their corresponding choices
    beq @1
    cmp #'2'
    beq @2
    cmp #'3'
    beq @3
    cmp #'4'
    beq @4
    cmp #'5'
    beq @5
    cmp #'6'
    bne @menuoptions         
    lda #<thanks
    ldx #>thanks
    jmp @choicemade
@1:
    lda #<glider
    ldx #>glider
    jmp @choicemade
@2:
    lda #<pulsar
    ldx #>pulsar
    jmp @choicemade
@3:
    lda #<hwss
    ldx #>hwss
    jmp @choicemade
@4:
    lda #<rpentomino
    ldx #>rpentomino
    jmp @choicemade
@5:
    lda #<gospergun
    ldx #>gospergun
@choicemade:
    sta ZPBUF2                      ; loads the bytes of the choice into ZPBUF2  
    txa
    sta ZPBUF2 + 1
    rts
@exit:
    tsx                             ; Exit needs to increment the stack twice
    inx
    inx
    txs
    jsr newline
    jsr rungameoflife               ; Go back to main menu

;-------------------------------------------------------------------------------
; INITIALIZEGAME routine
; Garbles: A, Y, X
; Uses: WIDTH, WIDTHMIN1, HEIGHT, HEIGHTMIN1, WIDTHHEIGHTMIN1, ROW, COL, INDEX
;       NUMPOINTS, ARRAYPTR, ARRAY, 
;
; Initializes the Game of Life program by initializing the screen, and array,
; and variables used throughout the program
;-------------------------------------------------------------------------------
initializegame:
    jsr chartoupper           ; Normalize to uppercase
    jsr reset                 ; clear screen
    lda #80
    sta WIDTHMIN1             ; Can only move the cursor right 80 times
    lda #23
    sta HEIGHTMIN1            ; Can only move the cursor right 23 times
    ldx #80                   ; Prepare to move cursor right 80 steps
@screenwidthloop:
    jsr goright               ; Move cursor right
    dex
    bne @screenwidthloop      ; Loop until cursor is at edge, or moved 80 steps
    ldx #23                   ; Prepare to move cursor down 23 steps
@screenheightloop:
    jsr godown                ; Move cursor right
    dex
    bne @screenheightloop
    jsr readposition          ; Store cursor location in ROW and COL
    jsr reset                 ; Clear the screen and hide cursor
    lda ROW
    sta HEIGHTMIN1
    sta HEIGHT                ; Store bottom-most row
    inc HEIGHT                ; HEIGHT = ROW + 1
    dec COL
    lda COL
    sta WIDTHMIN1
    sta WIDTH                 ; Store right-most column
    inc WIDTH                 ; WIDTH = COL + 1
    jsr calcindex             ; Compute INDEX = HEIGHT × WIDTH + COL
    clc
    lda INDEX
    adc #1
    sta NUMPOINTS             ; Total number of cells (low byte)
    lda INDEX + 1
    adc #0
    sta NUMPOINTS + 1         ; Total number of cells (high byte)
    sec
    lda NUMPOINTS
    sbc WIDTH
    sta WIDTHHEIGHTMIN1       ; WIDTH × (HEIGHT - 1) low byte
    lda NUMPOINTS + 1
    sbc #0
    sta WIDTHHEIGHTMIN1 + 1   ; WIDTH × (HEIGHT - 1) high byte
    lda #<ARRAY
    sta ARRAYPTR              ; Initialize ARRAYPTR to point to start of ARRAY
    lda #>ARRAY
    sta ARRAYPTR+1
    ldx NUMPOINTS
    ldy NUMPOINTS + 1         ; Set up array size counter in X:Y
@initializearray:
    lda #0
    sta (ARRAYPTR)            ; Zero out current cell
    inc ARRAYPTR              ; Move to next cell
    bne :+
    inc ARRAYPTR + 1
:
    cpx #0
    bne :+
    dey                       ; If low byte is 0, decrement high byte
:
    dex
    bne @initializearray
    cpy #0
    bne @initializearray      ; Continue until both X and Y reach 0
    rts

;-------------------------------------------------------------------------------
; GENERATESTATINGPOSITIONS routine
; Garbles: A, X, Y
; Uses: WIDTH, XMARGIN, HEIGHT, YMARGIN, ZPBUF2, COL, ROW
;
; Generates special starting structures which are stored at ZPBUF2. It also
; creates margins of the screen by doing (Screenwidth - Width of Structure)
; >> 2, and the same for the height. 
;-------------------------------------------------------------------------------
generatestartingposition:
    sec
    lda WIDTH              ; (Screenwidth - Width of Structure) >> 2
    sbc (ZPBUF2)           
    sta XMARGIN
    lsr XMARGIN
    dec XMARGIN            ; Dec as the coordinates are 1-based
    inc ZPBUF2             ; Increment to height of sctructure
    bne :+                 
    inc ZPBUF2 + 1       
:
    sec
    lda HEIGHT             ; (Screenheight - Height of Structure) >> 2
    sbc (ZPBUF2)            
    sta YMARGIN
    lsr YMARGIN
    dec YMARGIN            ; Dec as the coordinates are 1-based
    inc ZPBUF2             ; Increment to first x-coordinate
    bne :+                   
    inc ZPBUF2 + 1        
:
@loop:                     ; loop which prints the structure to the screen
    lda (ZPBUF2)
    cmp #0
    beq @done              ; structure data is 0 terminated
    clc
    adc XMARGIN            ; print structure using the x-margin
    tax                    ; store current x-coordinate in x
    sta XPOS               ; used to keep track in the array
    inc ZPBUF2             ; increment to y-coordinate
    bne :+                     
    inc ZPBUF2 + 1         
:
    lda (ZPBUF2)
    clc
    adc YMARGIN            ; print structure using the x-margin
    tay
    sta YPOS               ; used to keep track in the array
    jsr movecursor         ; move cursor to positions stored in X, and Y 
    jsr placecell          ; place cell in the array
    inc ZPBUF2             ; Increment to next x-coordinate or 0 if done
    bne :+                 
    inc ZPBUF2 + 1         
:
    jmp @loop
@done:
    rts

;-------------------------------------------------------------------------------
; USERCONTROL routine
; Garbles: A
; Conserves: X, Y
;
; Handles user input for manual control:
; - W/A/S/D to move cursor
; - SPACE to toggle cell state
; - R to resume simulation (mainloop)
; - Q to exit control mode
; - X to step the simulation once
;-------------------------------------------------------------------------------
usercontrol:
    jsr getch                 ; Wait for key press
    cmp #0
    beq usercontrol           ; Ignore null characters
    jsr chartoupper           ; Convert to uppercase for uniform input
    cmp #'Q'
    beq @exit                 ; Quit control mode
    cmp #'W'
    beq @up                   ; Move cursor up
    cmp #'D'
    beq @right                ; Move cursor right
    cmp #'A'
    beq @left                 ; Move cursor left
    cmp #'S'
    beq @down                 ; Move cursor down
    cmp #' '
    beq @space                ; Toggle cell at cursor
    cmp #'X'
    beq @step                 ; Step the simulation once
    cmp #'R'
    bne usercontrol           ; Unrecognized input → wait again
    jsr mainloop              ; Begin or resume simulation
    jsr showcursor
    jsr newline
    rts
@step:
    jsr step
    jmp usercontrol
@space:
    jsr placecell             ; Toggle cell under cursor
    jmp usercontrol
@up:
    jsr goup
    jmp usercontrol
@down:
    jsr godown
    jmp usercontrol
@right:
    jsr goright
    jmp usercontrol
@left:
    jsr goleft
    jmp usercontrol
@exit:
    jsr newline               ; Move to next line before exit
    rts

;-------------------------------------------------------------------------------
; PLACECELL routine
; Garbles: A, X, Y
; Uses: INDEX, ARRAYPTR
;
; Toggles the state of the cell under the cursor:
; - If cell is dead (0), mark it alive (bit 7) and draw '#'
; - If cell is alive (bit 7 set), mark it dead and draw ' '
;-------------------------------------------------------------------------------
placecell:
    lda XPOS
    sta COL
    lda YPOS
    sta ROW
    jsr calcindex             ; Compute linear index → INDEX
    clc
    lda INDEX                 ; Compute ARRAYPTR = ARRAY + INDEX
    adc #<ARRAY
    sta ARRAYPTR
    lda INDEX + 1
    adc #>ARRAY
    sta ARRAYPTR + 1
    lda (ARRAYPTR)            ; Read current cell value
    cmp #0
    bne @removecell           ; If not zero → cell is alive → remove it
    lda #%10000000            ; Cell is dead → make alive and draw '#'
    sta (ARRAYPTR)
    lda #'#'
    jsr putch
    jmp @exit
@removecell:
    lda #0                    ; Set cell to dead
    sta (ARRAYPTR)
    lda #' '                  ; Erase visual marker
    jsr putch
@exit:
    jsr goleft                ; move left to stay at current postion
    inc XPOS                  ; to keep tracking consistent
    rts

;-------------------------------------------------------------------------------
; READPOSITION routine
; Garbles: A, X, Y
; Uses: READBUF, ROW, COL
;
; Requests and parses the current cursor position from the terminal using
; ANSI escape sequence ESC [6n. The terminal responds with ESC [<row>;<col>R.
; This routine parses the row and column values from the response and stores
; them as zero-based values in ROW and COL.
;-------------------------------------------------------------------------------
readposition:
    lda #ESC                 ; ESC
    jsr putch
    lda #'['                 ; '['
    jsr putch
    lda #'6'                 ; '6'
    jsr putch
    lda #'n'                 ; 'n' → ESC [6n requests cursor position
    jsr putch
@waitesc:
    jsr getch                ; Wait for ESC character in response
    cmp #ESC
    bne @waitesc
    ldx #0                   ; Start filling READBUF at index 0
@readloop:
    jsr getch                ; Read next character
    cmp #0
    beq @readloop            ; Skip null characters
    sta READBUF,x            ; Store into buffer
    inx
    cmp #'R'                 ; Check for end of position string
    bne @readloop
    ldx #1                   ; Start parsing after '['
    stz ROW                  ; Clear ROW accumulator
    stz COL                  ; Clear COL accumulator
@parserow:
    lda READBUF,x            ; Load next byte
    inx
    cmp #';'                 ; Is this the row-column separator?
    beq @parsecol            ; Yes → switch to column parsing
    tay                      ; Save character temporarily in Y
    asl ROW                  ; Multiply ROW by 10 (×8 + ×2)
    lda ROW
    asl ROW
    asl ROW
    clc
    adc ROW
    sta ROW    
    tya                      ; Add new digit (ASCII to binary conversion)
    sec
    sbc #'0'
    clc
    adc ROW
    sta ROW
    jmp @parserow            ; Continue parsing next digit
@parsecol:
    lda READBUF,x            ; Load next byte
    inx
    cmp #'R'                 ; End of ANSI position string?
    beq :+                   ; Yes → parsing complete
    tay                      ; Save character temporarily in Y   
    asl COL                  ; Multiply COL by 10 (×8 + ×2)
    lda COL
    asl COL
    asl COL
    clc
    adc COL
    sta COL
    tya                      ; Add new digit (ASCII to binary conversion)
    sec
    sbc #'0'
    clc
    adc COL
    sta COL
    jmp @parsecol            ; Continue parsing next digit
:
    dec COL                  ; convert 1-based to 0-based (terminal origin is 1
                             ; ,1)
    dec ROW
    rts


;-------------------------------------------------------------------------------
; ADDRIGHT routine
; Garbles: A
; Conserves: X, Y
; Uses: ARRAYPTR, ZPBUF1, WIDTHMIN1
;
; Increments the right neighbor of the current cell.
; Wraps to the left if at the rightmost column.
;-------------------------------------------------------------------------------
addright:
    cpx WIDTHMIN1             ; Check if at rightmost column
    bne :+                    ; If not, move one cell right normally
    sec
    lda ARRAYPTR              ; Load low byte of current cell address
    sbc WIDTHMIN1             ; Wrap to first column (subtract WIDTH - 1)
    sta ZPBUF1
    lda ARRAYPTR + 1          ; Load high byte
    sbc #0                    ; Subtract carry
    sta ZPBUF1 + 1
    jmp @increment
:
    clc
    lda ARRAYPTR              ; Normal case: move one column right
    adc #1
    sta ZPBUF1
    lda ARRAYPTR + 1
    adc #0
    sta ZPBUF1 + 1
@increment:
    lda (ZPBUF1)              ; Load neighbor cell
    inc                       ; Increment neighbor count
    sta (ZPBUF1)              ; Store updated value
    rts

;-------------------------------------------------------------------------------
; ADDLEFT routine
; Garbles: A
; Conserves: X, Y
; Uses: ARRAYPTR, ZPBUF1, WIDTHMIN1
;
; Increments the left neighbor of the current cell.
; Wraps to the right if at the leftmost column.
;-------------------------------------------------------------------------------
addleft:
    cpx #0                    ; Check if at leftmost column
    bne :+                    ; If not, move one cell left normally
    clc
    lda ARRAYPTR              ; Load low byte of current cell address
    adc WIDTHMIN1             ; Wrap to last column (add WIDTH - 1)
    sta ZPBUF1
    lda ARRAYPTR + 1          ; Load high byte
    adc #0                    ; Add carry
    sta ZPBUF1 + 1
    jmp @increment
:
    sec
    lda ARRAYPTR              ; Normal case: move one column left
    sbc #1
    sta ZPBUF1
    lda ARRAYPTR + 1
    sbc #0
    sta ZPBUF1 + 1
@increment:
    lda (ZPBUF1)              ; Load neighbor cell
    inc                       ; Increment neighbor count
    sta (ZPBUF1)              ; Store updated value
    rts

;-------------------------------------------------------------------------------
; ADDBELLOW routine
; Garbles: A
; Conserves: X, Y
; Uses: ARRAYPTR, ZPBUF1, WIDTH, HEIGHTMIN1, WIDTHHEIGHTMIN1
;
; Increments the cell directly below the current one.
; Wraps to the top row if at the bottom.
;-------------------------------------------------------------------------------
addbellow:
    cpy HEIGHTMIN1            ; Check if at bottom row
    bne :+                    ; If not, use normal case
    sec
    lda ARRAYPTR              ; Load low byte
    sbc WIDTHHEIGHTMIN1       ; Wrap to top row
    sta ZPBUF1
    lda ARRAYPTR + 1
    sbc WIDTHHEIGHTMIN1 + 1
    sta ZPBUF1 + 1
    jmp @increment
:   
    clc
    lda ARRAYPTR              ; Normal case: move one row down
    adc WIDTH
    sta ZPBUF1
    lda ARRAYPTR + 1
    adc #0
    sta ZPBUF1 + 1
@increment:
    lda (ZPBUF1)              ; Load neighbor cell
    inc                       ; Increment neighbor count
    sta (ZPBUF1)              ; Store updated value
    rts

;-------------------------------------------------------------------------------
; ADDABOVE routine
; Garbles: A
; Conserves: X, Y
; Uses: ARRAYPTR, ZPBUF1, WIDTH, WIDTHHEIGHTMIN1
;
; Increments the cell directly above the current one.
; Wraps to the bottom row if at the top.
;-------------------------------------------------------------------------------
addabove:
    cpy #0                    ; Check if at top row
    bne :+                    ; If not, use normal case
    clc
    lda ARRAYPTR              ; Wrap to bottom row
    adc WIDTHHEIGHTMIN1
    sta ZPBUF1
    lda ARRAYPTR + 1
    adc WIDTHHEIGHTMIN1 + 1
    sta ZPBUF1 + 1
    jmp @increment
:   
    sec
    lda ARRAYPTR              ; Normal case: move one row up
    sbc WIDTH
    sta ZPBUF1
    lda ARRAYPTR + 1
    sbc #0
    sta ZPBUF1 + 1
@increment:
    lda (ZPBUF1)              ; Load neighbor cell
    inc                       ; Increment value
    sta (ZPBUF1)              ; Store updated value
    rts

;-------------------------------------------------------------------------------
; ADDOFSETLEFT routine
; Garbles: A
; Conserves: X, Y
; Uses: ZPBUF1, ZPBUF2, WIDTHMIN1
;
; Increments the cell one to the left of the one pointed by ZPBUF1.
; Used for diagonal left neighbors (above-left or below-left).
; Wraps horizontally if needed.
;-------------------------------------------------------------------------------
addofsetleft:
    cpx #0                    ; Check if at left edge
    bne :+                    ; If not, use normal case
    clc
    lda ZPBUF1                ; Wrap to right edge
    adc WIDTHMIN1
    sta ZPBUF2
    lda ZPBUF1 + 1
    adc #0
    sta ZPBUF2 + 1
    jmp @increment
:   
    sec
    lda ZPBUF1                ; Normal case: one cell left
    sbc #1
    sta ZPBUF2
    lda ZPBUF1 + 1
    sbc #0
    sta ZPBUF2 + 1
@increment:
    lda (ZPBUF2)              ; Load cell
    inc
    sta (ZPBUF2)              ; Store incremented result
    rts

;-------------------------------------------------------------------------------
; ADDOFSETRIGHT routine
; Garbles: A
; Conserves: X, Y
; Uses: ZPBUF1, ZPBUF2, WIDTHMIN1
;
; Increments the cell one to the right of the one pointed by ZPBUF1.
; Used for diagonal right neighbors (above-right or below-right).
; Wraps horizontally if needed.
;-------------------------------------------------------------------------------
addofsetright:
    cpx WIDTHMIN1             ; Check if at right edge
    bne :+                    ; If not, use normal case
    sec
    lda ZPBUF1                ; Wrap to left edge
    sbc WIDTHMIN1
    sta ZPBUF2
    lda ZPBUF1 + 1
    sbc #0
    sta ZPBUF2 + 1
    jmp @increment
:   
    clc
    lda ZPBUF1                ; Normal case: one cell right
    adc #1
    sta ZPBUF2
    lda ZPBUF1 + 1
    adc #0
    sta ZPBUF2 + 1
@increment:
    lda (ZPBUF2)              ; Load cell
    inc
    sta (ZPBUF2)              ; Store incremented result
    rts

;-------------------------------------------------------------------------------
; ADDNEIGHBORS routine
; Garbles: A
; Conserves: X, Y
;
; Adds +1 to the neighbor count of all 8 surrounding cells
; of the currently alive cell pointed to by ARRAYPTR.
;-------------------------------------------------------------------------------
addneighbors:
    jsr addabove               ; Add to cell directly above
    jsr addofsetright          ; Add to cell above-right
    jsr addofsetleft           ; Add to cell above-left
    jsr addleft                ; Add to cell directly left
    jsr addright               ; Add to cell directly right
    jsr addbellow              ; Add to cell directly below
    jsr addofsetright          ; Add to cell below-right
    jsr addofsetleft           ; Add to cell below-left
    rts                        


;-------------------------------------------------------------------------------
; COUNTNEIGHTBORS routine
; Garbles: A, X, Y
; Uses: ARRAYPTR, WIDTH, HEIGHT
;
; Scans the entire array and, for each **alive** cell (bit 7 set),
; calls addneighbors routine to increment the neighbor count for its 8 neighbors
;-------------------------------------------------------------------------------
countneightbors:
    ldy #0                      ; Initialize Y as the row counter
@row:
    ldx #0                      ; Initialize X as the column counter
@col:
    lda (ARRAYPTR)              ; Load current cell value
    and #%10000000              ; Mask out everything except alive flag (bit 7)
    cmp #0
    beq @dead                   ; If bit 7 not set (cell is dead), skip to next
    jsr addneighbors            ; If alive, increment neighbor count of 
                                ; surrounding cells
@dead:
    inc ARRAYPTR                ; Move pointer to next cell in row
    bne :+                      ; If no carry from low byte, skip
    inc ARRAYPTR+1              ; If carry, increment high byte of pointer
:
    inx                         ; Next column
    cpx WIDTH
    bne @col                    ; Continue row loop if not at row end
    iny                         ; Next row
    cpy HEIGHT
    bne @row                    ; Continue column loop if not at last row
    rts                         ; Done scanning array

;-------------------------------------------------------------------------------
; EVOLVEARRAY routine
; Garbles: A, X, Y
; Uses: ARRAYPTR, WIDTH, HEIGHT
;
; Applies Conway's Game of Life rules to each cell in the array:
; - Bit 7 (MSB) stores current alive/dead state
; - Lower 4 bits store neighbor count (0–8)
; Updates cell state and renders changes to terminal output.
;-------------------------------------------------------------------------------
evolvearray:
    ldy #0                     ; Initialize Y as the row counter
@row:
    ldx #0                     ; Initialize X as the column counter
@col:
    lda (ARRAYPTR)             ; Load current cell value
    bpl @dead                  ; Isolate alive state (bit 7) If not alive, 
                               ; handle dead cell logic
    lda (ARRAYPTR)
    and #%00001111             ; Mask to get neighbor count (lower 4 bits)
    cmp #2
    beq @stayalive             ; Stay alive with 2 neighbors
    cmp #3
    beq @stayalive             ; Stay alive with 3 neighbors
    lda #0
    sta (ARRAYPTR)             ; Mark cell as dead
    jsr movecursor             ; Move cursor to this cell’s position
    lda #' '                   ; Render as empty space
    jsr putch
    jmp @iterate
@stayalive:
    lda #%10000000             ; Set alive flag (bit 7), zero out neighbors
    sta (ARRAYPTR)
    jmp @iterate
@dead:
    lda (ARRAYPTR)
    and #%00001111             ; Get neighbor count
    cmp #3
    bne @staydead              ; Only revive with exactly 3 neighbors
    lda #%10000000
    sta (ARRAYPTR)             ; Mark as alive
    jsr movecursor
    lda #'#'                   ; Render alive cell
    jsr putch
    jmp @iterate
@staydead:
    lda #0
    sta (ARRAYPTR)             ; Keep dead with 0 neighbors
@iterate:
    inc ARRAYPTR               ; Move to next cell in row (low byte)
    bne :+                     ; If no carry, skip
    inc ARRAYPTR+1             ; Otherwise, increment high byte
:
    inx                        ; Move to next column
    cpx WIDTH
    bne @col                   ; Loop through columns
    iny                        ; Move to next row
    cpy HEIGHT
    bne @row                   ; Loop through rows
    rts                        

;-------------------------------------------------------------------------------
; MAINLOOP routine
; Garbles: A, X, Y
; Uses: WIDTH, HEIGHT, WIDTHMIN1, HEIGHTMIN1, ARRAYPTR, ARRAY
;
; Main loop for running the Game of Life:
; - Initializes cursor state
; - Repeatedly computes neighbors and evolves the array
; - Handles user keypresses: 'Q' to quit, 'P' to pause
;-------------------------------------------------------------------------------
mainloop:
    jsr hidecursor              ; Hide the cursor for cleaner display
@loop:
    lda #<ARRAY                 ; Set ARRAYPTR to point to the start of ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR + 1
    jsr countneightbors         ; Count neighbors and store in lowest four bits 
                                ; of array values
    lda #<ARRAY                 ; Reset ARRAYPTR again to start of ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR + 1
    jsr evolvearray             ; Apply evolution rules based on neighbor counts
    jsr getch                   ; Wait for a keypress (non-blocking or blocking)
    jsr chartoupper             ; Convert character to uppercase for simplicity
    cmp #'Q'                    ; Quit if user presses 'Q'
    beq @exit
    cmp #'P'                    ; Pause if user presses 'P'
    beq @pause
    jmp @loop                   ; Continue simulation loop
@exit:
    rts                         ; Return to caller 
@pause:
    jsr readposition
    lda COL
    sta XPOS
    lda ROW
    sta YPOS
    jsr showcursor              ; Show cursor while paused
    jsr usercontrol             ; Enter user control mode (e.g., allow 
                                ; editing/input)

;-------------------------------------------------------------------------------
; STEP routine
; Garbles: A, X, Y
; Uses: WIDTH, HEIGHT, WIDTHMIN1, HEIGHTMIN1, ARRAYPTR
;
; similar to mainloop for running the Game of Life:
; - Hides cursor state, and shows it again after done
; - Computes neighbors and evolves the array once
; - End with retracking XPOS, and YPOS 
;-------------------------------------------------------------------------------
step:
    jsr hidecursor              ; Hide the cursor for cleaner display
    lda #<ARRAY                 ; Set ARRAYPTR to point to the start of ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR + 1
    jsr countneightbors         ; Count neighbors and store in lowest four bits
                                ; of array values
    lda #<ARRAY                 ; Reset ARRAYPTR again to start of ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR + 1
    jsr evolvearray             ; Apply evolution rules based on neighbor counts
    jsr readposition
    lda COL
    sta XPOS
    lda ROW
    sta YPOS
    jsr showcursor              ; Show cursor
    rts

;-------------------------------------------------------------------------------
; CALCINDEX routine
; Conserves:     X, Y
; Garbles:       A
; Uses:          ROW, COL, INDEX, ZPBUF1
;
; Calculates a linear array index from 2D coordinates:
;     INDEX = ROW × WIDTH + COL
; The multiplication is performed using the shift-add method (8-bit × 8-bit),
; with the result stored in the 16-bit variable INDEX.
;-------------------------------------------------------------------------------
calcindex:
    phx                            
    lda WIDTH                      ; Load WIDTH (multiplier)
    sta ZPBUF1                     ; Store in ZPBUF1 (low byte)
    stz ZPBUF1 + 1                 ; Zero high byte of multiplicand (ROW)
    lda COL                        ; Load COL (the additive offset)
    sta INDEX                      ; Store in INDEX (starting value)
    stz INDEX+1                    ; Clear high byte of INDEX
    ldx #8                         ; 8 bit shift as multiplier is 8 bits
@loop:
    lsr ZPBUF1                     ; Shift right multiplier (low byte)
    bcc @skipadd                   ; If LSB is 0, skip addition
    clc
    lda INDEX                      ; Add ROW to INDEX (low byte)
    adc ROW
    sta INDEX
    lda INDEX+1                    ; Add carry + ZPBUF1+1 to high byte
    adc ZPBUF1 + 1
    sta INDEX+1
@skipadd:
    asl ROW                        ; Shift multiplicand (ROW)
    rol ZPBUF1 + 1                 ; Rotate into high byte (multiplicand becomes
                                   ; 16-bit)
    dex                            
    bne @loop                      
    plx                            
    rts                            

;-------------------------------------------------------------------------------
; movecursor routine
; Garbles: A
; Conserves: X, Y
; Uses: X, Y
;
; Calls ANSI force cursor command
;-------------------------------------------------------------------------------
movecursor:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    tya                     ; Transfer Y (ROW) to A 
    phx                     ; Push X, Y to stack
    phy
    inc                     ; Increment A as ANSI counts from 1
    jsr putdec              ; puts ROW
    ply                     ; Pull Y, X from stack
    plx
    lda #';'                ; Semi colon separates ROW from COL
    jsr putch
    txa                     ; Transfer X (COL) to A 
    phx                     ; Push X, Y to stack
    phy
    inc                     ; Increment A as ANSI counts from 1
    jsr putdec              ; puts COL
    ply                     ; Pull Y, X from stack
    plx
    lda #'f'                ; Final character tells ANSI sequence is done
    jsr putch
    rts

;-------------------------------------------------------------------------------
; SHOWCURSOR routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI show cursor command
;-------------------------------------------------------------------------------
showcursor:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'?'                ; Next set of characters are the show cursor command
    jsr putch
    lda #'2'
    jsr putch
    lda #'5'
    jsr putch
    lda #'h'
    jsr putch
    rts

;-------------------------------------------------------------------------------
; HIDECURSOR routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI hide cursor command
;-------------------------------------------------------------------------------
hidecursor:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'?'                ; Next set of characters are the hide cursor command
    jsr putch
    lda #'2'
    jsr putch
    lda #'5'
    jsr putch
    lda #'l'
    jsr putch
    rts

;-------------------------------------------------------------------------------
; GOUP routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI move cursor up command
;-------------------------------------------------------------------------------
goup:
    lda YPOS                ; if at top do not dec counter
    cmp #0
    beq @skip
    dec YPOS
@skip:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'A'                ; ANSI move up command
    jsr putch
    rts

;-------------------------------------------------------------------------------
; GODOWN routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI move cursor down command
;-------------------------------------------------------------------------------
godown:
    lda YPOS                ; if at bottom exit
    cmp HEIGHTMIN1
    beq @exit
    inc YPOS
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'B'                ; ANSI move down command
    jsr putch
@exit:
    rts

;-------------------------------------------------------------------------------
; GOLEFT routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI move cursor left command
;-------------------------------------------------------------------------------
goleft:
    lda XPOS                ; if at left edge do not decrement XPOS counter
    cmp #0
    beq @skip
    dec XPOS
@skip:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'D'                ; ANSI move left command
    jsr putch
    rts

;-------------------------------------------------------------------------------
; GORIGHT routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI move cursor right command
;-------------------------------------------------------------------------------
goright:
    lda XPOS                ; If at right edge exit
    cmp WIDTHMIN1          
    beq @exit
    inc XPOS
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'C'                ; ANSI move right command
    jsr putch
@exit:
    rts

;-------------------------------------------------------------------------------
; RESET routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI reset command which clears screen and places cursor top left
;-------------------------------------------------------------------------------
reset:
    stz XPOS
    stz YPOS
    lda #ESC                ; Start new escape sequence
    jsr putch                
    lda #'c'                ; ANSI reset command
    jsr putch               
    rts                      
