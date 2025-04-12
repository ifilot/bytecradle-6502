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
    
    0400: LDA #10       A9 10
    0402: LDX #04       A2 04
    0404: JSR FFE8      20 E8 FF
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
    0408: JSR FFF4                 20 F4 FF
    040B: JSR FFEE                 20 EE FF
    040E: PLY                      7A
    040F: PLX                      FA
    0410: STX 30                   86 30
    0412: CLC                      18
    0413: PHA                      48
    0414: ADC 30                   65 30
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
