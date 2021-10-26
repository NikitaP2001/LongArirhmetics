IFNDEF main
DEBUG EQU DEBUG

HeapAlloc TEXTEQU RtlAllocateHeap
HeapReAlloc TEXTEQU RtlReAllocateHeap
HeapValidate TEXTEQU RtlValidateHeap

EXTERNDEF DllHeapHandle:QWORD

ENDIF

