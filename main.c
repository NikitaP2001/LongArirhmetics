/* 
Needed for long arithmetic testing
 */
 
#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "windows.h"

uint64_t numbers[100];

static void mult(uint64_t op1, uint64_t op2, int times)
{
	for (uint64_t i = 0; i < times; i++) {
		if (LongValUnsignedAdd(op2, op1) == 0)
			puts("error addition");
	}
}

int main(void)
{	
	for (int j = 0; j < 100; j++) {
		for (int i = 0; (numbers[i] = AllocLongVal()) && i < 100; i++);
		
		for (int i = 0; (numbers[i] = FreeLongVal(numbers[i])) && i < 100; i++);
	}

	
	uint64_t val1 = AllocLongVal();
	uint64_t val2 = AllocLongVal();
	while (1) {
		int temp;
		scanf("%d", &temp);
		if (IntToLongVal(temp, val1) == 0)
			puts("Error int to longval");
		scanf("%d", &temp);
		if (IntToLongVal(0, val2) == 0)
			puts("Error inttolongval");
		DumpLongVal(val2);
		
		printf("Multiplication res: ");
		mult(val1, val2, temp);
		if (DumpLongVal(val2) == 0)
			puts("Dump error");
		
	}
	FreeLongVal(val1);
	FreeLongVal(val2);
	
	puts("hi");
	
}
