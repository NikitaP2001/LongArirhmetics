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
        
        if (_getch() == 27)
                exit(0);
        putchar('\n');
}

int DumpLongVal(uint64_t long_val, int base)
{
        char *buf;
        int sign, size;
        // if (base != 10 && base != 16) {
                // puts("Wrong base: can be 16 or 10 inly");
                // return 0;
        // }
        
        size = GetLongValSize(long_val);
        
        if (size == 0) {
                puts("Dump error: wrong longval descriptor");       
                return 0;
        }                
        
        if (base == 16) {
                buf = (char*)malloc(size);
        
                if ((sign = LongValToBin(long_val, buf, size)) == -1) {
                        puts("Inpossible to convert");
                        return 0;
                }
                
                if (sign == 1)
                        putchar('-');
                
                for (int i = 0; i < size; i++) {
                        printf("%02hx", (unsigned char)buf[i]);
                }
                
        } else {
                uint64_t divider = AllocLongVal();
                uint64_t quotient = AllocLongVal();
                uint64_t reminder = AllocLongVal();
                uint64_t divident = AllocLongVal();
                uint64_t lvzero = AllocLongVal();
                int length;
                
                IntToLongVal(0, lvzero);
                IntToLongVal(10, divider);
                MovLongVal(divident, long_val);
                
                buf = malloc(size*3);
                memset(buf, 0, size*3);
                
                if (CmpEqualLongVal(lvzero, divident))
                        length = 1;
                else 
                        length = 0;
                
                while (!CmpEqualLongVal(lvzero, divident)) {                        
                        DivideLongVal(quotient, reminder, divident, divider);                        
                        sign = LongValToBin(reminder, &buf[length++], 1);
                        MovLongVal(divident, quotient);
                } 

                if (sign == 1)
                        putchar('-');                                               
                for (int i = length - 1; i >= 0; i--) {
                        printf("%hhu", (unsigned char)buf[i]);
                }
                
                FreeLongVal(divident);
                FreeLongVal(divider);
                FreeLongVal(quotient);
                FreeLongVal(reminder);
                FreeLongVal(lvzero);
        }
        putchar('\n');
        
        return 1;
}

int main(void)
{	       
        uint64_t result = AllocLongVal();
        uint64_t reminder = AllocLongVal();
        uint64_t module = AllocLongVal();
        uint64_t val = AllocLongVal();
        uint64_t val2 = AllocLongVal();                      
        
        // Congruences
        // puts("Solve congruences");
        // WaitForConsoleInput();
        // int count;
        // scanf("%d", &count);
        // uint64_t *congr = calloc(sizeof(uint64_t), count * 2);
        // for (int i = 0; i < count; i++) {
                // int r, a;
                // scanf("%d %d", &r, &a);
                // congr[i*2] = AllocLongVal();
                // IntToLongVal(r, congr[i*2]);
                // congr[i*2+1] = AllocLongVal();
                // IntToLongVal(a, congr[i*2+1]);
        // }
        // SolveCongruences(result, congr, count);
        // DumpLongVal(result, 16);
        // for (int i = 0; i < count; i++) {
                // FreeLongVal(congr[i*2]);                
                // FreeLongVal(congr[i*2+1]);               
        // }
        
        // Divide
        puts("Division");
        WaitForConsoleInput();
        IntToLongVal(0x2B, val);
        IntToLongVal(2, val2);        
        DivideLongVal(result, reminder, val, val2);
        DumpLongVal(result, 10);
        
        // Square root
        puts("Square root");
        WaitForConsoleInput();
        IntToLongVal(0x2B, val);
        LongValSquareRoot(result, val);               
        DumpLongVal(result, 10); 
        
        // Divide
        puts("Division");
        WaitForConsoleInput();
        DumpLongVal(val, 0x2B);
        IntToLongVal(2, val2);        
        DivideLongVal(result, reminder, val, val2);
        DumpLongVal(result, 16);
        
        
        // Add
        puts("Add");
        WaitForConsoleInput();
        IntToLongVal(1234, val);
        IntToLongVal(54321, val2);
        IntToLongVal(15, module);
        AddLongVal(val, val2);
        DumpLongVal(val, 16);       

        // Power
        puts("65456 to power 100");
        WaitForConsoleInput();                    
        IntToLongVal(65456, val);
        clock_t t = clock();       
        LongValToPower(val, 100);       
        t = clock() - t;        
                
        DumpLongVal(val, 16);        
        printf("time: %.1f sec\n", ((float)t) / (CLOCKS_PER_SEC / 1000));        
        
        // Cmpare
        // IntToLongVal(-10, val);
        // IntToLongVal(-11, val2);
        
        // if (CmpEqualLongVal(val, val2))
                // puts("Equal");
        // else puts("Not equal");                

        // Add by module
        puts("Add by mod");
        WaitForConsoleInput();
        IntToLongVal(123454, val);
        IntToLongVal(12348, val2);
        IntToLongVal(15, module);
        SubLongValByMod(val, val2, module);
        DumpLongVal(val, 16);
        
        // Mult by module
        puts("Mult by mod");
        WaitForConsoleInput();
        IntToLongVal(123454, val);
        IntToLongVal(12348, val2);
        IntToLongVal(15, module);
        MultLongValByMod(val, val2, module);
        DumpLongVal(val, 16);
        
        // Divide by module
        puts("Div by mod");
        WaitForConsoleInput();
        IntToLongVal(1234540, val);
        IntToLongVal(1234, val2);
        IntToLongVal(155, module);
        DivLongValByMod(result, reminder, val, val2, module);               
        DumpLongVal(result, 16);  

        // Divide by module
        puts("Power by mod");
        WaitForConsoleInput();
        IntToLongVal(1234540, val);
        IntToLongVal(155, module);
        LongValToPowerByMod(val, 123, module);               
        DumpLongVal(val, 16);                

        return 0;
}