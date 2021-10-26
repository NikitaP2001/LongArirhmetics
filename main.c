#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "windows.h"

uint64_t numbers[100];


int main(void)
{	
	clock_t timer;
	int ac = 0, fc = 0;
	
	timer = clock();
	for (int j = 0; j < 10; j++) {
		for (int i = 0; (numbers[i] = AllocLongVal()) && i < 100; i++) {
			ac++;
			printf("%d - th allocated\n", i);
		}
		
		for (int i = 0; (numbers[i] = FreeLongVal(numbers[i])) && i < 100; i++) {
			fc++;
			printf("%d - th deallocated\n", i);
		}
	}
	timer = clock() - timer;
	/* 
	float dt = (float)timer;
	printf("got %d allocations and %d deallocation in %.0f ms\n", ac, fc, dt);
	
	uint64_t val1 = AllocLongVal();
	uint64_t val2 = AllocLongVal();
	
	puts("val1:");
	DumpLongVal(val1);
	
	puts("val2:");
	DumpLongVal(val2);
	
	FreeLongVal(val1);
	FreeLongVal(val2); */
	
}
