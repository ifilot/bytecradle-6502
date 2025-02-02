;
; Set of mnemonics used for the inline assembler, the optcodes
; are ordered in decreasing order of prevalence in typical 6502
; code.
;

.segment "DATA"

mnemonics:
    .byte "LDA "
    .word data_lda
    .byte "STA "
    .word data_sta
    .byte "LDX "
    .word data_ldx
    .byte "LDY "
    .word data_ldy
    .byte "STX "
    .word data_stx
    .byte "STY "
    .word data_sty
    .byte "ADC "
    .word data_adc
    .byte "SBC "
    .word data_sbc
    .byte "CMP "
    .word data_cmp
    .byte "CPX "
    .word data_cpx
    .byte "CPY "
    .word data_cpy
    .byte "AND "
    .word data_and
    .byte "ORA "
    .word data_ora
    .byte "EOR "
    .word data_eor
    .byte "ASL "
    .word data_asl
    .byte "LSR "
    .word data_lsr
    .byte "ROL "
    .word data_rol
    .byte "ROR "
    .word data_ror
    .byte "INC "
    .word data_inc
    .byte "INX "
    .word data_inx
    .byte "INY "
    .word data_iny
    .byte "DEC "
    .word data_dec
    .byte "DEX "
    .word data_dex
    .byte "DEY "
    .word data_dey
    .byte "JMP "
    .word data_jmp
    .byte "JSR "
    .word data_jsr
    .byte "RTS "
    .word data_rts
    .byte "BCC "
    .word data_bcc
    .byte "BCS "
    .word data_bcs
    .byte "BEQ "
    .word data_beq
    .byte "BNE "
    .word data_bne
    .byte "BMI "
    .word data_bmi
    .byte "BPL "
    .word data_bpl
    .byte "BVC "
    .word data_bvc
    .byte "BVS "
    .word data_bvs
    .byte "CLC "
    .word data_clc
    .byte "CLD "
    .word data_cld
    .byte "CLI "
    .word data_cli
    .byte "CLV "
    .word data_clv
    .byte "SEC "
    .word data_sec
    .byte "SED "
    .word data_sed
    .byte "SEI "
    .word data_sei
    .byte "PHA "
    .word data_pha
    .byte "PHP "
    .word data_php
    .byte "PLA "
    .word data_pla
    .byte "PLP "
    .word data_plp
    .byte "BRK "
    .word data_brk
    .byte "RTI "
    .word data_rti
    .byte "NOP "
    .word data_nop
    .byte "BIT "
    .word data_bit
    .byte "TSX "
    .word data_tsx
    .byte "TXS "
    .word data_txs
    .byte "TAX "
    .word data_tax
    .byte "TAY "
    .word data_tay
    .byte "TXA "
    .word data_txa
    .byte "TYA "
    .word data_tya
    .byte "TSB "
    .word data_tsb
    .byte "RMB0"
    .word data_rmb0
    .byte "BBR0"
    .word data_bbr0
    .byte "TRB "
    .word data_trb
    .byte "RMB1"
    .word data_rmb1
    .byte "BBR1"
    .word data_bbr1
    .byte "RMB2"
    .word data_rmb2
    .byte "BBR2"
    .word data_bbr2
    .byte "RMB3"
    .word data_rmb3
    .byte "BBR3"
    .word data_bbr3
    .byte "RMB4"
    .word data_rmb4
    .byte "BBR4"
    .word data_bbr4
    .byte "RMB5"
    .word data_rmb5
    .byte "PHY "
    .word data_phy
    .byte "BBR5"
    .word data_bbr5
    .byte "STZ "
    .word data_stz
    .byte "RMB6"
    .word data_rmb6
    .byte "BBR6"
    .word data_bbr6
    .byte "RMB7"
    .word data_rmb7
    .byte "PLY "
    .word data_ply
    .byte "BBR7"
    .word data_bbr7
    .byte "BRA "
    .word data_bra
    .byte "SMB0"
    .word data_smb0
    .byte "BBS0"
    .word data_bbs0
    .byte "SMB1"
    .word data_smb1
    .byte "BBS1"
    .word data_bbs1
    .byte "SMB2"
    .word data_smb2
    .byte "BBS2"
    .word data_bbs2
    .byte "SMB3"
    .word data_smb3
    .byte "BBS3"
    .word data_bbs3
    .byte "SMB4"
    .word data_smb4
    .byte "WAI "
    .word data_wai
    .byte "BBS4"
    .word data_bbs4
    .byte "SMB5"
    .word data_smb5
    .byte "PHX "
    .word data_phx
    .byte "STP "
    .word data_stp
    .byte "BBS5"
    .word data_bbs5
    .byte "SMB6"
    .word data_smb6
    .byte "BBS6"
    .word data_bbs6
    .byte "SMB7"
    .word data_smb7
    .byte "PLX "
    .word data_plx
    .byte "BBS7"
    .word data_bbs7

