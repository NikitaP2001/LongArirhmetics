include ntdll.inc
include kernel32.inc
includelib ntdll.lib
includelib kernel32.lib

include longops.inc
include main.inc

.data

global_set VALSET <0, 0>

.code

LongValUnsignedAdd proc op1:PTR longval, op2: PTR longval
	push rsi
	push rdi
	push r11
	push r12
	
	;read op1 size
	mov r11, (longval PTR [rcx]).val_size
	;case zero size
	test r11, r11
	je @Error
	
	;read op2 size
	mov r12, (longval PTR [rdx]).val_size
	;case zero size
	test r12, r12
	je @Error
	
	;read op1 address
	lea rsi, (longval PTR [rcx]).val_ptr
	mov rsi, QWORD PTR [rsi]
	;case nullptr
	test rsi, rsi
	je @Error
	
	;read op2 address
	lea rdi, (longval PTR [rdx]).val_ptr
	mov rdi, QWORD PTR [rdi]
	;case nullptr
	test rdi, rdi
	je @Error
	
	;case different sizes
	cmp r11, r12
	jne @Error
	
	lea rsi, [rsi + r11 - 1]
	lea rdi, [rdi + r12 - 1]
	
	clc
@@:
	mov al, byte ptr[rdi]
	adc [rsi], al
	pushfq
	
	dec rdi
	dec rsi
	
	dec r11
	je @F
	
	popfq
	jmp @B
	
@@:
	;check owerflow
	mov rax, (longval PTR [rcx]).val_size
	popfq
	jnc @F

@Error:
	mov eax, 0
	
@@:	
	
	pop r12
	pop r11
	pop rdi
	pop rsi
	ret
LongValUnsignedAdd endp

AllocLongVal proc
;Add new longval to global_set
;return:
;	descriptor:QWORD
;-----------------------------
	push rdi
	sub rsp, 28h

	mov rcx, (VALSET PTR global_set).val_count
	mov rdi, (VALSET PTR global_set).val_array
	xor rdx, rdx
@@:
	cmp rdx, rcx
	je @F

	cmp qword ptr[rdi], 0
	je @Found

	add rdi, SIZEOF QWORD
	inc rdx
	jmp @B
	
@@:
	mov r9, rcx
	inc r9
	shl r9, 3
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, (VALSET PTR global_set).val_array
	call HeapReAlloc
	test rax, rax
	je @Error
	mov (VALSET PTR global_set).val_array, rax
	inc (VALSET PTR global_set).val_count
	
	mov rcx, (VALSET PTR global_set).val_count
	lea rdi, [rax + rcx * 8 - 8]
	
@Found:
	;alloc longval
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, SIZEOF longval
	call HeapAlloc
	test rax, rax
	je @Error
	mov qword ptr[rdi], rax
	mov rdi, qword ptr[rdi]
	
	mov (longval PTR [rdi]).val_size, VAL_DEFAULT_SIZE
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, VAL_DEFAULT_SIZE
	call HeapAlloc
	je @Error
	mov (longval PTR [rdi]).val_ptr, rax
	mov (longval PTR [rdi]).descriptor, rax
	
	jmp @Exit
@Error:
	
	xor rax, rax
@Exit:

	add rsp, 28h
	pop rdi
	ret
AllocLongVal endp

FreeLongVal	proc descriptor:QWORD
	push rbx
	push rdi
	sub rsp, 28h
	
	mov rbx, (VALSET PTR global_set).val_count
	mov rdi, (VALSET PTR global_set).val_array
	xor rdx, rdx
@@:
	cmp rdx, rbx
	je @Error

	cmp qword ptr[rdi], 0
	je @Skip
	
	mov r8, qword ptr [rdi]
	cmp (longval PTR [r8]).descriptor, rcx
	je @Found
@Skip:

	add rdi, SIZEOF QWORD
	inc rdx
	jmp @B
	
@Found:
	mov rbx, rcx
	
	;free valptr
	mov rcx, DllHeapHandle
	xor rdx, rdx
	mov r8, rbx
	call HeapFree
	test rax, rax
	je @Error
	
	;free longval
	mov rcx, DllHeapHandle
	xor rdx, rdx
	mov r8, qword ptr[rdi]
	call HeapFree
	test rax, rax
	je @Error
	
	;move last
	mov rcx, (VALSET PTR global_set).val_count
	mov rdx, (VALSET PTR global_set).val_array
	lea rdx, [rdx + rcx * 8 - 8]
	mov rdx, qword ptr [rdx]
	mov qword ptr [rdi], rdx
	
	;realloc array
	cmp rcx, 10
	jbe @F
	
	mov r9, rcx
	dec r9
	shl r9, 3
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, (VALSET PTR global_set).val_array
	call HeapReAlloc
	test rax, rax
	je @Error
	mov (VALSET PTR global_set).val_array, rax
	dec (VALSET PTR global_set).val_count
	
@@:
	mov rax, rbx
	jmp @Exit

@Error:
	xor rax, rax

@Exit:

	add rsp, 28h
	pop rdi
	pop rbx
	ret
FreeLongVal endp

GetLongvalPtr proc desc:QWORD

	mov rax, (VALSET PTR global_set).val_count
	mov rdx, (VALSET PTR global_set).val_array
	xor r9, r9
@@:
	cmp r9, rax
	je @Error

	cmp qword ptr[rdx], 0
	je @Skip
	
	mov r8, qword ptr [rdx]
	cmp (longval PTR [r8]).descriptor, rcx
	je @Found
	
@Skip:
	add rdx, SIZEOF QWORD
	inc r9
	jmp @B

@Found:
	mov rax, r8
	jmp @Ret
	
@Error:
	xor rax, rax
	
@Ret:

	ret
GetLongvalPtr endp

END