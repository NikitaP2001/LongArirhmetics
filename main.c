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
		if (IntToLongVal(temp, val2) == 0)
			puts("Error inttolongval");
		DumpLongVal(val1);
		DumpLongVal(val2);
		
		printf("Addition res: ");
		if (AddLongVal(val1, val2) == 0)
			puts("Addition error");	
		DumpLongVal(val1);
	}
	FreeLongVal(val1);
	FreeLongVal(val2);
	
	puts("hi");
	
}