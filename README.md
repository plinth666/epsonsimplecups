# epsonsimplecups
A simple CUPS driver for the Epson TM-T20 POS printer.
Epson provides a driver for this printer, but they only provide x86 and x64 linux binary builds instead of source. As a result, the driver can't be used on ARM systems, such as the Raspberry PI.

This is a very simple driver that provides buffered raster printing and paper cutting at end of page or end of job.

