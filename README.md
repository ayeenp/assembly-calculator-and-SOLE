# Assembly Calculator and System of Linear Equations

This repository houses a collection of assembly code implementations designed for solving system of linear equations and performing calculations on 256-bit integers, Coded for IBM s/390x and Intel x86 processors.

## Features

- **System of Linear Equations Solver**: This solver is tailored for IBM s/390x and Intel x86 processors, offering efficient solutions to linear equation systems.
  
- **256-bit Integer Calculator**: Designed for IBM s/390x and Intel x86 processors, this calculator utilizes multiple registers and combines them to execute common 256-bit calculations.

- **Optimized Performance**: The Intel x86 solver leverages AVX2 SIMD floating-point extensions for parallel processing, ensuring faster computation times.

## How to Run

1. Clone this repository to your local machine.

2. Navigate to the desired folder containing the assembly code you wish to run.

3. Execute the `run.sh` script in each folder to run the respective assembly code.

## Prerequisites

### For IBM Assembly

To compile the IBM assembly codes, ensure you have the s/390x gcc compiler installed:

```bash
sudo apt install build-essential gcc-s390x-linux-gnu gdb-multiarch qemu-user
```

### For x86 Assembly

To compile the x86 assembly codes, you need to install `nasm`:

```bash
sudo apt install nasm
```

## Contribution

Contributions are welcome! If you have any ideas for improvements, feel free to open an issue or submit a pull request.

