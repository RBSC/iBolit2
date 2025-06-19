--------------------------------------------------------------------------------
iBolit2 MSX Diagnostics Cartridge
Copyright (c) 2024-2025 RBSC
Last updated: 19.06.2025
--------------------------------------------------------------------------------

About
-----

iBolit2 is the successor of the simple diagnostics cartridge called iBolit that was released by RBSC in 2022. Compared to
its predecessor, this cartridge offers 4 different diagnostic modes and better LCD-based voltmeters. It is based on Alera
CPLD EPM240T100C4 chip that allows to use different firmwares in the cartridge. In addition, the daughterboard of the
cartridge is now connected to the mainboard with 2 separate connectors and that makes it more stable.

During previous years we've seen numerous messages from MSX users, whose computers suddenly stopped working after being
removed from the storage or after yet another power cycle. Many people complained about black screens or about total power
failure. It's a known fact that RAM and other elements may go bad during storing or at power-on.

Diagnosing those problems usually starts from checking the power rails, clock signals, reset signal's state and activity on
data and address buses. The first diagnostics cartridge was a success, but its indication was too fast to identify single
problematic signals. Moreover, fast changing signals (for example CLK) it was difficult to diagnose as the LED was only
half-lit. So, it was decided to create a better diagnostics cartridge with several different ways to identify potential
faults.

The new cartridge uses the same LED assemblies as the old ones. The board now has 330 Ohm resistors for all MSX slot signals
as well as the built-in overvoltage protection for the 5V power bus, something that iBolit in its original version was
missing. There's also the same MSX edge connector installed on the top of iBolit2 cartridge's board. There one can insert
any third-party cartridge including the one with MSX diagnostics ROM. The daughterboard with voltmeters is detachable as
before.


Programming the CPLD
--------------------

The Altera CPLD chip needs to be programmed after assembling the cartridge. There are POF firmware files in the "Firmware"
folder of the repository. Please use the standard USB Blaster programmer to upload the firmware into the cartridge. The
external 5V power must be connected to the cartridge before programming. See the photo in the "Pics" folder on how to
connect the power and the USB Blaster to the iBolit2 board. The Quartus programming software could be found here:

 http://download.altera.com/akdlm/software/acdsinst/15.0/145/ib_installers/QuartusSetupWeb-15.0.0.145-windows.exe
 http://download.altera.com/akdlm/software/acdsinst/15.0/145/ib_installers/QuartusSetupWeb-15.0.0.145-linux.run

First connect the power (5V) and USB Blaster to the mainboard, then start the Quartus software, select JTAG mode and do the
auto-detection of the chip. In case the chip is not detected, please check your board and connections. Normally, the Altera
chip will be auto-detected on the properly assembled board. Now select the POF file from the "Firmware" folder and flash
it into the Altera chip. Finally disconnect the power and USB Blaster.

It's not recommended to program the Altera chip when the board is inserted into MSX computer - it's better to do it with
external power (for example from a USB3 port of the same computer where the USB Blaster is connected to).

PLEASE NOTE that there's also a firmware version with the inverted logic. It's located in the "Inverse" subfolder of the
"Firmware" folder in the repository. If you are unhappy with the default diagnostics modes, please try the firmware with
an inverse logic, maybe it fits you better.


Usage instructions
------------------

The iBolit2 cartridge offers 4 different diagnostics modes. There is a fast blinking mode, slow blinking mode, signal
low-state mode and signal high-state mode. In addition 3 voltmeters allow to monitor voltages on 3 MSX power buses (+5V,
+12V and -12V).

When switching the computer with iBolit2 in any slot on it's important to check all voltages first. If there's a significant
overvoltage or a missing voltage, it's recommended to switch the computer off immediately and to check the power supply.
Diagnosing the computer with incorrect voltages is not recommended as this may cause more damage.

On power-on, iBolit2 starts in the fast blinking mode. Each LED (except for the signle one under the CLK signal) should be
either lit or blinking. By design a LED is lit when its signal is low (TTL logic). And if a signal is high (TTL logic), a
LED is not lit. Some signals, for example RESET and some others do not fluctuate when a computer stays on. On the contrary -
the clock, data and address bus signals always fluctuate on a properly working computer. Some signals change their state
only diring a reset sequence, for example CS1, CS2 and some other slot signals. The RESET signal only changes its state when
the reset button is depressed. So, it's important to know which signals are expected to change their state and which stay
on/off during diagnostics.

Mode switching is done by the single pushbutton on the right side of the cartridge. It's recommended to hold the iBolit2's
board with the left hand when pressing the mode switching button with the right hand to make sure that the board is not
moved within the slot. The button has actually 2 functions - a short pressing resets the current mode, the long pressing
(over 1 second) switches to the next mode.

The second, slow blinking mode allows to better see "frozen" signals on the address and data buses. The third mode allows
to see all signals that are always low (TTL logic) or change their state to low (TTL logic). All LEDs are first switched
off and then each signal is checked in a cycle. If a signal is low (TTL logic), its LED is lit and then stays on.

The forth mode is the opposite to mode 3. In this mode all LEDs are first lit and then each signal is checked. If a signal
is high (TTL logic), its LED is switched off and then stays off. After pressing the mode changing button in mode 4, mode 1
is enabled again (this is a cycle: 1-2-3-4-1-2 and so on).

As you can see, this cartridge doesn't offer advanced diagnostics with error codes and such, but it still allows to see
anomalies on the power and data/address buses of MSX computer. It's recommended to first try the iBolit2 on a working
computer and to observe how it behaves there. There are certain patterns on how LEDs are lit/blinking on a properly working
computer. A deviation from this pattern could indicate a problem. It's also possible to see bootlops, when patterns are
repeating at defined intervals. This happens when a bad RAM prevents MSX BIOS from starting. It's also possible to see
when the CPU executes garbage - in this case LED blinking has no defined pattern and blinking is somewhat random.

