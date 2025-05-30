.PSC02

; zp memory allocation
ARRAYPTR     = $40  ; 2 bytes
ARRAYEND     = $42  ; 2 bytes
ARRAYLENGTH  = $44  ; 2 bytes
ARRAYVALUE   = $46  ; 3 bytes
CARRY        = $49  ; 3 bytes 
PREDIGIT     = $4C  ; 1 byte
DIGITS       = $4D  ; 2 bytes
PRINTDOT     = $4F  ; 1 byte
INDEX        = $50  ; 3 bytes
DEN          = $53  ; 2 bytes
COLUMNS      = $55  ; 1 byte
COLUMNCTR    = $56  ; 1 byte
NINES        = $57  ; 1 byte
ZPBUF1       = $58  ; 2 byte
ZPBUF2       = $5A  ; 2 byte

; array memory allocation 
ARRAY = $0400 ; max 31486 bytes 0400 - 7EFE reserved in memory for max 4723 digits of pi

; import and exporting functions / constants
.include "constants.inc"
.include "functions.inc"

.import printmenu
.export spigotrun

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "CODE"

;-------------------------------------------------------------------------------
; SPIGOTRUN routine
; Conserves:    Y
; Garbles:      A, X
; Uses:         ZPBUF1, ZPBUF2, DIGITS, COLUMNCTR, COLUMNS
; 
; Handles user input for number of Pi digits and screen width, validates input,
; sets global parameters for the Pi spigot algorithm, then launches calculation.
;-------------------------------------------------------------------------------
spigotrun:
    lda #<pispigottable       ; Print the algorithm header using predefined pispigot_table
    ldx #>pispigottable
    jsr printmenu              
    lda #<digitsinputstr       ; Prompt user for digit count by printing digitsinputstr
    ldx #>digitsinputstr
    jsr putstr
    jsr userinput              ; getting user input, stored in ZPBUF1/2
    lda ZPBUF2                 ; Validate digit count (must be <= 4723)
    cmp #>4723
    bcc @validdigit            ; Definitely below limit
    bne @invalidinput          ; Definitely above limit
    lda ZPBUF1                 ; Low byte
    cmp #<4723
    bcc @validdigit            ; Valid input
    bne @invalidinput          ; Input too large
@validdigit:
    lda ZPBUF2                 ; Store digit count in DIGITS (16-bit value)
    sta DIGITS + 1  
    lda ZPBUF1
    sta DIGITS
    jsr calcarray              ; Compute array size for Pi generation based on digit count
    jsr newline
    lda #<screensizestr        ; Prompt user for screen width by printing screensizestr
    ldx #>screensizestr
    jsr putstr
    jsr userinput
    lda ZPBUF2                 ; Validate screen width (must be <= 254)
    cmp #0
    bne @invalidinput          ; High byte must be zero
    lda ZPBUF1
    cmp #255
    bcc @validcolumn
    bne @invalidinput          ; Too large
@validcolumn:
    sec                        ; Store screen width
    lda ZPBUF1
    sta COLUMNS                ; Full column width (raw input)
    sbc #3
    sta COLUMNCTR              ; First row needs space for pispigotstr
    jsr newline
    jsr newline
    lda #<pispigotstr          ; Print Pi label string before output
    ldx #>pispigotstr
    jsr putstr
    jsr pispigot               ; go to main routine
    jsr newline
    jsr newline
    rts
@invalidinput:
    jsr newline                ; Print error message for invalid input
    lda #<invalidinputstr
    ldx #>invalidinputstr
    jsr putstrnl
    rts

;-------------------------------------------------------------------------------
; SPIGOTQUIT routine
; Garbles:      A, X
; Uses:         SP
; 
; Exits the spigot program cleanly by adjusting the return stack.
; Skips over the return address of the main loop to effectively quit.
;-------------------------------------------------------------------------------
spigotquit:
    jsr newline         
    tsx                 ; Transfer stack pointer to X (get current SP value)
    inx
    inx
    inx
    inx                 ; Skip over 4 bytes (simulate return from nested calls)
    txs                 ; Set the updated SP
    rts 

