# A UART Transmitter

UART (or Universal Asynchronous Receiver Transmitter) is a hardware device that is used for serial communication between two devices. Multi-bit data can be transmitted across devices in 2 ways; using a serial interface and using a parallel interface. A parallel interface means that all the bits (usually 8) are sent across the devices at the same time, using multiple wires. Serial transmission is the opposite, where each bit in the data is sent across a single wire one at a time. A UART is a device that is used to facilitate a serial data transmission.

UART typically works in 4 dates:

IDLE :  This is the "rest" state of the UART, where no transmission takes place. the Tx port outputs a constant high (1), instead of a low signal (0) because any malfunction/damage can easily be detected (the output would be a low when its not meant to be).
START :  This is the first stage in the transmission process. A 0 bit is sent across the Tx port, indicating that the DATA bits will be following on the next baud.
DATA :  This is where each bit of the data will be sent across the Tx, starting with the Least Significant Bit (LSB) and ending with the Most Significant Bit (MSB).
PARITY : This is an optional step where a parity bit is sent after the data, which will be used to ensure that data corruption has not occurred.
STOP :  This tends to be either one or two high (1) bits that are sent to indicate the end of the transmission cycle. After this is sent, the cycle returns back to the IDLE state.

# My Attempt At Making A UART Transmitter

This is my attempt at creating a UART transmitter (no receiver) using a 1 MHz processor clock. 

My UART transmitter contains one START bit, 8 DATA bits, no PARITY bits and 2 STOP bits. 

It consists of a 9600 bps baud generator, as UART only uses certain speeds (such as 9600, 19200, 38400 etc.) so the processor clock has to be "slowed down" in order to match the baud rate of the UART protocol. As well as a baud generator, a finite state machine is used to compartmentalise each of the states, controlling what the outputs are as a result of what state it is in. 


# How To Test Transmitter

In order to test the UART Transmitter, the following prerequisites are needed:

*  cocotb
*  Verilator
*  Python3.8+

To run the testbench run:

```bash
make

