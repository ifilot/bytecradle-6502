;
; Set of optcodes organized as 256 x 4 table: (1 KiB)
;

.segment "DATA"

;
; Addressing modes (operands):
; $00: implicit
; $01: absolute
; $02: absolutex
; $03: absolutey
; $04: accumulator
; $05: immediate
; $06: indirectx
; $07: indirecty
; $08: indirect
; $09: relative
; $0A: zeropage
; $0B: zeropagex
; $0C: zeropagey
; $0D: indirectzeropage
; $0E: absoluteindexedindirect
; $0F: zeropagerelative

optcodes:
    .byte "BRK ", $01, $00, $00, $00 
    .byte "ORA ", $02, $06, $00, $01 
    .byte "XXXX", $01, $FF, $00, $02
    .byte "XXXX", $01, $FF, $00, $03
    .byte "TSB ", $02, $0A, $00, $04 
    .byte "ORA ", $02, $0A, $00, $05 
    .byte "ASL ", $02, $0A, $00, $06 
    .byte "RMB0", $02, $0A, $00, $07 
    .byte "PHP ", $01, $00, $00, $08 
    .byte "ORA ", $02, $05, $00, $09 
    .byte "ASL ", $01, $04, $00, $0A 
    .byte "XXXX", $01, $FF, $00, $0B
    .byte "TSB ", $03, $01, $00, $0C 
    .byte "ORA ", $03, $01, $00, $0D 
    .byte "ASL ", $03, $01, $00, $0E 
    .byte "BBR0", $03, $0F, $00, $0F 
    .byte "BPL ", $02, $09, $00, $10 
    .byte "ORA ", $02, $07, $00, $11 
    .byte "ORA ", $02, $0D, $00, $12 
    .byte "XXXX", $01, $FF, $00, $13
    .byte "TRB ", $02, $0A, $00, $14 
    .byte "ORA ", $02, $0B, $00, $15 
    .byte "ASL ", $02, $0B, $00, $16 
    .byte "RMB1", $02, $0A, $00, $17 
    .byte "CLC ", $01, $00, $00, $18 
    .byte "ORA ", $03, $03, $00, $19 
    .byte "INC ", $01, $04, $00, $1A 
    .byte "XXXX", $01, $FF, $00, $1B
    .byte "TRB ", $03, $01, $00, $1C 
    .byte "ORA ", $03, $02, $00, $1D 
    .byte "ASL ", $03, $02, $00, $1E 
    .byte "BBR1", $03, $0F, $00, $1F 
    .byte "JSR ", $03, $01, $00, $20 
    .byte "AND ", $02, $06, $00, $21 
    .byte "XXXX", $01, $FF, $00, $22
    .byte "XXXX", $01, $FF, $00, $23
    .byte "BIT ", $02, $0A, $00, $24 
    .byte "AND ", $02, $0A, $00, $25 
    .byte "ROL ", $02, $0A, $00, $26 
    .byte "RMB2", $02, $0A, $00, $27 
    .byte "PLP ", $01, $00, $00, $28 
    .byte "AND ", $02, $05, $00, $29 
    .byte "ROL ", $01, $04, $00, $2A 
    .byte "XXXX", $01, $FF, $00, $2B
    .byte "BIT ", $03, $01, $00, $2C 
    .byte "AND ", $03, $01, $00, $2D 
    .byte "ROL ", $03, $01, $00, $2E 
    .byte "BBR2", $03, $0F, $00, $2F 
    .byte "BMI ", $02, $09, $00, $30 
    .byte "AND ", $02, $07, $00, $31 
    .byte "AND ", $02, $0D, $00, $32 
    .byte "XXXX", $01, $FF, $00, $33
    .byte "BIT ", $02, $0B, $00, $34 
    .byte "AND ", $02, $0B, $00, $35 
    .byte "ROL ", $02, $0B, $00, $36 
    .byte "RMB3", $02, $0A, $00, $37 
    .byte "SEC ", $01, $00, $00, $38 
    .byte "AND ", $03, $03, $00, $39 
    .byte "DEC ", $01, $04, $00, $3A 
    .byte "XXXX", $01, $FF, $00, $3B
    .byte "BIT ", $03, $02, $00, $3C 
    .byte "AND ", $03, $02, $00, $3D 
    .byte "ROL ", $03, $02, $00, $3E 
    .byte "BBR3", $03, $0F, $00, $3F 
    .byte "RTI ", $01, $00, $00, $40 
    .byte "EOR ", $02, $06, $00, $41 
    .byte "XXXX", $01, $FF, $00, $42
    .byte "XXXX", $01, $FF, $00, $43
    .byte "XXXX", $01, $FF, $00, $44
    .byte "EOR ", $02, $0A, $00, $45 
    .byte "LSR ", $02, $0A, $00, $46 
    .byte "RMB4", $02, $0A, $00, $47 
    .byte "PHA ", $01, $00, $00, $48 
    .byte "EOR ", $02, $05, $00, $49 
    .byte "LSR ", $01, $04, $00, $4A 
    .byte "XXXX", $01, $FF, $00, $4B
    .byte "JMP ", $03, $01, $00, $4C 
    .byte "EOR ", $03, $01, $00, $4D 
    .byte "LSR ", $03, $01, $00, $4E 
    .byte "BBR4", $03, $0F, $00, $4F 
    .byte "BVC ", $02, $09, $00, $50 
    .byte "EOR ", $02, $07, $00, $51 
    .byte "EOR ", $02, $0D, $00, $52 
    .byte "XXXX", $01, $FF, $00, $53
    .byte "XXXX", $01, $FF, $00, $54
    .byte "EOR ", $02, $0B, $00, $55 
    .byte "LSR ", $02, $0B, $00, $56 
    .byte "RMB5", $02, $0A, $00, $57 
    .byte "CLI ", $01, $00, $00, $58 
    .byte "EOR ", $03, $03, $00, $59 
    .byte "PHY ", $01, $00, $00, $5A 
    .byte "XXXX", $01, $FF, $00, $5B
    .byte "XXXX", $01, $FF, $00, $5C
    .byte "EOR ", $03, $02, $00, $5D 
    .byte "LSR ", $03, $02, $00, $5E 
    .byte "BBR5", $03, $0F, $00, $5F 
    .byte "RTS ", $01, $00, $00, $60 
    .byte "ADC ", $02, $06, $00, $61 
    .byte "XXXX", $01, $FF, $00, $62
    .byte "XXXX", $01, $FF, $00, $63
    .byte "STZ ", $02, $0A, $00, $64 
    .byte "ADC ", $02, $0A, $00, $65 
    .byte "ROR ", $02, $0A, $00, $66 
    .byte "RMB6", $02, $0A, $00, $67 
    .byte "PLA ", $01, $00, $00, $68 
    .byte "ADC ", $02, $05, $00, $69 
    .byte "ROR ", $01, $04, $00, $6A 
    .byte "XXXX", $01, $FF, $00, $6B
    .byte "JMP ", $03, $08, $00, $6C 
    .byte "ADC ", $03, $01, $00, $6D 
    .byte "ROR ", $03, $01, $00, $6E 
    .byte "BBR6", $03, $0F, $00, $6F 
    .byte "BVS ", $02, $09, $00, $70 
    .byte "ADC ", $02, $07, $00, $71 
    .byte "ADC ", $02, $0D, $00, $72 
    .byte "XXXX", $01, $FF, $00, $73
    .byte "STZ ", $02, $0B, $00, $74 
    .byte "ADC ", $02, $0B, $00, $75 
    .byte "ROR ", $02, $0B, $00, $76 
    .byte "RMB7", $02, $0A, $00, $77 
    .byte "SEI ", $01, $00, $00, $78 
    .byte "ADC ", $03, $03, $00, $79 
    .byte "PLY ", $01, $00, $00, $7A 
    .byte "XXXX", $01, $FF, $00, $7B
    .byte "JMP ", $03, $0E, $00, $7C 
    .byte "ADC ", $03, $02, $00, $7D 
    .byte "ROR ", $03, $02, $00, $7E 
    .byte "BBR7", $03, $0F, $00, $7F 
    .byte "BRA ", $02, $09, $00, $80 
    .byte "STA ", $02, $06, $00, $81 
    .byte "XXXX", $01, $FF, $00, $82
    .byte "XXXX", $01, $FF, $00, $83
    .byte "STY ", $02, $0A, $00, $84 
    .byte "STA ", $02, $0A, $00, $85 
    .byte "STX ", $02, $0A, $00, $86 
    .byte "SMB0", $02, $0A, $00, $87 
    .byte "DEY ", $01, $00, $00, $88 
    .byte "BIT ", $02, $05, $00, $89 
    .byte "TXA ", $01, $00, $00, $8A 
    .byte "XXXX", $01, $FF, $00, $8B
    .byte "STY ", $03, $01, $00, $8C 
    .byte "STA ", $03, $01, $00, $8D 
    .byte "STX ", $03, $01, $00, $8E 
    .byte "BBS0", $03, $0F, $00, $8F 
    .byte "BCC ", $02, $09, $00, $90 
    .byte "STA ", $02, $07, $00, $91 
    .byte "STA ", $02, $0D, $00, $92 
    .byte "XXXX", $01, $FF, $00, $93
    .byte "STY ", $02, $0B, $00, $94 
    .byte "STA ", $02, $0B, $00, $95 
    .byte "STX ", $02, $0C, $00, $96 
    .byte "SMB1", $02, $0A, $00, $97 
    .byte "TYA ", $01, $00, $00, $98 
    .byte "STA ", $03, $03, $00, $99 
    .byte "TXS ", $01, $00, $00, $9A 
    .byte "XXXX", $01, $FF, $00, $9B
    .byte "STZ ", $03, $01, $00, $9C 
    .byte "STA ", $03, $02, $00, $9D 
    .byte "STZ ", $03, $02, $00, $9E 
    .byte "BBS1", $03, $0F, $00, $9F 
    .byte "LDY ", $02, $05, $00, $A0 
    .byte "LDA ", $02, $06, $00, $A1 
    .byte "LDX ", $02, $05, $00, $A2 
    .byte "XXXX", $01, $FF, $00, $A3
    .byte "LDY ", $02, $0A, $00, $A4 
    .byte "LDA ", $02, $0A, $00, $A5 
    .byte "LDX ", $02, $0A, $00, $A6 
    .byte "SMB2", $02, $0A, $00, $A7 
    .byte "TAY ", $01, $00, $00, $A8 
    .byte "LDA ", $02, $05, $00, $A9 
    .byte "TAX ", $01, $00, $00, $AA 
    .byte "XXXX", $01, $FF, $00, $AB
    .byte "LDY ", $03, $01, $00, $AC 
    .byte "LDA ", $03, $01, $00, $AD 
    .byte "LDX ", $03, $01, $00, $AE 
    .byte "BBS2", $03, $0F, $00, $AF 
    .byte "BCS ", $02, $09, $00, $B0 
    .byte "LDA ", $02, $07, $00, $B1 
    .byte "LDA ", $02, $0D, $00, $B2 
    .byte "XXXX", $01, $FF, $00, $B3
    .byte "LDY ", $02, $0B, $00, $B4 
    .byte "LDA ", $02, $0B, $00, $B5 
    .byte "LDX ", $02, $0C, $00, $B6 
    .byte "SMB3", $02, $0A, $00, $B7 
    .byte "CLV ", $01, $00, $00, $B8 
    .byte "LDA ", $03, $03, $00, $B9 
    .byte "TSX ", $01, $00, $00, $BA 
    .byte "XXXX", $01, $FF, $00, $BB
    .byte "LDY ", $03, $02, $00, $BC 
    .byte "LDA ", $03, $02, $00, $BD 
    .byte "LDX ", $03, $03, $00, $BE 
    .byte "BBS3", $03, $0F, $00, $BF 
    .byte "CPY ", $02, $05, $00, $C0 
    .byte "CMP ", $02, $06, $00, $C1 
    .byte "XXXX", $01, $FF, $00, $C2
    .byte "XXXX", $01, $FF, $00, $C3
    .byte "CPY ", $02, $0A, $00, $C4 
    .byte "CMP ", $02, $0A, $00, $C5 
    .byte "DEC ", $02, $0A, $00, $C6 
    .byte "SMB4", $02, $0A, $00, $C7 
    .byte "INY ", $01, $00, $00, $C8 
    .byte "CMP ", $02, $05, $00, $C9 
    .byte "DEX ", $01, $00, $00, $CA 
    .byte "WAI ", $01, $00, $00, $CB 
    .byte "CPY ", $03, $01, $00, $CC 
    .byte "CMP ", $03, $01, $00, $CD 
    .byte "DEC ", $03, $01, $00, $CE 
    .byte "BBS4", $03, $0F, $00, $CF 
    .byte "BNE ", $02, $09, $00, $D0 
    .byte "CMP ", $02, $07, $00, $D1 
    .byte "CMP ", $02, $0D, $00, $D2 
    .byte "XXXX", $01, $FF, $00, $D3
    .byte "XXXX", $01, $FF, $00, $D4
    .byte "CMP ", $02, $0B, $00, $D5 
    .byte "DEC ", $02, $0B, $00, $D6 
    .byte "SMB5", $02, $0A, $00, $D7 
    .byte "CLD ", $01, $00, $00, $D8 
    .byte "CMP ", $03, $03, $00, $D9 
    .byte "PHX ", $01, $00, $00, $DA 
    .byte "STP ", $01, $00, $00, $DB 
    .byte "XXXX", $01, $FF, $00, $DC
    .byte "CMP ", $03, $02, $00, $DD 
    .byte "DEC ", $03, $02, $00, $DE 
    .byte "BBS5", $03, $0F, $00, $DF 
    .byte "CPX ", $02, $05, $00, $E0 
    .byte "SBC ", $02, $06, $00, $E1 
    .byte "XXXX", $01, $FF, $00, $E2
    .byte "XXXX", $01, $FF, $00, $E3
    .byte "CPX ", $02, $0A, $00, $E4 
    .byte "SBC ", $02, $0A, $00, $E5 
    .byte "INC ", $02, $0A, $00, $E6 
    .byte "SMB6", $02, $0A, $00, $E7 
    .byte "INX ", $01, $00, $00, $E8 
    .byte "SBC ", $02, $05, $00, $E9 
    .byte "NOP ", $01, $00, $00, $EA 
    .byte "XXXX", $01, $FF, $00, $EB
    .byte "CPX ", $03, $01, $00, $EC 
    .byte "SBC ", $03, $01, $00, $ED 
    .byte "INC ", $03, $01, $00, $EE 
    .byte "BBS6", $03, $0F, $00, $EF 
    .byte "BEQ ", $02, $09, $00, $F0 
    .byte "SBC ", $02, $07, $00, $F1 
    .byte "SBC ", $02, $0D, $00, $F2 
    .byte "XXXX", $01, $FF, $00, $F3
    .byte "XXXX", $01, $FF, $00, $F4
    .byte "SBC ", $02, $0B, $00, $F5 
    .byte "INC ", $02, $0B, $00, $F6 
    .byte "SMB7", $02, $0A, $00, $F7 
    .byte "SED ", $01, $00, $00, $F8 
    .byte "SBC ", $03, $03, $00, $F9 
    .byte "PLX ", $01, $00, $00, $FA 
    .byte "XXXX", $01, $FF, $00, $FB
    .byte "XXXX", $01, $FF, $00, $FC
    .byte "SBC ", $03, $02, $00, $FD 
    .byte "INC ", $03, $02, $00, $FE 
    .byte "BBS7", $03, $0F, $00, $FF 