pispigotstr: 
    .asciiz "Pi ="
digitsinputstr:
    .asciiz "Digits of Pi (max 4723): "
screensizestr:
    .asciiz "Screen Width (max 255): "
invalidinputstr:
    .asciiz "Invalid input provided!"

; pi spigot table
.align 32
pispigottable:
    .byte $FF, $FF                      ; dashed line
    .byte <@pispigotstr,    >@pispigotstr
    .byte $FF, $FF                      ; dashed line
    .byte <@creditstr,      >@creditstr
    .byte <@davidstr,       >@davidstr
    .byte <@exitstr,        >@exitstr
    .byte $FF, $FF                      ; dashed line
    .byte 0

; pi spigot strings
@pispigotstr:
    .asciiz "PI SPIGOT ALGORITHM"
@creditstr:
    .asciiz "ORIGINAL ALGORITHM BY RABINOWITS AND WAGON"
@davidstr:
    .asciiz "IMPLEMENTED BY DAVID WARRAND"
@exitstr:
    .asciiz "(Q) TO QUIT"

;-------------------------------------------------------------------------------
; USERINPUT routine
; Garbles:      A, X, Y
; Uses:         CMDBUF, CMDLENGTH, ZPBUF1, ZPBUF2
; 
; Handles character-by-character user input, including uppercase conversion,
; backspace handling, and command parsing into a decimal number in ZPBUF1/2.
;-------------------------------------------------------------------------------
userinput:
    jsr getch                ; Read character from keyboard
    cmp #0
    beq userinput            ; Ignore null characters
    jsr chartoupper          ; Convert to uppercase for consistent handling
    cmp #CR
    beq @userinputcomplete   ; If carriage return, input is done
    cmp #BS
    beq @backspace           ; Handle backspace manually
    cmp #'Q'
    bne :+                   ; If 'Q', quit the program
    jsr spigotquit
:
    ldx CMDLENGTH
    cpx #$05
    beq @userinputcomplete   ; Max 5 characters allowed in buffer
    jsr ischarnum
    bcs userinput            ; Skip non-numeric characters
    sta CMDBUF,x             ; Store valid number character
    jsr putch                ; Echo typed character
    inc CMDLENGTH
    jmp userinput            ; Loop for next character
@backspace:
    lda CMDLENGTH
    beq @exitbs              ; Ignore if buffer is empty
    jsr putbackspace         ; Visually remove character
    dec CMDLENGTH
@exitbs:
    jmp userinput            ; Continue accepting input
@userinputcomplete:
    ldx #0                
    stz ZPBUF1
    stz ZPBUF2
@decimalroutine:
    asl ZPBUF1               ; Multiply current ZPBUF by 10 using shifts (×2 + ×8)
    rol ZPBUF2               ; ×2
    lda ZPBUF2
    tay                      ; Store current hi-byte
    lda ZPBUF1
    asl ZPBUF1
    rol ZPBUF2               ; ×4
    asl ZPBUF1
    rol ZPBUF2               ; ×8 (cumulative)
    clc
    adc ZPBUF1               ; Add ×2 + ×8 = ×10
    sta ZPBUF1
    tya
    adc ZPBUF2
    sta ZPBUF2
    lda CMDBUF,x             ; Add current digit (CMDBUF[x] - '0') to ZPBUF
    sec
    sbc #'0'
    clc
    adc ZPBUF1
    sta ZPBUF1
    lda #0
    adc ZPBUF2
    sta ZPBUF2
    inx
    cpx CMDLENGTH
    bne @decimalroutine      ; Repeat for all characters
    jsr clearcmdbuf          ; Reset buffer for next use
    rts

