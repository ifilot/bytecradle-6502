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

    0400: LDA #01       A9 01
    0402: LDX #01       A2 01
    0404: LDY #00       A0 00
    0406: PHX           DA
    0407: JSR FFEE      20 FF EE
    040A: JSR FFE8      20 FF E8
    040D: PLX           FA
    040E: STX 20        86 20
    0410: CLC           18
    0411: PHA           48
    0412: ADC 20        65 20
    0414: PLX           FA
    0415: INY           C8
    0416: CPY #0A       C0 0A
    0418: BNE EC        D0 EC
    041A: RTS           60

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