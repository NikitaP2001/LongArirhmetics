IFNDEF LONGVAL_INC
LONGVAL_INC EQU LONGVAL_INC

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


AllocLongVal	PROTO	

FreeLongVal		PROTO	descriptor:QWORD

CompactLongVal PROTO desc:QWORD

ReallocLongVal PROTO desc:QWORD, new_size:QWORD

GetLongvalPtr PROTO desc:QWORD


ENDIF