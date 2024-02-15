#!/bin/bash
# nasm -f elf64 asm_io.asm && 
gcc -m64 -no-pie -std=c17 -c driver.c
nasm -f elf64 main1.asm &&
gcc -m64 -no-pie -std=c17 -o main1 driver.c main1.o&&
./main1
rm main1.o main1 driver.o
