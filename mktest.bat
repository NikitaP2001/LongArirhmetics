@echo off

set FILENAME=test
set SOURCES=*.c
set OBJECTS=*.o

set CFLAGS=-O3 -s -mconsole -I./inc
set LKFLAGS=-Wl,--gc-sections -L./lib -llongar64

@echo on
gcc %SOURCES% -o %FILENAME% %CFLAGS% %LKFLAGS%
@echo off
	if errorlevel 1 goto terminate
@echo on
	dir
	:terminate
	pause