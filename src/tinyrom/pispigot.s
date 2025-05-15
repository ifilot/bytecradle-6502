; this code is a simple monitor class for the ByteCradle 6502

.PSC02

; zp memory allocation
strptr       = $40  ; 2 bytes
arrayptr     = $42  ; 2 bytes
predigit     = $44  ; 1 byte
message      = $45  ; 2 bytes
nines        = $47  ; 1 byte
length       = $48  ; 2 bytes
digits       = $4A  ; 2 bytes
temp         = $4C  ; 1 byte
arrayend     = $4D  ; 2 bytes
print_dot    = $4F  ; 1 byte
carry        = $50  ; 3 bytes 
index        = $53  ; 3 bytes
ten          = $56  ; 1 bytes
arrayvalue   = $57  ; 3 bytes
den          = $5A  ; 2 bytes
multiplier   = $5C  ; 2 bytes

; array memory allocation
array = $0400 ; max 31486 bytes 0400 - 7EFE reserved in memory for max 4723 digits of pi

.include "constants.inc"
.include "functions.inc"
.export spigotrun

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "CODE"

;------------------------------------------------------
; Main routine
;-------------------------------------------------------------------------------
spigotrun:
    jsr newline
    ; loads pi string address into strptr which is the pointer used in the print subroutine
    lda #<beginstr
    ldx #>beginstr
    jsr putstrnl

    jsr newline
    jsr newline

    ; loads pi string address into strptr which is the pointer used in the print subroutine
    lda #<pispigotstr
    ldx #>pispigotstr
    jsr putstrnl

    ; initializing array pointer to the begin of the array
    lda #<array
    sta arrayptr
    lda #>array
    sta arrayptr + 1

    ; initializing the number of digits - 1 
    lda #<30
    sta digits
    lda #>30
    sta digits + 1

    ; Initialize the length of the array
    lda #<100
    sta length
    lda #>100
    sta length + 1


    ; going to the pispigot routine
    jsr pispigot

    rts

beginstr: .asciiz "Implementing the Pi Spigot Algorithm by Rabinowitz and Wagon:"
pispigotstr: .asciiz "Pi ="

;-------------------------------------------------------------------------------
; Pi Spigot routine
;-------------------------------------------------------------------------------
pispigot:
    ; initializing variables 

    ; nine counter to zero
    lda #0
    sta nines 

    ; loading 2 into counter used to print a dot after first digit
    lda #2  
    sta print_dot 

    ; loading space as first predigit
    lda #$F0 
    sta predigit 

    ldx length  ; loading low byte of array length into x
    ldy length + 1 ; loading high byte of array length into x

    ; loop which Initializes the array values to 2
@InitializeArray:
    ; loading 2 into low byte of array
    lda #2 
    sta (arrayptr)

    ; incrementing array pointer to high byte
    inc arrayptr
    bne :+
    inc arrayptr+1
:
    ; loading 0 into low byte of array
    lda #0
    sta (arrayptr)

    ; incrementing array pointer to low byte of next array value
    inc arrayptr
    bne :+
    inc arrayptr+1
:

    ; checking if low byte (X) is zero if it is decremnt high byte first
    cpx #0
    bne :+
    dey
:
    dex
    bne @InitializeArray

    ; checking if high byte is zero if it is array initializing is done
    cpy #0
    bne @InitializeArray
    
    ; array pointer is now pointing one value after the array
    ; correct by decrementing array pointer to high byte of last array value
    lda arrayptr
    bne :+
    dec arrayptr+1
:
    dec arrayptr

    ; store high byte address of final array value
    lda arrayptr
    sta arrayend
    lda arrayptr + 1
    sta arrayend + 1

    ; main loop which computes the digits of pi
@mainloop:
    ; start from end of array
    lda arrayend
    sta arrayptr
    lda arrayend + 1
    sta arrayptr + 1

    ; loading length of array into X and Y
    ldy length + 1
    ldx length

    ; carry for first value is zero
    lda #0
    sta carry
    sta carry+1
    sta carry+2

    ; go to inner loop
    jsr Carryloop

    ; final step which generates a final carry value
    jsr divmod_carry_10

    ; check final carry value and turn it into appropriate predigit or hold
    jsr predigit_check

    ; degrement degit if both low and high are zero then routine is done
    lda digits
    bne :+       
    lda digits + 1
    beq @exit         
    dec digits + 1   
:
    dec digits
    jmp @mainloop

@exit:
    ; print final predigit
    lda predigit
    adc '0'
    jsr putch

    rts

; routine which checks the final carry value
predigit_check:
    phx

    ; special conditions if carry is nine or ten
    lda carry
    cmp #9
    beq @nine

    cmp #10
    beq @ten

    ; print predigit
    lda predigit
    adc #'0' 
    jsr putch

    ; check if dot needs to be placed
    lda print_dot
    beq :+
    dec print_dot
    bne :+
    lda #'.' 
    jsr putch
:

    ; check if any nines need to be printed
    ldx nines
    beq @update_predigit

    ; flushing nines
:
    lda #'9' 
    jsr putch
    dex
    bne :-
    lda #0
    sta nines

@update_predigit:
    lda carry
    sta predigit
    jmp @exit

    ; carry is 10
@ten:
    ; incrementing predigit and printing
    clc
    inc predigit    
    lda predigit
    adc #'0' 
    jsr putch

    ; checking if any nines
    ldx nines
    beq @reset_after_ten

    ; flushing nines as zeros
:
    lda #'0' 
    jsr putch
    dex
    bne :-

@reset_after_ten:
    lda #0
    sta predigit
    sta nines
    jmp @exit

    ; carry is 9
@nine:
    ; number of nines held increassed by 1
    inc nines

@exit:
    plx
    rts

