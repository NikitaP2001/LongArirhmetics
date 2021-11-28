IFNDEF LONGVAL_INC
LONGVAL_INC EQU LONGVAL_INC

HEAP_GENERATE_EXCEPTIONS EQU 4
HEAP_ZERO_MEMORY EQU 8
HEAP_NO_SERIALIZE EQU 1

VAL_DEFAULT_SIZE EQU 1
VALMEM_DEFAULT_SIZE EQU 100
lplongval TYPEDEF PTR longval
longval STRUCT 
	val_size 	QWORD		0
	val_ptr		QWORD 		0
	val_sign	QWORD		0
	descriptor	QWORD		0
        mem_size        QWORD           0
longval ENDS

VALSET STRUCT
	val_count	QWORD	0
	val_array	lplongval 0
VALSET ENDS
EXTERNDEF global_set:VALSET

VALREG STRUCT
        descriptor      QWORD   0
        IsFree          QWORD   0
VALREG ENDS

EXTERNDEF ValStash:QWORD
StashSize = 1000

AllocLongVal	PROTO	

FreeLongVal		PROTO	descriptor:QWORD

CompactLongVal PROTO desc:QWORD

ReallocLongVal PROTO desc:QWORD, new_size:QWORD

GetLongvalPtr PROTO desc:QWORD

BinToLongVal PROTO dest:QWORD, source:PTR BYTE, s_size:QWORD

LongValToBin PROTO source:QWORD, dest:PTR BYTE, dest_size:QWORD

GetLongValSize PROTO source:QWORD

; Get preallocated longval 
stalloc MACRO
LOCAL @for
LOCAL @endf

        push rdi
        push rcx
        mov rcx, StashSize               
        mov rdi, ValStash
@for:                  
                cmp (VALREG ptr [rdi]).IsFree, 0    
                je @endf
                add  rdi, SIZEOF VALREG
                dec rcx
                je @Error
                jmp @for        
@endf:     
        mov rax, (VALREG ptr [rdi]).descriptor
        mov (VALREG ptr [rdi]).IsFree, 1
        pop rcx
        pop rdi
ENDM

; Mark preallocated longval as free
stfree MACRO desc
LOCAL @for
LOCAL @endf
        push rdi
        push rcx
        push rbx
        mov rbx, desc
        mov rcx, StashSize               
        mov rdi, ValStash
@for:                  
                cmp (VALREG ptr [rdi]).descriptor, rbx   
                je @endf
                add  rdi, SIZEOF VALREG
                dec rcx
                je @Error
                jmp @for        
@endf:             
        mov (VALREG ptr [rdi]).IsFree, 0
	pop rbx
        pop rcx
        pop rdi
ENDM

ENDIF