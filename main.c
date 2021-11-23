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
        
        IntToLongVal(-11, val);
        puts("val1:");
        DumpLongVal(val);
        
        IntToLongVal(12, val2);
        puts("val2:");
        DumpLongVal(val2);
        
        int ans = UCmpEqualLongVal(val, val2);
        if (ans != 0)
                printf("equal");
        else
                printf("non equal");
                
        

        return 0;
}