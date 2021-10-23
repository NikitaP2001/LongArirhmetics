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
	for (int j = 0; j < 1000000; j++) {
		for (int i = 0; (numbers[i] = AllocLongVal()) && i < 100; i++)
			ac++;
		
		for (int i = 0; (numbers[i] = FreeLongVal(numbers[i])) && i < 100; i++)
			fc++;
	}
	timer -= clock();
	
	float dt = (float)timer;
	printf("Got %d Allocations and %d Deallocation in %f ms\n", ac, fc, dt);
	
}
