/* 
Needed for long arithmetic testing
 */
 
#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "windows.h"

static void factorial(int power, uint64_t val)
{
        IntToLongVal(1, val);
        uint64_t temp = AllocLongVal();
        for (int i = 1; i <= power; i++) {
                IntToLongVal(i, temp);
                MultLongVal(val, val, temp);
                printf("%d\n", i);
                DumpLongVal(val);
        }
}

int main(void)
{	          
        uint64_t val = AllocLongVal();
        clock_t t;
loop:        
        t = clock();
        factorial(29, val);
        
        t = clock() - t;
        printf("%f ms\n", ((float)t) / (CLOCKS_PER_SEC/1000));
        
        
        DumpLongVal(val);
        getchar();
        goto loop;        

        return 0;
}