The bottom line - to be able to use this cartridge for MSX computer diagnostics one must learn how good patterns look like
and what signals fluctuate or stay high/low on a properly working computer. Comparing known good patterns and signal states
to the ones on a non-working computer normally gives a good hint on what needs to be diagnosed first.

It's a "learn by experience" device, so one must be patient to gain enough knowledge for successful failure diagnostics.


Where to buy parts
------------------

The parts for assembling the cartridge can be purchased from these sellers on AliExpress:

 - https://www.aliexpress.com/item/1005006246691152.html	(USB voltage tester)
 - https://www.aliexpress.com/item/1005006216595025.html	(1212S DC-DC converter)
 - https://www.aliexpress.com/item/1005006240551154.html	(2x5 angled male pin header)
 - https://www.aliexpress.com/item/1005005315148259.html	(2x5 pin angled female connector)
 - https://www.aliexpress.com/item/1005006695642025.html	(red, yellow and blue LED assembly)
 - https://www.aliexpress.com/item/32799108713.html		(dual-color or just any simple 5mm LED)
 - https://www.aliexpress.com/item/1005001437036125.html	(1kOhm and 330Ohm SMD resistor assembly)
 - https://www.aliexpress.com/item/32948284513.html		(LED for the -12v voltmeter)
 - https://www.aliexpress.com/item/1005006870220937.html	(10uF and 47uF capacitors)
 - https://www.aliexpress.com/item/1005003647067417.html	(50-pin angled slot connector)
 - https://www.aliexpress.com/item/1005002487704059.html	(3.3v voltage regulator)
 - https://www.aliexpress.com/item/32877842771.html		(self-recovery fuse, use 1A or 2A fuses only)
 - https://www.aliexpress.com/item/1005006883303362.html	(zener diode)
 - https://www.aliexpress.com/item/1005006879247149.html	(EPM240T100C4 CPLD, 3.3V)


Assembling notes
----------------

Please read the following notes carefully:


 - It's highly recommended to install ceramic capacitors everywhere on the board. For the DC-DC converters the ceramic 10uF
   capacitors are a must

 - To adapt the voltmeters to work with iBolit2, you need to first carefully open the USB tester's case with a knife and
   remove the board. Then desolder both male and female USB connectors and clean up the mounting holes. The standard 4-pin
   headers won't fit, so you have to use 2-pin headers with slightly shortened plastic base from one side. The distance
   between the pairs of holes is not 2.54mm!

 - The voltmeter with a separate red LED is for -12v indication, it should be installed on the lowest position of the iBolit2
   daughterboard. See the reference photos in the "Pics" folder

 - Please note that LED assemblies may have incorrect key position! So please always test the LED assemblies with a multimeter
   in the diode testing mode to find the correct polarity. The cathode should be on the right, like marked on the mainboard

 - The pins of both DC-DC converters should be carefully bent to the 90 degree angle and the converters have to be installed
   face-down. See the reference photos in the "Pics" folder

 - The Altera CPLD chip needs to be programmed after assembling the cartridge. There are POF firmware files in the "Firmware"
   folder of the repository. See the "Programming CPLD" section for programming instructions

 - Instead of one blue and two red LED assemblies you might want to install one red and two blue LED assemblies. Make your
   own choice. However, it's recommended to install the yellow LED assembly at the rightmost position. If you are installing
   the green LED assembly, you need to select a different value for the resistor assembly, for example 330 Ohm instead of
   1kOhm for red/blue ones

 - The board has overvoltage protection that will kick in if the voltage on the 5V bus is higher that 5.6V. If you see this
   or above voltage value when switching on your MSX computer, disconnect the power immediately and diagnose your power
   supply. Please note that the fuse on the iBolit2 board is self-recovering, so if the board has cut off the 5V power to
   itself because of the overvoltage and no longer works, just let it cool down for a few minutes to restore the fuse

 - The daughterboard with voltmeters is detachable. But when it is detached, no power will be supplied to the upper cartridge
   slot. If you need to use the cartridge slot without the attached daughterboard, you need to put 5 jumpers horizontally on
   5 pairs of pins of the upper daughterboard's connector

 - Do not bridge the SW1+2 solder jumper pad unless your MSX refuses to power on with the inserted iBolit2 cartridge


IMPORTANT!
----------

The RBSC provides all the files and information for free, without any liability (see the disclaimer.txt file). The provided
information, software or hardware must not be used for commercial purposes unless permitted by the RBSC. Producing a small
amount of bare boards for personal projects and selling the rest of the batch is allowed without the permission of RBSC.

When the sources of the tools are used to create alternative projects, please always mention the original source and the
copyright!

The iBolit logo was created by the digital artist named Alu Orlov (alu.orlov.art @ gmail.com) based on existing character
design. She has also created RBSC's main logo, as well as Carnivore2 and 2+ stickers and carton boxes. If you would like
to have a cool logo or any other form of digital art, contact her by e-mail.


Contact information
-------------------

The members of RBSC group Tnt23, Wierzbowsky, Pyhesty, Ptero, GreyWolf, SuperMax, VWarlock, Alspru and DJS3000 can be contacted
via the group's e-mail address:

info@rbsc.su

The group's coordinator could be reached via this e-mail address:

admin@rbsc.su

The group's website can be found here:

https://rbsc.su/
https://rbsc.su/ru

The RBSC's hardware repository can be found here:

https://github.com/rbsc

The RBSC's 3D model repository can be found here:

https://www.thingiverse.com/groups/rbsc/things

-= ! MSX FOREVER ! =-