;-------------------------------------------------------------------------------
; PISPIGOT routine
; Garbles:      A, X, Y
; Uses:         ARRAY, ARRAYPTR, ARRAYEND, CARRY, PREDIGIT, NINES, PRINTDOT
;
; Computes digits of Pi using a spigot algorithm and prints them as they are produced.
;-------------------------------------------------------------------------------
pispigot:
    stz NINES               ; Reset counter for trailing 9s
    lda #2
    sta PRINTDOT            ; Set dot printing state (prints dot after first digit)
    lda #$F0
    sta PREDIGIT            ; Initialize predigit to space (non-digit placeholder)
    lda #<ARRAY
    sta ARRAYPTR
    lda #>ARRAY
    sta ARRAYPTR+1          ; Set pointer to start of array
    ldx ARRAYLENGTH
    ldy ARRAYLENGTH+1       ; Load array size into X and Y
@initializearray:
    lda #2
    sta (ARRAYPTR)          ; Store 2 in low byte of array element
    inc ARRAYPTR
    bne :+
    inc ARRAYPTR+1
:
    lda #0
    sta (ARRAYPTR)          ; Store 0 in high byte of array element
    inc ARRAYPTR
    bne :+
    inc ARRAYPTR+1
:
    cpx #0
    bne :+
    dey                     ; Decrement high byte of counter if low byte hit 0
:
    dex
    bne @initializearray
    cpy #0
    bne @initializearray    ; Loop until X and Y are both zero (array fully initialized)
    lda ARRAYPTR
    bne :+
    dec ARRAYPTR+1
:
    dec ARRAYPTR            ; Adjust pointer to last high byte in array
    lda ARRAYPTR
    sta ARRAYEND
    lda ARRAYPTR+1
    sta ARRAYEND+1          ; Save final pointer location as ARRAYEND
@mainloop:
    jsr getch
    cmp #'q'
    bne :+
    jsr spigotquit
:
    cmp #'Q'
    bne :+
    jsr spigotquit          ; Allow both 'q' and 'Q' to quit
:
    lda ARRAYEND
    sta ARRAYPTR
    lda ARRAYEND+1
    sta ARRAYPTR+1          ; Reset pointer to end of array
    ldy ARRAYLENGTH+1
    ldx ARRAYLENGTH         ; Load array length into X/Y again
    stz CARRY
    stz CARRY+1
    stz CARRY+2             ; Clear multi-byte carry register
    jsr carryloop           ; Core processing loop for array transformation
    jsr divmodcarry10       ; Extract one digit using final carry division
    jsr predigitcheck       ; Print or defer digit depending on predigit/carry state
    lda DIGITS
    bne :+
    lda DIGITS+1
    beq @exit               ; Exit if DIGITS == 0
    dec DIGITS+1
:
    dec DIGITS              ; Decrement digit counter
    jmp @mainloop
@exit:
    jsr columncheck
    lda PREDIGIT
    adc #'0'
    jsr putch               ; Print final predigit and exit
    rts

;-------------------------------------------------------------------------------
; COLUMNCHECK routine
; Conserves     X, Y
; Garbles:      A
; Uses:         COLUMNCTR, COLUMNS
;
; Decrements the column counter and prints a newline when it wraps to zero.
;-------------------------------------------------------------------------------
columncheck:
    dec COLUMNCTR           ; Decrement printable column count
    bne :+                  ; If not zero, skip newline
    lda COLUMNS
    sta COLUMNCTR           ; Reset counter to full width
    jsr newline             ; Print newline after full row
:
    rts


;-------------------------------------------------------------------------------
; PREDIGITCHECK routine
; Conserves:    X, Y
; Garbles:      A
; Uses:         CARRY, PREDIGIT, NINES, PRINTDOT
;
; Handles formatting and output of the next digit based on carry result.
;-------------------------------------------------------------------------------
predigitcheck:
    phx                            ; Save X register
    lda CARRY                      ; Check if carry is 9
    cmp #9
    beq @nine
    cmp #10                        ; Check if carry is 10
    beq @ten
    jsr columncheck                ; Normal case: print predigit
    lda PREDIGIT
    adc #'0'
    jsr putch
    lda PRINTDOT                   ; Check if dot should be printed
    beq :+
    dec PRINTDOT
    bne :+
    lda #'.'
    jsr columncheck
    jsr putch
