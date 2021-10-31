IFNDEF MAIN_INC
MAIN_INC EQU MAIN_INC
DEBUG EQU DEBUG

HeapAlloc EQU RtlAllocateHeap
HeapReAlloc EQU RtlReAllocateHeap
HeapValidate EQU RtlValidateHeap

EXTERNDEF DllHeapHandle:QWORD

ENDIF

