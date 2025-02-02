;
; Set of mnemonics used for the inline assembler, the optcodes
; are ordered in decreasing order of prevalence in typical 6502
; code.
;

.segment "DATA"

mnemonics:
    .byte "LDA "
    .word parse_lda
    .byte "STA "
    .word parse_sta
    .byte "LDX "
    .word parse_ldx
    .byte "LDY "
    .word parse_ldy
    .byte "STX "
    .word parse_stx
    .byte "STY "
    .word parse_sty
    .byte "ADC "
    .word parse_adc
    .byte "SBC "
    .word parse_sbc
    .byte "CMP "
    .word parse_cmp
    .byte "CPX "
    .word parse_cpx
    .byte "CPY "
    .word parse_cpy
    .byte "AND "
    .word parse_and
    .byte "ORA "
    .word parse_ora
    .byte "EOR "
    .word parse_eor
    .byte "ASL "
    .word parse_asl
    .byte "LSR "
    .word parse_lsr
    .byte "ROL "
    .word parse_rol
    .byte "ROR "
    .word parse_ror
    .byte "INC "
    .word parse_inc
    .byte "INX "
    .word parse_inx
    .byte "INY "
    .word parse_iny
    .byte "DEC "
    .word parse_dec
    .byte "DEX "
    .word parse_dex
    .byte "DEY "
    .word parse_dey
    .byte "JMP "
    .word parse_jmp
    .byte "JSR "
    .word parse_jsr
    .byte "RTS "
    .word parse_rts
    .byte "BCC "
    .word parse_bcc
    .byte "BCS "
    .word parse_bcs
    .byte "BEQ "
    .word parse_beq
    .byte "BNE "
    .word parse_bne
    .byte "BMI "
    .word parse_bmi
    .byte "BPL "
    .word parse_bpl
    .byte "BVC "
    .word parse_bvc
    .byte "BVS "
    .word parse_bvs
    .byte "CLC "
    .word parse_clc
    .byte "CLD "
    .word parse_cld
    .byte "CLI "
    .word parse_cli
    .byte "CLV "
    .word parse_clv
    .byte "SEC "
    .word parse_sec
    .byte "SED "
    .word parse_sed
    .byte "SEI "
    .word parse_sei
    .byte "PHA "
    .word parse_pha
    .byte "PHP "
    .word parse_php
    .byte "PLA "
    .word parse_pla
    .byte "PLP "
    .word parse_plp
    .byte "BRK "
    .word parse_brk
    .byte "RTI "
    .word parse_rti
    .byte "NOP "
    .word parse_nop
    .byte "BIT "
    .word parse_bit
    .byte "TSX "
    .word parse_tsx
    .byte "TXS "
    .word parse_txs
    .byte "TAX "
    .word parse_tax
    .byte "TAY "
    .word parse_tay
    .byte "TXA "
    .word parse_txa
    .byte "TYA "
    .word parse_tya
    .byte "TSB "
    .word parse_tsb
    .byte "RMB0"
    .word parse_rmb0
    .byte "BBR0"
    .word parse_bbr0
    .byte "TRB "
    .word parse_trb
    .byte "RMB1"
    .word parse_rmb1
    .byte "BBR1"
    .word parse_bbr1
    .byte "RMB2"
    .word parse_rmb2
    .byte "BBR2"
    .word parse_bbr2
    .byte "RMB3"
    .word parse_rmb3
    .byte "BBR3"
    .word parse_bbr3
    .byte "RMB4"
    .word parse_rmb4
    .byte "BBR4"
    .word parse_bbr4
    .byte "RMB5"
    .word parse_rmb5
    .byte "PHY "
    .word parse_phy
    .byte "BBR5"
    .word parse_bbr5
    .byte "STZ "
    .word parse_stz
    .byte "RMB6"
    .word parse_rmb6
    .byte "BBR6"
    .word parse_bbr6
    .byte "RMB7"
    .word parse_rmb7
    .byte "PLY "
    .word parse_ply
    .byte "BBR7"
    .word parse_bbr7
    .byte "BRA "
    .word parse_bra
    .byte "SMB0"
    .word parse_smb0
    .byte "BBS0"
    .word parse_bbs0
    .byte "SMB1"
    .word parse_smb1
    .byte "BBS1"
    .word parse_bbs1
    .byte "SMB2"
    .word parse_smb2
    .byte "BBS2"
    .word parse_bbs2
    .byte "SMB3"
    .word parse_smb3
    .byte "BBS3"
    .word parse_bbs3
    .byte "SMB4"
    .word parse_smb4
    .byte "WAI "
    .word parse_wai
    .byte "BBS4"
    .word parse_bbs4
    .byte "SMB5"
    .word parse_smb5
    .byte "PHX "
    .word parse_phx
    .byte "STP "
    .word parse_stp
    .byte "BBS5"
    .word parse_bbs5
    .byte "SMB6"
    .word parse_smb6
    .byte "BBS6"
    .word parse_bbs6
    .byte "SMB7"
    .word parse_smb7
    .byte "PLX "
    .word parse_plx
    .byte "BBS7"
    .word parse_bbs7