:
    ldx NINES                      ; If any held 9s, flush them
    beq @updatepredigit
:
    jsr columncheck
    lda #'9'
    jsr putch
    dex
    bne :-
    stz NINES
@updatepredigit:
    lda CARRY                      ; Update predigit with current digit
    sta PREDIGIT
    jmp @exit
@ten:
    clc                            ; Carry was 10: increment predigit and flush zeros
    inc PREDIGIT
    jsr columncheck
    lda PREDIGIT
    adc #'0'
    jsr putch
    ldx NINES
    beq @resetafterten
:
    jsr columncheck
    lda #'0'
    jsr putch
    dex
    bne :-
@resetafterten:
    stz PREDIGIT
    stz NINES
    jmp @exit
@nine:
    inc NINES                      ; Carry is 9: hold the 9
@exit:
    plx                            ; Restore X register
    rts

;-------------------------------------------------------------------------------
; CARRYLOOP routine
; Garbles:      A, X, Y
; Uses:         ARRAYPTR, ARRAYVALUE, CARRY, INDEX, DEN
;
; Core loop of the Pi spigot algorithm that updates the carry by walking through
; the array in reverse, using mixed radix arithmetic.
;-------------------------------------------------------------------------------
carryloop:
    stz INDEX+2                          ; Clear high byte of 24-bit INDEX (not used but good practice)
    txa
    sta INDEX                            ; Set INDEX = YX (current array index)
    sta DEN                              ; Same value is used as denominator base
    tya
    sta INDEX+1
    sta DEN+1
    asl DEN
    rol DEN+1                            ; Multiply DEN by 2 (DEN = INDEX * 2)
    lda DEN                              ; Subtract 1 from DEN (DEN = 2*INDEX - 1)
    cmp #0
    bne :+
    dec DEN+1
:
    dec DEN
    jsr multipycarrybynum                ; carry = carry * numerator (INDEX)
    lda (ARRAYPTR)
    sta ARRAYVALUE+1                     ; Load high byte of array element
    lda ARRAYPTR
    bne :+
    dec ARRAYPTR+1
:
    dec ARRAYPTR
    lda (ARRAYPTR)
    sta ARRAYVALUE                       ; Load low byte of array element
    jsr multipyarrayby10andaddtocarry    ; carry += array * 10
    jsr divmodcarryden                   ; array = carry % DEN, carry = carry / DEN
    lda ARRAYPTR
    bne :+
    dec ARRAYPTR+1
:
    dec ARRAYPTR                         ; Move to previous array element (2 bytes per element)
    lda ARRAYPTR
    bne :+
    dec ARRAYPTR+1
:
    dec ARRAYPTR
    cpx #0
    bne :+
    dey
:
    dex
    bne carryloop                        ; Loop while X ≠ 0
    cpy #0
    bne carryloop                        ; Loop while Y ≠ 0
    rts

;-------------------------------------------------------------------------------
; DIVMODCARRY10 routine
; Conserves     X, Y
; Garbles:      A
; Uses:         CARRY, ARRAYVALUE, array
;
; Performs 16-bit divided by 8-bit division: (CARRY / 10), remainder into 
; ARRAYVALUE, and quotient into CARRY
;-------------------------------------------------------------------------------
divmodcarry10:
    phx                             ; Preserve X
    stz ARRAYVALUE                  ; Clear quotient low byte
    stz ARRAYVALUE + 1              ; Clear quotient high byte
    ldx #8                          ; 8 bits to divide
