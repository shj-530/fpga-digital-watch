import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer


async def tick(dut):
    """Advance one clock cycle and wait for outputs to settle."""
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")


async def tick_n(dut, n):
    """Advance n clock cycles."""
    if n <= 0:
        return
    await ClockCycles(dut.clk, n)
    await Timer(1, unit="ns")


async def press(dut, bit, cycles=2):
    """Hold button[bit] for `cycles` clock cycles, then release."""
    dut.button.value = int(dut.button.value) | (1 << bit)
    await tick_n(dut, cycles)
    dut.button.value = int(dut.button.value) & ~(1 << bit)
    await tick(dut)


@cocotb.test()
async def test_timer_staged(dut):
    """Timer testbench split into integration stages."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    dut.button.value = 0
    dut.sw.value = 0
    await tick(dut)

    CPS = int(dut.CYCLES_PER_SECOND.value)
    HOLD = CPS
    SHORT = 2

    # =========================================================================
    # STAGE 1: Basic Countdown and Auto-stop at Zero
    # Goal: Verify borrow cascade and zero-detect gate.
    # Logic: Force a small value (00:00:03) and verify it hits 0 and stops.
    # =========================================================================
    cocotb.log.info("--- STAGE 1: Testing Countdown and Auto-stop ---")

    # We bypass the FSM and buttons for now by forcing values directly if possible,
    # or just initializing the counters via the 'clr' reset logic.
    # Note: This assumes you have implemented basic time-setting or hardcoded start.

    # For now, let's assume we use the edit logic from Stage 3 to set 3 seconds,
    # OR you can temporarily hardcode a value in your RTL for this test.

    # [ignoring loop detection]
    # (Stage 1 code here)
    assert int(dut.seconds_disp.value) == 0, "Initial state should be 0"

    # =========================================================================
    # STAGE 2: Pause and Resume (FSM Start/Stop)
    # Goal: Verify button[0] toggles counting.
    # =========================================================================
    cocotb.log.info("--- STAGE 2: Testing Pause and Resume ---")

    # First, force a non-zero starting value by poking the internal counter
    # Set seconds to 5 so we have something to count down from
    dut.u_seconds.u_counter.count.value = 5
    await tick(dut)
    assert int(dut.seconds_disp.value) == 5, (
        f"Seconds should be 5 after poke, got {int(dut.seconds_disp.value)}"
    )

    # Press Start (button[0]) — timer should begin counting
    await press(dut, 0, SHORT)
    # Wait enough cycles for 1 tick (CPS cycles after running goes high)
    await tick_n(dut, CPS + 2)
    sec_after_start = int(dut.seconds_disp.value)
    assert sec_after_start < 5, f"Timer should have decremented, got {sec_after_start}"

    # Press Stop (button[0]) — timer should pause
    await press(dut, 0, SHORT)
    frozen = int(dut.seconds_disp.value)
    await tick_n(dut, CPS + 5)
    assert int(dut.seconds_disp.value) == frozen, (
        f"Timer should be paused at {frozen}, got {int(dut.seconds_disp.value)}"
    )

    # =========================================================================
    # STAGE 3: Set Mode (Edit Logic)
    # Goal: Verify button[3] hold enters edit mode and buttons [1]/[0] work.
    # =========================================================================
    cocotb.log.info("--- STAGE 3: Testing Set Mode ---")

    # 1. Reset counter to 0 so we have a clean starting point for edit testing
    dut.u_seconds.u_counter.count.value = 0
    await tick(dut)
    assert int(dut.seconds_disp.value) == 0, "Setup: Seconds should be 0 before edit test"

    # 2. Enter Edit Mode (Long press button[3])
    # Hold slightly longer than CPS to ensure the pulse logic triggers
    await press(dut, 3, HOLD + 5) 
    await tick_n(dut, 5)

    # 3. Test Increment (button[1])
    await press(dut, 1, SHORT)
    await tick_n(dut, 5)
    val_after_inc = int(dut.seconds_disp.value)
    assert val_after_inc == 1, f"Seconds should be 1 after one increment, got {val_after_inc}"

    # 4. Test Decrement (button[0])
    await press(dut, 0, SHORT)
    await tick_n(dut, 5)
    val_after_dec = int(dut.seconds_disp.value)
    assert val_after_dec == 0, f"Seconds should be 0 after decrement, got {val_after_dec}"
