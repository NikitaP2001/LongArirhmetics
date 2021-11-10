@echo off

set FILENAME=test
set SOURCES=main.c
set OBJECTS=main.o

set CFLAGS=-O0 -std=gnu11 -s -mconsole -I./inc
set LKFLAGS=-Wl,--gc-sections -L./lib -llongar64

@echo on
gcc %SOURCES% -o %FILENAME% %CFLAGS% %LKFLAGS%
@echo off
	if errorlevel 1 goto terminate
@echo on
	dir
	:terminate
	pause