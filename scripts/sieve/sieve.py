# -*- coding: utf-8 -*-

import numpy as np
import sympy as sp

SIZE = 1024*16
vals = np.ones(SIZE//2, dtype=np.uint8) * 0xFF
primeslist = [2]

def main():
    for i in range(0, (SIZE-3)//2):
        print(i)
        if vals[i] == 0xFF:
            p = 2 * i + 3
    
            primeslist.append(p)
            
            if p < (np.sqrt(SIZE)+1):
                s = p
                while s < SIZE:
                    if s % 2 != 0 and vals[(s-3) // 2] == 0xFF:
                        vals[(s-3) // 2] = 0     # mark as non-prime
                    s += p
    
    # check that the list is correct
    assert([i for i in sp.primerange(SIZE)] == primeslist)
    
    # print the list
    print(primeslist)
    
    # print number of primes
    print(len(primeslist))
    
if __name__ == '__main__':
    main()