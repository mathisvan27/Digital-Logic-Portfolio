import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


BAUD_DIV = 104  # 1 MHz / 9600 ≈ 104.167 (your code uses 103)

async def reset_dut(dut):
    dut.reset.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)
    dut.reset.value = 0
    await RisingEdge(dut.clk)


@cocotb.test()
async def test_uart_transmit_byte(dut):
    """Test UART transmit for one byte."""

    # Start clock (1 MHz → 1us period)
    cocotb.start_soon(Clock(dut.clk, 1, units="us").start())

    # Reset
    await reset_dut(dut)

    # Send a test byte
    test_byte = 0x55  # 01010101
    dut.in_msg.value = test_byte
    dut.i_tx_start.value = 1
    await RisingEdge(dut.clk)
    dut.i_tx_start.value = 0  # pulse only once

    # UART frame = start(0) + data(8 LSB-first) + stop(1)
    expected_bits = [0] + [(test_byte >> i) & 1 for i in range(8)] + [1]

    # Check each bit on message_out
    for i, bit in enumerate(expected_bits):
        # wait ~1 baud period (104 clocks)
        for _ in range(BAUD_DIV):
            await RisingEdge(dut.clk)
        assert dut.message_out.value == bit, f"Bit {i} mismatch: expected {bit}, got {dut.message_out.value}"
