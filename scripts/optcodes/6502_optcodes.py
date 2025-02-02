from data import addressModeTable, opcodeTable

def main():
    
    optcodes = []
    mnemonics = {}
    for i in range(0,256):
        if i in opcodeTable.keys():
            v = opcodeTable[i]
            mode = [k for k in addressModeTable.keys()].index(v[2])
            
            optcodes.append('.byte "%s", $%02X, $%02X, $00, $%02X ' % (v[1].ljust(4, " ").upper(), v[0], mode, i))
            
            if v[1].upper() not in mnemonics.keys():
                mnemonics[v[1].upper()] = []
            mnemonics[v[1].upper()].append((mode, i))
                
        else:
            optcodes.append('.byte "????", $01, $FF, $00, $%02X' % i)

    mnemonics = dict(sorted(mnemonics.items()))
    lines = []
    for k,v in mnemonics.items():
        lines.append('data_%s:' % k.lower())
        data = ''
        for mode in v:
            data += '$%02X,' % mode[0]
            data += '$%02X,' % mode[1]
        data += '$%02X' % 0xFF # terminating char
        lines.append('    .byte %s' % data)
    
    for line in lines:
        print(line)

if __name__ == '__main__':
    main()