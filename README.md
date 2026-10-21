# NPU-assignment
Verilog implementation and simulation of a Round Robin Arbiter and an Add-and-Shift Multiplier
# RISC-V Based NPU Assignment

This repository contains the Verilog HDL implementations, testbenches, and simulation results for the NPU assignment. It covers a Round Robin Arbiter, an optimized 4-bit multiplier, and a configurable 128-bit SIMD Arithmetic Unit as the bonus problem.

## Table of Contents

- [Problem 1: Round Robin Arbiter](#problem-1-4-request-round-robin-arbiter)
- [Problem 2: Add-and-Shift Multiplier](#problem-2-optimized-4-bit-multiplier)
- [Bonus: 128-bit SIMD Arithmetic Unit](#bonus-128-bit-configurable-simd-arithmetic-unit)
- [Tools Used](#tools-used)
- [Repository Structure](#repository-structure)
- [Running the Simulations](#running-the-simulations)

---

## Problem 1: 4-Request Round Robin Arbiter

### Objective

Design a 4-request Round Robin Arbiter that grants access to one requester at a time in a fair and cyclic manner.

### Working Principle

The arbiter receives four request signals and generates a one-hot grant signal based on the current priority. After granting access to a requester, it updates its priority so that the next requester gets a chance first. This process repeats as long as requests are active.

The design uses a state register to store the last granted requester. The arbitration logic checks requests in cyclic order based on this state.

### Main Features

- Supports four independent requesters.
- Grants access to at most one requester at a time.
- Updates priority after each grant.
- Provides fair arbitration when requests remain active.
- Includes a testbench to verify arbitration behavior.

### Files

- `rr_arbiter.v` — Verilog implementation of the arbiter.
- `rr_arbiter_tb.v` — Testbench for checking the grant sequence.
- `waveform.png` — Simulation waveform, if included.

### Verification

The testbench checks different request combinations, including simultaneous requests from all four requesters. The waveform is used to verify that the grant is one-hot and that the priority changes after each grant.

---

## Problem 2: Optimized 4-Bit Multiplier

### Objective

Implement a 4-bit unsigned multiplier using the add-and-shift algorithm.

### Working Principle

The multiplier uses four main registers: M, A, Q, and C. Register M stores the multiplicand, Q stores the multiplier, A stores the partial product, and C stores the carry generated during addition.

At each iteration, the least-significant bit of Q is checked. If it is 1, M is added to A. The combined C\:A register is then shifted right by one bit. If Q[0] is 0, the addition is skipped and the combined register is shifted directly.

The process runs for four iterations. A control unit manages the iteration count, keeps track of whether multiplication is in progress, and asserts `done` when the result is ready.

### Main Features

- Accepts two 4-bit unsigned operands.
- Uses the add-and-shift multiplication algorithm.
- Uses a carry flip-flop to preserve the carry during addition.
- Produces an 8-bit product.
- Signals completion using the `done` output.

### Files

- `code.v` — Verilog implementation of the multiplier.
- `code_tb.v` — Testbench for checking multiplication results.
- `waveform.png` — Simulation waveform, if included.

### Test Cases

| Multiplicand | Multiplier | Expected Product |
| ------------ | ---------- | ---------------- |
| `1011` (11)  | `0111` (7) | `01001101` (77)  |
| `0110` (6)   | `1001` (9) | `00110110` (54)  |

### Verification

The testbench applies both input combinations and checks the resulting product against the expected value. The waveform can be used to observe the register updates over the four iterations and verify when `done` is asserted.

---

## Bonus: 128-bit Configurable SIMD Arithmetic Unit

### Objective

Design a configurable 128-bit SIMD (Single Instruction, Multiple Data) Arithmetic Unit that performs parallel unsigned addition and subtraction on packed data elements.

The design supports 8-bit, 16-bit, and 32-bit element widths and uses saturating arithmetic to handle overflow and underflow.

### Input and Output Signals

| Signal      |    Width | Description                     |
| ----------- | -------: | ------------------------------- |
| `A`         | 128 bits | First input operand             |
| `B`         | 128 bits | Second input operand            |
| `width_sel` |   2 bits | Selects the element width       |
| `sub`       |    1 bit | Selects addition or subtraction |
| `Y`         | 128 bits | Arithmetic result               |

### Element Width Selection

The `width_sel` signal determines how the two 128-bit operands are divided into independent lanes.

| `width_sel` | Element Width | Number of Lanes |
| ----------- | ------------: | --------------: |
| `00`        |        8 bits |              16 |
| `01`        |       16 bits |               8 |
| `10`        |       32 bits |               4 |
| `11`        |      Reserved |               0 |

Lane 0 contains the least-significant bits of each operand. The remaining lanes follow in increasing bit order.

### Operation Selection

| `sub` | Operation   |
| ----- | ----------- |
| `0`   | Addition    |
| `1`   | Subtraction |

The selected operation is performed independently on every active lane.

### Saturating Arithmetic

The design uses unsigned saturation instead of allowing arithmetic results to wrap around.

**Saturating addition:** If a sum exceeds the maximum value representable by the selected lane width, the output is set to that maximum value.

| Element Width | Maximum Value                  |
| ------------- | ------------------------------ |
| 8 bits        | `8'hFF` (255)                  |
| 16 bits       | `16'hFFFF` (65,535)            |
| 32 bits       | `32'hFFFFFFFF` (4,294,967,295) |

For example, in 8-bit mode, 250 + 20 produces 255 because the mathematical result, 270, exceeds the maximum 8-bit unsigned value.

**Saturating subtraction:** If A is smaller than B in a lane, the result for that lane is set to zero. Otherwise, the normal subtraction result is returned.

For example, 100 − 500 produces zero.

### Working Principle

The input operands are divided into lanes according to the selected element width. Each lane performs addition or subtraction independently.

For addition, an extended-width intermediate result is used to detect overflow. For subtraction, the operands are compared to detect underflow. Each lane saturates independently, so overflow or underflow in one lane does not affect the others.

The design is combinational and does not require a clock or reset signal.

### Files

- `simd_add_sub_128.v` — Verilog implementation of the SIMD arithmetic unit.
- `tb_simd_add_sub_128.v` — Testbench for checking arithmetic and saturation behavior.
- `waveform.png` — Simulation waveform, if included.

### Verification

The testbench should check all three element widths and cover:

- Normal addition.
- Normal subtraction.
- Saturating addition due to overflow.
- Saturating subtraction due to underflow.
- Reserved width selection (`width_sel = 2'b11`).

The testbench compares the actual 128-bit output with the expected result and reports PASS or FAIL for each test.

### Example Test Cases

| Mode      | Example                 | Expected Lane Result |
| --------- | ----------------------- | -------------------- |
| 8-bit     | 250 + 20                | 255                  |
| 16-bit    | 65000 + 1000            | 65535                |
| 32-bit    | `32'hFFFFFFF0 + 32'h20` | `32'hFFFFFFFF`       |
| All modes | 100 − 500               | 0                    |

These are lane-level examples. The full 128-bit output contains the corresponding result in every active lane.

---

## Tools Used

- Verilog HDL
- Intel Quartus Prime
- ModelSim / Questa Simulator

## Repository Structure

The repository is organized into separate folders for each part.

```text
NPU-Assignment/
├── README.md
├── Problem-1-Round-Robin-Arbiter/
│   ├── rr_arbiter.v
│   ├── rr_arbiter_tb.v
│   └── waveform.png
├── Problem-2-Add-Shift-Multiplier/
│   ├── code.v
│   ├── code_tb.v
│   └── waveform.png
└── Bonus-SIMD-Arithmetic-Unit/
    ├──bonus.v
    ├── tb_bonus.v
    └── waveform.png
```

Waveform images are optional until generated. Keep the filenames in the README consistent with the actual files uploaded to GitHub.

## Running the Simulations

1. Open ModelSim or Questa.
2. Create a project or working library for the design you want to test.
3. Add the corresponding Verilog design and testbench files.
4. Compile both files and resolve any compilation errors.
5. Set the relevant testbench as the simulation top module.
6. Run the simulation until all test cases have completed.
7. Check the transcript for PASS or FAIL messages.
8. Inspect the waveform to verify the signals and register updates.
9. Save waveform screenshots and add them to the corresponding project folder.

## Conclusion

This assignment demonstrates three digital design concepts: fair resource arbitration, sequential multiplication using the add-and-shift algorithm, and parallel arithmetic using a configurable SIMD architecture.

The designs use Verilog HDL and testbenches to check their functional behavior. Simulation results help verify the arbitration sequence, multiplication results, and saturation behavior across different SIMD lane widths.
