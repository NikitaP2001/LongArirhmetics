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
        uint64_t res = AllocLongVal();                              
        
        int a, b;
loop:   
        scanf("%d %d", &a, &b);
        
        IntToLongVal(a, val1);
        IntToLongVal(b, val2);
        
        putchar(' ');
        DumpLongVal(val1);
        printf("x\n ");        
        DumpLongVal(val2);
        puts(" ---------------");       
        
        MultLongVal(res, val1, val2);
        
        DumpLongVal(res);        
        
        goto loop;
        
        FreeLongVal(val1);
        FreeLongVal(val2);
        FreeLongVal(res);
        
        return 0;
}