#!/bin/bash
gcc -m64 -no-pie -std=c17 -c driver.c
nasm -f elf64 main2.asm &&
gcc -m64 -no-pie -std=c17 -o main2 driver.c main2.o&&
./main2
rm main2.o main2 driver.o
