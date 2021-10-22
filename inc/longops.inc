IFNDEF longops
longops EQU longops

longval STRUCT 
	val_size 	QWORD		0
	val_ptr		QWORD PTR 	0
	val_sign	DWORD		0
longval ENDS

LongValAdd PROTO val1:PTR longval, val2: PTR longval

LongValSub PROTO val1:PTR longval, val2: PTR longval

ENDIF