;
; For a given mnemonics, provide the optcodes for the different types of
; addressing modes (listed below) as pairs. Each list of pairs is terminated
; by $FF.
;
; Addressing modes
; ----------------
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
;
data_adc:
    .byte $06,$61,$0A,$65,$05,$69,$01,$6D,$07,$71,$0D,$72,$0B,$75,$03,$79,$02,$7D,$FF
data_and:
    .byte $06,$21,$0A,$25,$05,$29,$01,$2D,$07,$31,$0D,$32,$0B,$35,$03,$39,$02,$3D,$FF
data_asl:
    .byte $0A,$06,$04,$0A,$01,$0E,$0B,$16,$02,$1E,$FF
data_bbr0:
    .byte $0F,$0F,$FF
data_bbr1:
    .byte $0F,$1F,$FF
data_bbr2:
    .byte $0F,$2F,$FF
data_bbr3:
    .byte $0F,$3F,$FF
data_bbr4:
    .byte $0F,$4F,$FF
data_bbr5:
    .byte $0F,$5F,$FF
data_bbr6:
    .byte $0F,$6F,$FF
data_bbr7:
    .byte $0F,$7F,$FF
data_bbs0:
    .byte $0F,$8F,$FF
data_bbs1:
    .byte $0F,$9F,$FF
data_bbs2:
    .byte $0F,$AF,$FF
data_bbs3:
    .byte $0F,$BF,$FF
data_bbs4:
    .byte $0F,$CF,$FF
data_bbs5:
    .byte $0F,$DF,$FF
data_bbs6:
    .byte $0F,$EF,$FF
data_bbs7:
    .byte $0F,$FF,$FF
data_bcc:
    .byte $09,$90,$FF
data_bcs:
    .byte $09,$B0,$FF
data_beq:
    .byte $09,$F0,$FF
data_bit:
    .byte $0A,$24,$01,$2C,$0B,$34,$02,$3C,$05,$89,$FF
data_bmi:
    .byte $09,$30,$FF
data_bne:
    .byte $09,$D0,$FF
data_bpl:
    .byte $09,$10,$FF
data_bra:
    .byte $09,$80,$FF
data_brk:
    .byte $00,$00,$FF
data_bvc:
    .byte $09,$50,$FF
data_bvs:
    .byte $09,$70,$FF
data_clc:
    .byte $00,$18,$FF
data_cld:
    .byte $00,$D8,$FF
data_cli:
    .byte $00,$58,$FF
data_clv:
    .byte $00,$B8,$FF
data_cmp:
    .byte $06,$C1,$0A,$C5,$05,$C9,$01,$CD,$07,$D1,$0D,$D2,$0B,$D5,$03,$D9,$02,$DD,$FF
data_cpx:
    .byte $05,$E0,$0A,$E4,$01,$EC,$FF
data_cpy:
    .byte $05,$C0,$0A,$C4,$01,$CC,$FF
data_dec:
    .byte $04,$3A,$0A,$C6,$01,$CE,$0B,$D6,$02,$DE,$FF
data_dex:
    .byte $00,$CA,$FF
data_dey:
    .byte $00,$88,$FF
data_eor:
    .byte $06,$41,$0A,$45,$05,$49,$01,$4D,$07,$51,$0D,$52,$0B,$55,$03,$59,$02,$5D,$FF
data_inc:
    .byte $04,$1A,$0A,$E6,$01,$EE,$0B,$F6,$02,$FE,$FF
