/* 
Needed for long arithmetic testing
 */
 
#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "windows.h"


char binval[] = {0x37, 0x5f, 0x00};

static void factorial(int power, uint64_t val)
{
        IntToLongVal(1, val);
        uint64_t temp = AllocLongVal();
        for (int i = 1; i <= power; i++) {
                IntToLongVal(i, temp);
                MultLongVal(val, val, temp);
        }
}

int main(void)
{	       
        // Take factorial
        uint64_t val = AllocLongVal();
        uint64_t val2 = AllocLongVal();
        
        // clock_t t = clock();
        
        // factorial(10000, val);
        
        // t = clock() - t;        
                
        // DumpLongVal(val);
        // printf("time: %.1f sec", ((float)t) / (CLOCKS_PER_SEC / 1000));
        
        IntToLongVal(-10, val);
        IntToLongVal(-10, val2);
        MultLongVal(val, val, val2);
        DumpLongVal(val);

        return 0;
}