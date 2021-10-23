IFNDEF longops
longops EQU longops

VAL_DEFAULT_SIZE EQU 10
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

LongValUnsignedAdd PROTO op1:PTR longval, op2: PTR longval

LongValSub PROTO op1:PTR longval, op2: PTR longval

LongValToStdString PROTO target:PTR BYTE, source: PTR longval

AllocLongVal	PROTO	
FreeLongVal		PROTO	descriptor:QWORD

ENDIF