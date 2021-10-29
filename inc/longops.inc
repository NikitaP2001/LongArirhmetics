IFNDEF longops
longops EQU longops

HEAP_GENERATE_EXCEPTIONS EQU 4
HEAP_ZERO_MEMORY EQU 8
HEAP_NO_SERIALIZE EQU 1

VAL_DEFAULT_SIZE EQU 1
lplongval TYPEDEF PTR longval
longval STRUCT 
	val_size 	QWORD		0
	val_ptr		QWORD 		0
	val_sign	QWORD		0
	descriptor	QWORD		0
longval ENDS

VALSET STRUCT
	val_count	QWORD	0
	val_array	lplongval 0
VALSET ENDS

EXTERNDEF global_set:VALSET

UAddLongVal PROTO op1:QWORD, op2: QWORD

USubLongVal PROTO op1:QWORD, op2: QWORD

XchgLongVal PROTO op1:QWORD, op2: QWORD

MovLongVal PROTO dest:QWORD, source: QWORD

AddLongVal PROTO op1:QWORD, op2: QWORD

UCmpLongVal PROTO op1:QWORD, op2:QWORD

CmpEqualLongVal PROTO op1:QWORD, op2: QWORD

CmpGreaterLongVal PROTO op1:QWORD, op2: QWORD

CmpLowerLongVal PROTO op1:QWORD, op2: QWORD

LongValToStdString PROTO target:QWORD, source:QWORD

AllocLongVal	PROTO	
FreeLongVal		PROTO	descriptor:QWORD

GetLongvalPtr PROTO desc:QWORD

IntToLongVal PROTO ival:DWORD, desc:QWORD

ENDIF