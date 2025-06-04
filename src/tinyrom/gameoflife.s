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
READBUF           = $55      ; 9 bytes

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

; pi spigot table
.align 3
gameoflifetable:
    .byte $FF, $FF                          ; dashed line
    .byte <@gameoflifestr,  >@gameoflifestr
    .byte $FF, $FF                          ; dashed line
    .byte <@creditstr,      >@creditstr
    .byte <@davidstr,       >@davidstr
    .byte <@startstr,       >@startstr
    .byte <@backstr,        >@backstr
    .byte $FF, $FF                          ; dashed line
    .byte <@controlstr,     >@controlstr
    .byte $FF, $FF                          ; dashed line
    .byte <@controlstr1,    >@controlstr1
    .byte <@controlstr2,    >@controlstr2
    .byte <@controlstr3,    >@controlstr3
    .byte <@controlstr4,    >@controlstr4
    .byte <@exitstr,        >@exitstr
    .byte $FF, $FF                          ; dashed line
    .byte 0

; pi spigot strings
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
    .asciiz "(WASD) TO MOVE AROUND"
@controlstr2:
    .asciiz "(SPACE) TO PLACE OR REMOVE A CELL"
@controlstr3:
    .asciiz "(R) TO START"
@controlstr4:
    .asciiz "(P) TO PAUSE"

;-------------------------------------------------------------------------------
; RUNGAMEOFLIFE routine
; Garbles: A, X, Y
; Uses: gameoflifetable, ROW, COL, WIDTH, HEIGHT, NUMPOINTS, INDEX,
;       WIDTHHEIGHTMIN1, ARRAYPTR
;
; Initializes and launches the Game of Life program.
; Waits for spacebar to begin or 'B' to exit.
; Sets the board size based on current cursor position and
; initializes the simulation array to zeros.
;-------------------------------------------------------------------------------
rungameoflife:
    lda #<gameoflifetable     ; Load low byte of gameoflifetable string
    ldx #>gameoflifetable     ; Load high byte
    jsr printmenu             ; Print program title/menu
@start:
    jsr getch                 ; Wait for user input
    cmp #0
    beq @start                ; Ignore null characters
    cmp #' '
    beq :+                    ; If spacebar, start game
    jsr chartoupper
    cmp #'B'
    bne @start                ; If not 'B', loop again
    jmp @exit                 ; Exit on 'B'
:
    jsr chartoupper           ; Normalize to uppercase
    ldx #255                  ; Prepare to move cursor down-right 255 steps
@end:
    jsr godown                ; Move cursor down
    jsr goright               ; Move cursor right
    dex
    bne @end                  ; Loop until cursor is at bottom-right
    jsr readposition          ; Store cursor location in ROW and COL
    jsr reset                 ; Clear the screen and hide cursor
    lda ROW
    sta HEIGHT                ; Store bottom-most row
    inc HEIGHT                ; HEIGHT = ROW + 1
    lda COL
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
    jsr usercontrol           ; Enter interactive user control mode
@exit:
    jsr newline               ; Print newline before exiting
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
    cmp #'R'
    bne usercontrol           ; Unrecognized input → wait again
    jsr mainloop              ; Begin or resume simulation
    jsr showcursor
    jsr newline
    rts
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
;
; Requires: readposition to set ROW and COL,
;           calcindex to compute INDEX = ROW * WIDTH + COL.
;-------------------------------------------------------------------------------
placecell:
    jsr readposition          ; Get current cursor position → ROW, COL
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
    lda #ESC                  ; ESC
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
    dec COL                  ; convert 1-based to 0-based (terminal origin is 1,1)
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
; ADDNEIGHTBORS routine
; Garbles: A
; Conserves: X, Y
;
; Adds +1 to the neighbor count of all 8 surrounding cells
; of the currently alive cell pointed to by ARRAYPTR.
;-------------------------------------------------------------------------------
addneightbors:
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
; calls addneightbors routine to increment the neighbor count for its 8 neighbors.
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
    jsr addneightbors           ; If alive, increment neighbor count of surrounding cells
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
    and #%10000000             ; Isolate alive state (bit 7)
    beq @dead                  ; If not alive, handle dead cell logic
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
; Uses: WIDTH, HEIGHT, WIDTHMIN1, HEIGHTMIN1, ARRAYPTR
;
; Main loop for running the Game of Life:
; - Initializes screen/cursor state
; - Repeatedly computes neighbors and evolves the array
; - Handles user keypresses: 'Q' to quit, 'P' to pause
;-------------------------------------------------------------------------------
mainloop:
    jsr hidecursor              ; Hide the cursor for cleaner display
    lda WIDTH
    sta WIDTHMIN1               ; Store WIDTH and HEIGHT minus one for bounds
    dec WIDTHMIN1
    lda HEIGHT 
    sta HEIGHTMIN1
    dec HEIGHTMIN1
@loop:
    lda #<ARRAY                 ; Set ARRAYPTR to point to the start of ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR + 1
    jsr countneightbors         ; Count neighbors and store in lowest four bits of array values
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
    rts                         ; Return to caller (likely ends program)
@pause:
    jsr showcursor              ; Show cursor while paused
    jsr usercontrol             ; Enter user control mode (e.g., allow editing/input)

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
    rol ZPBUF1 + 1                 ; Rotate into high byte (multiplicand becomes 16-bit)
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
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'A'                ; ANSI move up command
    jsr putch
    rts

;-------------------------------------------------------------------------------
; GOLEFT routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI move cursor left command
;-------------------------------------------------------------------------------
goleft:
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'D'                ; ANSI move left command
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
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'B'                ; ANSI move down command
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
    lda #ESC                ; Start new escape sequence
    jsr putch
    lda #'['                ; CSI
    jsr putch
    lda #'C'                ; ANSI move right command
    jsr putch
    rts

;-------------------------------------------------------------------------------
; RESET routine
; Garbles: A
; Conserves: X, Y
;
; Calls ANSI reset command which clears screen and places cursor top left
;-------------------------------------------------------------------------------
reset:
    lda #ESC                ; Start new escape sequence
    jsr putch                
    lda #'c'                ; ANSI reset command
    jsr putch               
    rts                      