@divloop:
    rol CARRY                       ; Shift dividend into remainder
    rol ARRAYVALUE
    sec
    lda ARRAYVALUE
    sbc #10                         ; Subtract divisor low byte
    sta ZPBUF1
    lda ARRAYVALUE + 1
    sbc #0                          ; Subtract high byte
    bcc @nosubtract                 ; Skip if remainder < 10
    sta ARRAYVALUE + 1              ; Store result high byte
    lda ZPBUF1
    sta ARRAYVALUE                  ; Store result low byte
@nosubtract:
    dex
    bne @divloop                    ; Loop until all bits processed
    rol CARRY                       ; Shift final quotient bit into carry
    lda ARRAYVALUE + 1
    sta ARRAY + 1                   ; Store remainder high byte
    lda ARRAYVALUE
    sta ARRAY                       ; Store remainder low byte
    plx
    rts

;-------------------------------------------------------------------------------
; DIVMODCARRYDEN routine
; Conserves     X, Y
; Garbles:      A
; Uses:         CARRY (24-bit), DEN (16-bit), ARRAYVALUE, ARRAYPTR
;
; Performs 24-bit ÷ 16-bit division: (CARRY / DEN)
; Stores remainder in array and keeps quotient in CARRY.
;-------------------------------------------------------------------------------
divmodcarryden:
    phx                             ; Preserve X
    stz ARRAYVALUE                  ; Clear remainder low byte
    stz ARRAYVALUE + 1              ; Clear remainder high byte
    ldx #24                         ; 24 bits to divide
@divloop:
    rol CARRY                       ; Shift dividend into remainder
    rol CARRY + 1
    rol CARRY + 2
    rol ARRAYVALUE
    rol ARRAYVALUE + 1
    sec
    lda ARRAYVALUE
    sbc DEN                         ; Subtract divisor low byte
    sta ZPBUF1
    lda ARRAYVALUE + 1
    sbc DEN + 1                     ; Subtract high byte
    bcc @nosubtract                ; Skip if remainder < divisor
    sta ARRAYVALUE + 1              ; Store updated high byte
    lda ZPBUF1
    sta ARRAYVALUE                  ; Store updated low byte
@nosubtract:
    dex
    bne @divloop                    ; Continue loop
    rol CARRY
    rol CARRY + 1
    rol CARRY + 2                   ; Final shift to complete quotient
    lda ARRAYVALUE
    sta (ARRAYPTR)                  ; Store remainder low byte
    inc ARRAYPTR
    bne :+
    inc ARRAYPTR + 1
:
    lda ARRAYVALUE + 1
    sta (ARRAYPTR)                 ; Store remainder high byte
    plx
    rts

;-------------------------------------------------------------------------------
; MULTIPYCARRYBYNUM routine
; Conserves     X, Y
; Garbles:      A
; Uses:         CARRY, INDEX, ZPBUF1
;
; Performs 16-bit × 16-bit multiplication, result stored as 24-bit in CARRY.
; CARRY × INDEX → CARRY (result)
;-------------------------------------------------------------------------------
multipycarrybynum:
    phx                            ; Save X
    lda CARRY
    sta ZPBUF1                     ; Copy CARRY to ZPBUF1 (multiplier)
    lda CARRY+1
    sta ZPBUF1+1
    stz CARRY                      ; Clear result low
    stz CARRY+1                    ; Clear result mid
    stz CARRY+2                    ; Clear result high
    stz INDEX+2                    ; Ensure multiplicand is 16-bit
    ldx #16                        ; 16 bits in multiplier
@loop:
    lsr ZPBUF1+1                   ; Shift right into carry
    ror ZPBUF1
    bcc @skipadd                  ; If bit is 0, skip addition
    clc
    lda CARRY
    adc INDEX
    sta CARRY
    lda CARRY+1
    adc INDEX+1
    sta CARRY+1
    lda CARRY+2
    adc INDEX+2
    sta CARRY+2
