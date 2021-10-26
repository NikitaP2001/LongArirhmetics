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
	
	uint64_t val;
	
	val = AllocLongVal(val);
	while (1) {
		int temp;
		scanf("%d", &temp);
		IntToLongVal(temp, val);
		DumpLongVal(val);
		
	}
	FreeLongVal(val);
	
	puts("hi");
	
}
