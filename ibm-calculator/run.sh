s390x-linux-gnu-gcc -o ibm -static -fno-pie -no-pie -ggdb3 driver.c ibm-1.s
./ibm
rm ibm
