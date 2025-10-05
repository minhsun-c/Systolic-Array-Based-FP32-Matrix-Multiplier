# Systolic Array Based FP32 Matrix Multiplier

## Description

This project accelerates matrix multiplication in deep learning. The core architecture is Systolic Array, proposed by H. T. Kung. 

The multiplier is composed with N*N pipelined processing elements. Inside each processing element, there is a FP32 multiplier and a FP32 Adder. Both FP32 multiplier and adder has a leading zero detector for normalization.

## Testing

### Overview
The FP32 systolic array is verified using a **Verilator-based C++ testbench** that:
- Drives inputs in a **wavefront (anti-diagonal)** pattern matching an \( N $\times$ N \) mesh.  
- Computes a **golden reference** in C++ using native `float` arithmetic.  
- Compares DUT results against the reference with a small epsilon tolerance.  
- Generates **waveform traces** (`build/wave.vcd`) for debugging.  
- Scales with the matrix dimension \( N \) through Makefile or command-line arguments.  

### Running Tests

#### Quick Start (Verilator default)
```bash
# Clean previous build
make clean

# Build and run for different sizes
make SIZE=2  INPUT=test2.txt  run   # 2×2
make SIZE=8  INPUT=test8.txt  run   # 8×8
make SIZE=16 INPUT=test16.txt run   # 16×16
```

- The simulator defaults to **Verilator**.  
  You can still use **Icarus Verilog** by specifying `SIM=iverilog`.  
- Waveforms are saved as `build/wave.vcd`. 

---

### Using Built-In Testcases

Verified testcases are located in the `data/` directory:

| File | Matrix Size | Status |
|------|--------------|--------|
| `data/test2.txt`  | 2×2  | Correct |
| `data/test8.txt`  | 8×8  | Correct |
| `data/test16.txt` | 16×16 | Correct |

Each file contains known-good inputs and expected outputs for regression testing.  
They are used to validate correctness and maintain consistency across updates.

---

### What Gets Validated

- **Functional correctness** of FP32 multiply-accumulate operations.  
- **Pipeline timing**: reset, input feed, and drain phases.  
- **Numerical accuracy**: equality within floating-point tolerance.  
- **Scalability**: ability to handle various N×N configurations.  

---

### Development Utilities

| Command | Description |
|----------|-------------|
| `make indent` | Format all Verilog and C++ sources. |
| `make wave` | Open waveform (`wave.vcd`) in GTKWave. |
| `make clean` | Remove build and simulation outputs. |
