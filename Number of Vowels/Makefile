######################
PROJECT = Vowels
######################


CC   = gcc

# win 64
ASM  = nasm -f win64
RM   = del
BIN  = $(PROJECT).exe

# linux 64
#ASM = nasm -f elf64
#RM = rm -f
#BIN  = $(PROJECT)


OBJ = $(PROJECT).o  


all:    $(BIN)

clean:
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CC) $(OBJ) -o $(BIN) 

$(OBJ): $(PROJECT).s
	$(ASM) $(PROJECT).s -o $(PROJECT).o 

