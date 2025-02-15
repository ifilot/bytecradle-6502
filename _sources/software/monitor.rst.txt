Monitor
=======

Inline-assembler
################

Sample programs
---------------

Hello World
-----------

Open the inline-assembler using :code:`A0400` and insert the following
assembly instructions.

.. code:: ca65
    
    0400: LDA #04       A9 04
    0402: LDX #10       A2 10
    0404: JSR FFF7      20 FF F7
    0407: RTS           60

Next, insert the ascii characters for the string :code:`Hello World!` by
first typing :code:`W0410` and entering the following values

.. code::

    0410: 48 65 6C 6C 6F 20 57 6F 72 6C 64 21 00

To run the small program, type :code:`G0400`.

The expected output is

.. code::

    @:G0400
    Hello World!

Fibonacci series
----------------

Open the inline-assembler using :code:`A0400` and insert the following
assembly instructions.

.. code:: ca65

    0400: LDA #01                  A9 01
    0402: LDX #01                  A2 01
    0404: LDY #00                  A0 00
    0406: PHX                      DA
    0407: PHY                      5A
    0408: JSR FFEE                 20 FF EE
    040B: JSR FFE8                 20 FF E8
    040E: PLY                      7A
    040F: PLX                      FA
    0410: STX 20                   86 20
    0412: CLC                      18
    0413: PHA                      48
    0414: ADC 20                   65 20
    0416: PLX                      FA
    0417: INY                      C8
    0418: CPY #0C                  C0 0C
    041A: BNE EA                   D0 EA
    041C: RTS                      60

To run the program, type :code:`G0400` which yields the following output

.. code::

    @:G0400
    1
    2
    3
    5
    8
    13
    21
    34
    55
    89
