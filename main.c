/* 
Needed for long arithmetic testing
 */
 
#include "longar64.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <conio.h>
#include <time.h>
#include "windows.h"

static void factorial(int power, uint64_t val)
{
        IntToLongVal(1, val);
        uint64_t temp = AllocLongVal();
        for (int i = 1; i <= power; i++) {
                IntToLongVal(i, temp);
                MultLongVal(val, val, temp);
        }
}

static void WaitForConsoleInput()
{
        printf("Press any key to continue...");
        FlushConsoleInputBuffer(GetStdHandle(STD_INPUT_HANDLE));
        
        while (!_kbhit);
        
        _getch();
        putchar('\n');
}

int main(void)
{	       
        uint64_t result = AllocLongVal();
        uint64_t reminder = AllocLongVal();

        // Power
        puts("65456 to power 1234");
        WaitForConsoleInput();
        uint64_t val = AllocLongVal();
        uint64_t val2 = AllocLongVal();              
        
        IntToLongVal(65456, val);
        clock_t t = clock();       
        LongValToPower(val, 1234);       
        t = clock() - t;        
                
        DumpLongVal(val);        
        printf("time: %.1f sec\n", ((float)t) / (CLOCKS_PER_SEC / 1000));
        
        // Cmpare
        // IntToLongVal(-10, val);
        // IntToLongVal(-11, val2);
        
        // if (CmpEqualLongVal(val, val2))
                // puts("Equal");
        // else puts("Not equal");
        
        // Divide
        puts("Division");
        DumpLongVal(val);
        IntToLongVal(123448765, val2);
        MultLongVal(val, val, val2);        
        DumpLongVal(val);
        DivideLongVal(result, reminder, val, val2);
        DumpLongVal(result);

        

        return 0;
}