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
        uint64_t val = AllocLongVal();
        uint64_t val2 = AllocLongVal();
        
// loop:        
        // BinToLongVal(val, binval, sizeof(binval));
        // DumpLongVal(val);
        
        // IntToLongVal(11, val2);
        // DumpLongVal(val2);
        
        // MultLongVal(val, val, val2);
        // DumpLongVal(val);
        // getchar();
        
        // goto loop;
        
        
        clock_t t;
loop:        
        t = clock();
        factorial(300, val);
        
        t = clock() - t;
        printf("%f ms\n", ((float)t) / (CLOCKS_PER_SEC/1000));
        
        
        DumpLongVal(val);
        getchar();
        goto loop;        

        return 0;
}