# ARM64-pipelined-CPU
A 5-stage pipelined 64-bit ARM CPU implemented in SystemVerilog with hazard detection, data forwarding, branching, and comprehensive testbenches.

## Overview

This project implements a simplified 64-bit ARM CPU using a 5-stage pipeline architecture: Fetch, Decode, Execute, Memory, and Writeback. It supports arithmetic, load/store, and branching instructions, with full pipeline hazard handling and forwarding to maintain correct operation across all instruction types.

## Features

* 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback)

* Data forwarding and hazard detection

* Support for arithmetic, logic, memory, and branch instructions

* Comprehensive SystemVerilog testbenches for instruction validation and pipeline correctness

* Waveform verification using ModelSim

* Combinational logic constructed from gate primitives to emphasize structural hardware understanding

## Technical Highlights

* Implementation in SystemVerilog, suitable for FPGA prototyping or simulation

* Instruction-level and pipeline-level verification strategies

* Debugging and waveform analysis to ensure correct flag propagation, branch resolution, and hazard handling

* Modular design enabling expansion to additional instruction types or pipeline optimizations

## Skills Demonstrated

* RTL design and simulation

* ARM architecture understanding

* Digital logic, pipelining, and hazard resolution

* Testbench development and waveform analysis

* Hands-on debugging and iterative verification