@skipadd:
    asl INDEX                      ; Shift multiplicand left
    rol INDEX+1
    rol INDEX+2
    dex
    bne @loop
    plx
    rts

;-------------------------------------------------------------------------------
; MULTIPYARRAYBY10ANDADDTOCARRY routine
; Conserves:    X, Y
; Garbles:      A
; Uses:         ARRAYVALUE, CARRY
;
; Multiplies ARRAYVALUE (16 bits) by 10 and adds result to CARRY (24-bit add).
;-------------------------------------------------------------------------------
multipyarrayby10andaddtocarry:
    stz ARRAYVALUE+2               ; Extend to 24 bits
    asl ARRAYVALUE                 ; ×2
    rol ARRAYVALUE+1
    rol ARRAYVALUE+2
    clc
    lda ARRAYVALUE
    adc CARRY
    sta CARRY
    lda ARRAYVALUE+1
    adc CARRY+1
    sta CARRY+1
    lda ARRAYVALUE+2
    adc CARRY+2
    sta CARRY+2
    asl ARRAYVALUE                 ; ×4 (shift again)
    rol ARRAYVALUE+1
    rol ARRAYVALUE+2
    asl ARRAYVALUE                 ; ×8 (shift again)
    rol ARRAYVALUE+1
    rol ARRAYVALUE+2
    clc
    lda CARRY
    adc ARRAYVALUE
    sta CARRY
    lda CARRY+1
    adc ARRAYVALUE+1
    sta CARRY+1
    lda CARRY+2
    adc ARRAYVALUE+2
    sta CARRY+2
    rts

;-------------------------------------------------------------------------------
; CALCARRAY routine
; Conserves:    Y
; Garbles:      A,X
; Uses:         ZPBUF1, ZPBUF2
; Input: DIGITS
;
; Mulitplies DIGITS by 10 then divides by 3 
; is found. Assumes that STRLB is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
calcarray:
    lda DIGITS                      ; loading digits into length
    sta ARRAYLENGTH
    lda DIGITS + 1
    sta ARRAYLENGTH + 1
    clc
    rol ARRAYLENGTH                 ; multiplying length by 2
    rol ARRAYLENGTH + 1
    lda ARRAYLENGTH                 ; storing length times 2 in X and Y
    tax 
    lda ARRAYLENGTH + 1
    tay 
    rol ARRAYLENGTH                 ; multiplying length times 4
    rol ARRAYLENGTH + 1
    rol ARRAYLENGTH
    rol ARRAYLENGTH + 1
    clc
    txa                             ; adding length times 2 to length times 8
    adc ARRAYLENGTH
    sta ARRAYLENGTH                 ; resulting low byte after times 10 operation
    tya 
    adc ARRAYLENGTH + 1
    sta ARRAYLENGTH + 1             ; resulting high byte after times 10 operation
    stz ZPBUF1                      ; using ZPBUF1 as remainder
    stz ZPBUF1 + 1
    ldx #16                         ; 16 bits to process for long division
@divloop:                           ; dividing by 3 cannot be done simply thus long division is performed
    rol ARRAYLENGTH                 ; Shift dividend left into remainder
    rol ARRAYLENGTH + 1
    rol ZPBUF1
    rol ZPBUF1 + 1
    sec                             ; Try subtracting divisor from remainder
    lda ZPBUF1
    sbc #3                          ; subtract low byte
    sta ZPBUF2                      ; using ZPBUF2 as a temporary value holder
    lda ZPBUF1 + 1
    sbc #0                          ; subtract high byte
    bcc @nosubtract                ; if remainder < divisor, skip setting quotient bit
    sta ZPBUF1 + 1                  ; If subtraction succeeded, store result
    lda ZPBUF2
    sta ZPBUF1
@nosubtract:
    dex
    bne @divloop
    rol ARRAYLENGTH                 ; final rol to have the quotient in the correct format
    rol ARRAYLENGTH + 1   
    rts