Memory map
----------

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

.. list-table::
   :header-rows: 1
   :widths: auto

   * - Address Range
     - Description
   * - :code:`$7F00`
     - ROM bank register
   * - :code:`$7F01`
     - RAM bank register
   * - :code:`$7F04`
     - ACIA1 DATA register
   * - :code:`$7F05`
     - ACIA1 STATUS register
   * - :code:`$7F06`
     - ACIA1 COMMAND register
   * - :code:`$7F07`
     - ACIA1 CONTROL register
   * - :code:`$7F08`
     - ACIA2 DATA register
   * - :code:`$7F09`
     - ACIA2 STATUS register
   * - :code:`$7F0A`
     - ACIA2 COMMAND register
   * - :code:`$7F0B`
     - ACIA2 CONTROL register
   * - :code:`$7F0C`
     - GPU DATA register
   * - :code:`$7F0D`
     - GPU REC register
   * - :code:`$7F0E`
     - GPU STATUS register
   * - :code:`$7F0F`
     - GPU BIT register
   * - :code:`$7F20`
     - SDCARD SERIAL register
   * - :code:`$7F21`
     - SDCARD CLKSTART register
   * - :code:`$7F22`
     - SDCARD DESELECT register
   * - :code:`$7F23`
     - SDCARD SELECT register