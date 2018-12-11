# ST7565 FPGA Controller

![alt ST7565](https://github.com/freddy-/ST7565/raw/master/st7565.png)

This project contains code to describe a hardware that initialize and drive a ST7565 display using a FPGA. 
That display was removed from an old HP printer. I've used one cheap chinese logic analyzer to debug the communication between the main board and the display.
The data is sent to display througth the SPI protocol at approximatedly 2MHz. 
It currently only sends 0xF0 and 0x0F patterns to fill the screen.

The next step is to create a frame buffer, using the FPGA BRAM, to draw pixels in X Y coordinates.
It was implemented using my DIY FPGA dev board [found here](https://hackaday.io/project/33754-diy-fpga-dev-board).