#include <stdint.h>

__declspec(dllimport) int DumpLongVal(uint64_t descriptor);

__declspec(dllimport) int LongValUnsignedAdd(uint64_t op1_desc, uint64_t op2_desc);

__declspec(dllimport) uint64_t AllocLongVal();

__declspec(dllimport) uint64_t FreeLongVal(uint64_t descriptor);

__declspec(dllimport) int IntToLongVal(int ival, uint64_t desc);

__declspec(dllimport) int LongValUnsignedSub(uint64_t op1_desc, uint64_t op2_desc);