
.segment "CODE"

.define SIEVESTART $1000
.define SIEVELIMIT 1000

.export sieve

;-------------------------------------------------------------------------------
; Sieve of Eratosthenes function
;-------------------------------------------------------------------------------
sieve:
    rts