# Required Tools

The tools you'll need depend on whether you're assembling the board yourself or
working with a pre-assembled unit.

## For Manual Assembly

If you're starting from a bare PCB and sourcing your own components, ensure you
have the following tools and equipment:

- **Soldering iron** — Preferably temperature-controlled for best results.
- **Solder** — Leaded solder is typically easier to work with, but choose
  according to your preference or safety requirements.
- **ROM flasher** — A reliable, advanced commercial flasher such as the **XGecu
  PRO**, which supports programming **Atmel SST39SF0X0** series chips.

### Board-Specific Requirements

- **For :material-chip: TINY boards**: A flasher that supports programming **ATF22V10** chips.
- **For :material-chip: MINI boards**: A flasher compatible with **ATF1502AS** chips.

## For Pre-Assembled Boards

If you're using a board that has already been assembled, your tool requirements
are simpler:

- A **SST39SF0X0-compatible flasher** — Many affordable and widely available
  flashers support this chip family.

!!! tip 
    While high-end flashers like the XGecu PRO are recommended for
    reliability, budget-friendly options may suffice for casual use, especially
    with pre-assembled boards. A budget-friendly option is the
    [PICO-SST39SF0x0-programmer](https://github.com/ifilot/pico-sst39sf0x0-programmer).

[:material-arrow-right: Next: Proceed to assembling the board](assembling-the-board.md)