/* 
Needed for long arithmetic testing
 */
 
#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "windows.h"

uint64_t numbers[20000];

int main(void)
{	      
     
	uint64_t val = AllocLongVal();                            
        
        double fval;
loop:   
        scanf("%lf", &fval);
        
        DoubleToLongVal(fval, val);
        
        DumpLongVal(val);
        
        
        goto loop;
        
        FreeLongVal(val); 

        return 0;
}