.segment "CODE"

parse_lda:
    rts

parse_sta:
    rts

parse_ldx:
    rts

parse_ldy:
    rts

parse_stx:
    rts

parse_sty:
    rts

parse_adc:
    rts

parse_sbc:
    rts

parse_cmp:
    rts

parse_cpx:
    rts

parse_cpy:
    rts

parse_and:
    rts

parse_ora:
    rts

parse_eor:
    rts

parse_asl:
    rts

parse_lsr:
    rts

parse_rol:
    rts

parse_ror:
    rts

parse_inc:
    rts

parse_inx:
    rts

parse_iny:
    rts

parse_dec:
    rts

parse_dex:
    rts

parse_dey:
    rts

parse_jmp:
    rts

parse_jsr:
    rts

parse_rts:
    rts

parse_bcc:
    rts

parse_bcs:
    rts

parse_beq:
    rts

parse_bne:
    rts

parse_bmi:
    rts

parse_bpl:
    rts

parse_bvc:
    rts

parse_bvs:
    rts

parse_clc:
    rts

parse_cld:
    rts

parse_cli:
    rts

parse_clv:
    rts

parse_sec:
    rts

parse_sed:
    rts

parse_sei:
    rts

parse_pha:
    rts

parse_php:
    rts

parse_pla:
    rts

parse_plp:
    rts

parse_brk:
    rts

parse_rti:
    rts

parse_nop:
    rts

parse_bit:
    rts

parse_tsx:
    rts

parse_txs:
    rts

parse_tax:
    rts

parse_tay:
    rts

parse_txa:
    rts

parse_tya:
    rts

parse_tsb:
    rts

parse_rmb0:
    rts

parse_bbr0:
    rts

parse_trb:
    rts

parse_rmb1:
    rts

parse_bbr1:
    rts

parse_rmb2:
    rts

parse_bbr2:
    rts

parse_rmb3:
    rts

parse_bbr3:
    rts

parse_rmb4:
    rts

parse_bbr4:
    rts

parse_rmb5:
    rts

parse_phy:
    rts

parse_bbr5:
    rts

parse_stz:
    rts

parse_rmb6:
    rts

parse_bbr6:
    rts

parse_rmb7:
    rts

parse_ply:
    rts

parse_bbr7:
    rts

parse_bra:
    rts

parse_smb0:
    rts

parse_bbs0:
    rts

parse_smb1:
    rts

parse_bbs1:
    rts

parse_smb2:
    rts

parse_bbs2:
    rts

parse_smb3:
    rts

parse_bbs3:
    rts

parse_smb4:
    rts

parse_wai:
    rts

parse_bbs4:
    rts

parse_smb5:
    rts

parse_phx:
    rts

parse_stp:
    rts

parse_bbs5:
    rts

parse_smb6:
    rts

parse_bbs6:
    rts

parse_smb7:
    rts

parse_plx:
    rts

parse_bbs7:
    rts