#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "windows.h"

struct longval op1 = {
	.val_size = 6,
	.val_ptr = "\x12\x34\x56\x67\x78\xFF",
};

struct longval op2= {
	.val_size = 6,
	.val_ptr = "\x00\x00\x00\x11\x11\x10",
};

int main(void)
{
	op1.val_ptr[0] = '\x12';
	op2.val_ptr[0]= '\x00';
	char *ptr = malloc(30);
	strcpy(ptr, "Hello from program");
	DllMonitor(ptr);
	
	if (LongValUnsignedAdd(&op1, &op2) == 0)
		puts("\t[-] Addition error");
	
	puts("\t[+] Addition completed");
	puts("op1:");
	DumpLongVal(&op1);
	puts("op2:");
	DumpLongVal(&op2);
	
}
