.import parse_mnemonic

mnemonics:
    .byte "LDA ", .word parse_mnemonic
    .byte "STA ", .word parse_mnemonic
    .byte "LDX ", .word parse_mnemonic
    .byte "LDY ", .word parse_mnemonic
    .byte "STX ", .word parse_mnemonic
    .byte "STY ", .word parse_mnemonic
    .byte "ADC ", .word parse_mnemonic
    .byte "SBC ", .word parse_mnemonic
    .byte "CMP ", .word parse_mnemonic
    .byte "CPX ", .word parse_mnemonic
    .byte "CPY ", .word parse_mnemonic
    .byte "AND ", .word parse_mnemonic
    .byte "ORA ", .word parse_mnemonic
    .byte "EOR ", .word parse_mnemonic
    .byte "ASL ", .word parse_mnemonic
    .byte "LSR ", .word parse_mnemonic
    .byte "ROL ", .word parse_mnemonic
    .byte "ROR ", .word parse_mnemonic
    .byte "INC ", .word parse_mnemonic
    .byte "INX ", .word parse_mnemonic
    .byte "INY ", .word parse_mnemonic
    .byte "DEC ", .word parse_mnemonic
    .byte "DEX ", .word parse_mnemonic
    .byte "DEY ", .word parse_mnemonic
    .byte "JMP ", .word parse_mnemonic
    .byte "JSR ", .word parse_mnemonic
    .byte "RTS ", .word parse_mnemonic
    .byte "BCC ", .word parse_mnemonic
    .byte "BCS ", .word parse_mnemonic
    .byte "BEQ ", .word parse_mnemonic
    .byte "BNE ", .word parse_mnemonic
    .byte "BMI ", .word parse_mnemonic
    .byte "BPL ", .word parse_mnemonic
    .byte "BVC ", .word parse_mnemonic
    .byte "BVS ", .word parse_mnemonic
    .byte "CLC ", .word parse_mnemonic
    .byte "CLD ", .word parse_mnemonic
    .byte "CLI ", .word parse_mnemonic
    .byte "CLV ", .word parse_mnemonic
    .byte "SEC ", .word parse_mnemonic
    .byte "SED ", .word parse_mnemonic
    .byte "SEI ", .word parse_mnemonic
    .byte "PHA ", .word parse_mnemonic
    .byte "PHP ", .word parse_mnemonic
    .byte "PLA ", .word parse_mnemonic
    .byte "PLP ", .word parse_mnemonic
    .byte "BRK ", .word parse_mnemonic
    .byte "RTI ", .word parse_mnemonic
    .byte "NOP ", .word parse_mnemonic
    .byte "BIT ", .word parse_mnemonic
    .byte "TSX ", .word parse_mnemonic
    .byte "TXS ", .word parse_mnemonic
    .byte "TAX ", .word parse_mnemonic
    .byte "TAY ", .word parse_mnemonic
    .byte "TXA ", .word parse_mnemonic
    .byte "TYA ", .word parse_mnemonic
    .byte "TSB ", .word parse_mnemonic
    .byte "RMB0", .word parse_mnemonic
    .byte "BBR0", .word parse_mnemonic
    .byte "TRB ", .word parse_mnemonic
    .byte "RMB1", .word parse_mnemonic
    .byte "BBR1", .word parse_mnemonic
    .byte "RMB2", .word parse_mnemonic
    .byte "BBR2", .word parse_mnemonic
    .byte "RMB3", .word parse_mnemonic
    .byte "BBR3", .word parse_mnemonic
    .byte "RMB4", .word parse_mnemonic
    .byte "BBR4", .word parse_mnemonic
    .byte "RMB5", .word parse_mnemonic
    .byte "PHY ", .word parse_mnemonic
    .byte "BBR5", .word parse_mnemonic
    .byte "STZ ", .word parse_mnemonic
    .byte "RMB6", .word parse_mnemonic
    .byte "BBR6", .word parse_mnemonic
    .byte "RMB7", .word parse_mnemonic
    .byte "PLY ", .word parse_mnemonic
    .byte "BBR7", .word parse_mnemonic
    .byte "BRA ", .word parse_mnemonic
    .byte "SMB0", .word parse_mnemonic
    .byte "BBS0", .word parse_mnemonic
    .byte "SMB1", .word parse_mnemonic
    .byte "BBS1", .word parse_mnemonic
    .byte "SMB2", .word parse_mnemonic
    .byte "BBS2", .word parse_mnemonic
    .byte "SMB3", .word parse_mnemonic
    .byte "BBS3", .word parse_mnemonic
    .byte "SMB4", .word parse_mnemonic
    .byte "WAI ", .word parse_mnemonic
    .byte "BBS4", .word parse_mnemonic
    .byte "SMB5", .word parse_mnemonic
    .byte "PHX ", .word parse_mnemonic
    .byte "STP ", .word parse_mnemonic
    .byte "BBS5", .word parse_mnemonic
    .byte "SMB6", .word parse_mnemonic
    .byte "BBS6", .word parse_mnemonic
    .byte "SMB7", .word parse_mnemonic
    .byte "PLX ", .word parse_mnemonic
    .byte "BBS7", .word parse_mnemonic