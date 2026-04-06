# SRC folder

This folder contains three types of software which are categorized by their
roles, which are organized as follows in order of increasing complexity:

* **Firmware**: Bare-bones environment. Puts the system in an infinite loop,
  typically in an echoing state where all input received over the serial port is
  simply echoed back to the user. 
* **Environments**: Offers a user-friendly menu and allows the user to select a
  program / application from a list of options. Among these, there is a monitor
  program.
* **Operating System (OS)**: The most rich experience, offering an interface to
  a storage device via drivers and the option for the user to navigate the
  storage device and load in and execute programs.