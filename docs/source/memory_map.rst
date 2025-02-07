Memory map
==========

The following table describes the memory layout of the ByteCradle 6502 SBC:

.. list-table::
   :header-rows: 1
   :widths: auto

   * - Address Range
     - Description
   * - :code:`$0000-$00FF`
     - Zero Page
   * - :code:`$0100-$01FF`
     - Stack
   * - :code:`$0200-$02FF`
     - Keyboard Buffer
   * - :code:`$0300-$03FF`
     - System Variables
   * - :code:`$0400-$7EFF`
     - Free User Space
   * - :code:`$7F00-$7FFF`
     - I/O Space
   * - :code:`$8000-$BFFF`
     - Bankable Memory (32 x 16 KiB)
   * - :code:`$C000-$FFFF`
     - Bankable System ROM (32 x 16 KiB)

Zero Page
---------

The first 32 bytes of the zero page are reserved for system variables. The user
is free to use the zero page at `$20-$FF`.

I/O space
---------

