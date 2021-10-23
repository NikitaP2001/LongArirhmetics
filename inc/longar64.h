#include <stdint.h>
#pragma pack(push, 1)
struct longval {
	uint64_t val_size;
	unsigned char *val_ptr;
	unsigned int val_sign;
};
#pragma pop()


__declspec(dllimport) void DllMonitor(char *msg);
__declspec(dllimport) void DumpLongVal(struct longval *val);
__declspec(dllimport) int LongValUnsignedAdd(struct longval *op1, struct longval *op2);
__declspec(dllimport) uint64_t AllocLongVal();
__declspec(dllimport) uint64_t FreeLongVal(uint64_t descriptor);