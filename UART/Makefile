TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = $(PWD)/uart_transmit.sv
TOPLEVEL = uart_transmit
MODULE = test_uart   # name of my cocotb testbench

SIM = verilator

# Enable VCD waveform dump
EXTRA_ARGS += --trace

include $(shell cocotb-config --makefiles)/Makefile.sim
