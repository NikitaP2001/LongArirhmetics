TARGET = longar64

SRC_DIR = src
OBJ_DIR = obj
INC_DIR = inc

PATH=E:\masm64\

vpath %.asm SRC_DIR
vpath %.inc INC_DIR
vpath %.obj OBJ_DIR

CFLAGS = /c /Cp /I $(PATH)include
LDFLAGS = /SUBSYSTEM:WINDOWS /ENTRY:DllMain /DLL /section:.bss
LDLIBS = /LIBPATH:$(PATH)lib

CC=E:\masm64\bin\ml64.exe
LNK=E:\masm64\bin\link.exe

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
OBJECTS = $(subst $(SRC_DIR)/,$(OBJ_DIR)/,$(SOURCES:.asm=.obj))

%.obj: src/%.asm
	$(CC) $(CFLAGS) -c -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LNK) $(LDFLAGS) -o $@ $^

clean:
	del $(OBJ_DIR)\*.obj
	del $(TARGET).dll
