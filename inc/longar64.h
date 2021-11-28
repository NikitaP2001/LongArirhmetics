#include <stdint.h>

__declspec(dllimport) uint64_t AllocLongVal();

__declspec(dllimport) uint64_t FreeLongVal(uint64_t descriptor);

__declspec(dllimport) int IntToLongVal(int ival, uint64_t desc);

__declspec(dllimport) int AddLongVal(uint64_t op1_desc, uint64_t op2_desc);

__declspec(dllimport) int MovLongVal(uint64_t dest, uint64_t source);

__declspec(dllimport) int SubLongVal(uint64_t op1_desc, uint64_t op2_desc);

__declspec(dllimport) int MultLongVal(uint64_t dest, uint64_t op1, uint64_t op2);

__declspec(dllimport) void DoubleToLongVal(double dval, uint64_t desc);

__declspec(dllimport) void ReallocLongVal(uint64_t desc, uint64_t size);

__declspec(dllimport) int BinToLongVal(uint64_t destination, char *source, uint64_t size);

__declspec(dllimport) int DivideLongVal(uint64_t result, uint64_t reminder,
 uint64_t op1, uint64_t op2);
 
__declspec(dllimport) int CmpEqualLongVal(uint64_t op1, uint64_t op2);

__declspec(dllimport) void LongValToPower(uint64_t desc, uint64_t power);

__declspec(dllimport) void AddLongValByMod(uint64_t op1_desc, uint64_t op2_desc,
uint64_t module);

__declspec(dllimport) void SubLongValByMod(uint64_t op1_desc, uint64_t op2_desc,
uint64_t module);

__declspec(dllimport) void MultLongValByMod(uint64_t op1_desc, uint64_t op2_desc,
uint64_t module);

__declspec(dllimport) void DivLongValByMod(uint64_t result, uint64_t reminder, 
uint64_t op1, uint64_t op2, uint64_t module);

__declspec(dllimport) void LongValToPowerByMod(uint64_t desc, uint64_t power,
uint64_t module);

__declspec(dllimport) void LongValSquareRoot(uint64_t result, uint64_t operant);

__declspec(dllimport) void SolveCongruences(uint64_t result, uint64_t *psys, uint64_t count);

__declspec(dllimport) int CmpLowerLongVal(uint64_t op1, uint64_t op2);

__declspec(dllimport) int LongValToBin(uint64_t source, char *dest, uint64_t dest_size);

__declspec(dllimport) int GetLongValSize(uint64_t source);