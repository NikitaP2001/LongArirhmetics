#include <stdint.h>

__declspec(dllimport) int DumpLongVal(uint64_t descriptor);

__declspec(dllimport) uint64_t AllocLongVal();

__declspec(dllimport) uint64_t FreeLongVal(uint64_t descriptor);

__declspec(dllimport) int IntToLongVal(int ival, uint64_t desc);

__declspec(dllimport) int AddLongVal(uint64_t op1_desc, uint64_t op2_desc);

__declspec(dllimport) int MultLongVal(uint64_t dest, uint64_t op1, uint64_t op2);
