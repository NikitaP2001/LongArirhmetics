SHELL=cmd.exe
TARGET = longar64

SRC_DIR = src
OBJ_DIR = obj
INC_DIR = inc
LIB_DIR = lib

PATH=\masm64

vpath %.asm SRC_DIR
vpath %.inc INC_DIR
vpath %.obj OBJ_DIR

CFLAGS = /c /Cp /I $(PATH)\include /I $(INC_DIR)
LDFLAGS = /SUBSYSTEM:WINDOWS /ENTRY:DllMain /DLL /ALIGN:16 \
	  /DEF:$(TARGET).def
LDLIBS = /LIBPATH:$(PATH)\lib

CC=\masm64\bin\ml64.exe
LNK=\masm64\bin\link.exe

SOURCES = $(wildcard $(SRC_DIR)/*.asm)
OBJECTS = $(subst $(SRC_DIR)/,$(OBJ_DIR)/,$(SOURCES:.asm=.obj))

$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.asm
	$(CC) $(CFLAGS) /Fo $@ $<

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LNK) $(LDFLAGS) /OUT:$@ $(LDLIBS) $^
	move .\$(TARGET).lib .\$(LIB_DIR)
	move $(TARGET) $(TARGET).dll
	del *.exp

clean:
	@-del $(TARGET).dll $(OBJ_DIR)\*.obj \
	.\$(LIB_DIR)\*.lib