; carry loop which genererates the digits of pi
Carryloop:
    ; initializing
    lda #0
    sta index + 2

    ; generating numerator = index and denominator of mixed radix
    ; mixed radix is used to decode the array into the digits of pi
    txa 
    sta index
    sta den
    tya
    sta index + 1
    sta den + 1
    asl den
    rol den + 1

    ; Subtract 1 from the 16-bit value
    lda den
    cmp #0
    bne @skip_borrow1
    dec den + 1
@skip_borrow1:
    dec den

    ; multiplying carry by numerator of mixed radix
    jsr multipy_carry_by_num

    ; loading array
    lda (arrayptr)
    sta arrayvalue + 1
    lda arrayptr
    bne :+
    dec arrayptr+1
:
    dec arrayptr
    lda (arrayptr)
    sta arrayvalue

    ; multiplying array by 10 and adding to carry
    jsr multipy_array_by_10_and_add_to_carry

    ; dividing carry by denominator of mixed radix
    ; remainder is new array value and quotient is carry
    jsr divmod_carry_den

    ; decrement twice to point to the high byte of the next array value
    lda arrayptr
    bne :+
    dec arrayptr+1
:
    dec arrayptr
    lda arrayptr
    bne :+
    dec arrayptr+1
:
    dec arrayptr

    cpx #0
    bne :+
    dey
:
    dex
    bne Carryloop

    cpy #0
    bne Carryloop

    rts


; 16 bits / 8 bits (10) = 16 bit division algorithm
divmod_carry_10:
    phx
    phy
    ; Clear quotient and remainder
    lda #0

    sta arrayvalue
    sta arrayvalue + 1
    sta arrayvalue + 2

    ldx #8  ; 8 bits to process
@divloop:
    ; Shift dividend left into remainder
    rol carry 
    rol arrayvalue

    ; Try subtracting divisor from remainder
    sec
    lda arrayvalue
    sbc #10         ; subtract low byte
    sta temp
    lda arrayvalue + 1
    sbc #0     ; subtract high byte
    bcc @no_subtract    ; if remainder < divisor, skip setting quotient bit

    ; If subtraction succeeded, store result
    sta arrayvalue + 1
    lda temp
    sta arrayvalue

@no_subtract:
    dex
    bne @divloop

    rol carry

    lda arrayvalue + 1
    sta array + 1
    lda arrayvalue
    sta array

    ply
    plx
    rts

; 24 bits / 16 bits = 16 bit division algorithm
divmod_carry_den:
    phx
    phy
    ; Clear quotient and remainder
    lda #0
    sta arrayvalue
    sta arrayvalue + 1

    ldx #24  ; 24 bits to process
@divloop:
    ; Shift dividend left into remainder
    rol carry        
    rol carry + 1
    rol carry + 2    
    rol arrayvalue
    rol arrayvalue + 1

    ; Try subtracting divisor from remainder
    sec
    lda arrayvalue
    sbc den         ; subtract low byte
    sta temp
    lda arrayvalue + 1
    sbc den+1       ; subtract high byte
    bcc @no_subtract    ; if remainder < divisor, skip setting quotient bit

    ; If subtraction succeeded, store result and set quotient bit = 1
    sta arrayvalue + 1
    lda temp
    sta arrayvalue

@no_subtract:
    dex
    bne @divloop

    rol carry
    rol carry + 1
    rol carry + 2

    lda arrayvalue
    sta (arrayptr)
    inc arrayptr
    bne :+
    inc arrayptr+1
:
    lda arrayvalue + 1
    sta (arrayptr)

    ply
    plx
    rts

; 16 bits * 16 bits = 24 bit multiplication algorithm
; note: checked and product is 24 bits not 32 bits for number of digits
multipy_carry_by_num:
    phx
    ; Clear product (3 bytes)

    lda carry
    sta multiplier
    lda carry + 1
    sta multiplier+1

    lda #0
    sta carry
    sta carry+1
    sta carry+2

    ; Ensure multiplicand is 16-bit, and use 3-byte temp
    sta index+2

    ldx #16  ; 16 bits in multiplier
@loop:
    ; Shift right multiplier (LSB into carry flag)
    lsr multiplier + 1
    ror multiplier

    bcc @skip_add      ; if bit was 0, skip

    ; Add multiplicand to product (24-bit add)
    clc
    lda carry
    adc index
    sta carry

    lda carry+1
    adc index+1
    sta carry+1

    lda carry+2
    adc index+2
    sta carry+2

@skip_add:
    ; Shift multiplicand left 
    asl index
    rol index+1
    rol index+2

    dex
    bne @loop

    plx
    rts

;-------------------------------------------------------------------------------
; Multiply Array by 10 and add to Carry
;-------------------------------------------------------------------------------
multipy_array_by_10_and_add_to_carry:
    lda #0
    sta arrayvalue + 2           ; Ensure multiplicand is 16-bit, and use 3-byte temp
    asl arrayvalue               ; multiply by 2
    rol arrayvalue + 1
    rol arrayvalue + 2
    clc                          ; 24 bit add, adding array times 2 to carry
    lda arrayvalue
    adc carry
    sta carry
    lda arrayvalue + 1
    adc carry + 1
    sta carry + 1
    lda arrayvalue + 2
    adc carry + 2
    sta carry + 2
    asl arrayvalue               ; shift 24 bits left twice, multiply by 4
    rol arrayvalue + 1
    rol arrayvalue + 2
    asl arrayvalue
    rol arrayvalue + 1
    rol arrayvalue + 2
    clc                          ; 24 bit add, adding array times 8 to carry
    lda carry
    adc arrayvalue
    sta carry
    lda carry + 1
    adc arrayvalue + 1
    sta carry + 1
    lda carry + 2
    adc arrayvalue + 2
    sta carry + 2
    rts