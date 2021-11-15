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
	uint64_t val1 = AllocLongVal();                            
        uint64_t val2 = AllocLongVal();                            
        uint64_t res = AllocLongVal();                            
        
        IntToLongVal(0xFFFF, val1);
        IntToLongVal(0x1732A, val2);
        MultLongVal(res, val1, val2);   
        IntToLongVal(0xE, val2);
        MultLongVal(res, res, val2);   
        DumpLongVal(res);

        return 0;
}