data_inx:
    .byte $00,$E8,$FF
data_iny:
    .byte $00,$C8,$FF
data_jmp:
    .byte $01,$4C,$08,$6C,$0E,$7C,$FF
data_jsr:
    .byte $01,$20,$FF
data_lda:
    .byte $06,$A1,$0A,$A5,$05,$A9,$01,$AD,$07,$B1,$0D,$B2,$0B,$B5,$03,$B9,$02,$BD,$FF
data_ldx:
    .byte $05,$A2,$0A,$A6,$01,$AE,$0C,$B6,$03,$BE,$FF
data_ldy:
    .byte $05,$A0,$0A,$A4,$01,$AC,$0B,$B4,$02,$BC,$FF
data_lsr:
    .byte $0A,$46,$04,$4A,$01,$4E,$0B,$56,$02,$5E,$FF
data_nop:
    .byte $00,$EA,$FF
data_ora:
    .byte $06,$01,$0A,$05,$05,$09,$01,$0D,$07,$11,$0D,$12,$0B,$15,$03,$19,$02,$1D,$FF
data_pha:
    .byte $00,$48,$FF
data_php:
    .byte $00,$08,$FF
data_phx:
    .byte $00,$DA,$FF
data_phy:
    .byte $00,$5A,$FF
data_pla:
    .byte $00,$68,$FF
data_plp:
    .byte $00,$28,$FF
data_plx:
    .byte $00,$FA,$FF
data_ply:
    .byte $00,$7A,$FF
data_rmb0:
    .byte $0A,$07,$FF
data_rmb1:
    .byte $0A,$17,$FF
data_rmb2:
    .byte $0A,$27,$FF
data_rmb3:
    .byte $0A,$37,$FF
data_rmb4:
    .byte $0A,$47,$FF
data_rmb5:
    .byte $0A,$57,$FF
data_rmb6:
    .byte $0A,$67,$FF
data_rmb7:
    .byte $0A,$77,$FF
data_rol:
    .byte $0A,$26,$04,$2A,$01,$2E,$0B,$36,$02,$3E,$FF
data_ror:
    .byte $0A,$66,$04,$6A,$01,$6E,$0B,$76,$02,$7E,$FF
data_rti:
    .byte $00,$40,$FF
data_rts:
    .byte $00,$60,$FF
data_sbc:
    .byte $06,$E1,$0A,$E5,$05,$E9,$01,$ED,$07,$F1,$0D,$F2,$0B,$F5,$03,$F9,$02,$FD,$FF
data_sec:
    .byte $00,$38,$FF
data_sed:
    .byte $00,$F8,$FF
data_sei:
    .byte $00,$78,$FF
data_smb0:
    .byte $0A,$87,$FF
data_smb1:
    .byte $0A,$97,$FF
data_smb2:
    .byte $0A,$A7,$FF
data_smb3:
    .byte $0A,$B7,$FF
data_smb4:
    .byte $0A,$C7,$FF
data_smb5:
    .byte $0A,$D7,$FF
data_smb6:
    .byte $0A,$E7,$FF
data_smb7:
    .byte $0A,$F7,$FF
data_sta:
    .byte $06,$81,$0A,$85,$01,$8D,$07,$91,$0D,$92,$0B,$95,$03,$99,$02,$9D,$FF
data_stp:
    .byte $00,$DB,$FF
data_stx:
    .byte $0A,$86,$01,$8E,$0C,$96,$FF
data_sty:
    .byte $0A,$84,$01,$8C,$0B,$94,$FF
data_stz:
    .byte $0A,$64,$0B,$74,$01,$9C,$02,$9E,$FF
data_tax:
    .byte $00,$AA,$FF
data_tay:
    .byte $00,$A8,$FF
data_trb:
    .byte $0A,$14,$01,$1C,$FF
data_tsb:
    .byte $0A,$04,$01,$0C,$FF
data_tsx:
    .byte $00,$BA,$FF
data_txa:
    .byte $00,$8A,$FF
data_txs:
    .byte $00,$9A,$FF
data_tya:
    .byte $00,$98,$FF
data_wai:
    .byte $00,$CB,$FF