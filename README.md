# Assembly Language Projects #

This repository contains a variety of assembly language programs written in both x86 and MIPS architecture. The difference between x86 and MIPS architecture is that x86 is Complex Instruction Set Computing (CISC) while ARM is Reduced Instruction Set Computing (RISC). 

MIPS: 

* Emphasis on software, Single-clock, reduced instruction only

* 13 general-purpose registers, preceded by $ in assembly language instruction (ex. $0, $t3). special registers Lo and Hi used to store result of multiplication and division 

* Spends more transistors on memory registers

x86:

* Emphasis on hardware, Includes multi-clock complex instructions

* 8 general-purpose registers. Registers can be accessed based on # of bits required (ex. EAX = 32 bits, AX = 16 bits, AH = 8 bits Hi, Al= 8 bits Lo)

* Transistors used for storing complex instructions

**Programs in x86:**

* Factorials

* Number of Vowels

**Programs in MIPS:**

* Coming Soon

## Running the x86 Programs ##

In linux, install NAMS:
```

$ sudo apt-get install nasm
```

Go to the directory of the downloaded or forked project and run the make file. Finally, run the program in terminal
```

$ make
...
$ ./Vowels
```

## Running the MIPS Programs ##

Download and open the MIPS file with [MARS (MIPS Assembler and Runtime Simulator)](http://courses.missouristate.edu/KenVollmar/MARS/), from Missouri State University 

