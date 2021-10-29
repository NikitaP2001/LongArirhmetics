include ntdll.inc
include kernel32.inc
includelib ntdll.lib
includelib kernel32.lib

include longops.inc
include main.inc

.data

global_set VALSET <0, 0>

.code

LongValUnsignedAdd proc op1:QWORD, op2: QWORD
;	Add second operand to first, not change
;	sign qword
;	ret: 
;		not a zero is case of success
;	Note: This function must not be called 
;	outside of module
;--------------------------------------------------------
	LOCAL BFlags:BYTE
	
	push rsi
	push rdi
	push r11
	push r12
	push r14
	sub rsp, 30h
	mov op1, rcx
	mov op2, rdx
	
	;read op1 size
	mov rcx, op1
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r11, (longval PTR [rax]).val_size
	;case zero size
	test r11, r11
	je @Error
	
	;read op2 size
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r12, (longval PTR [rax]).val_size
	;case zero size
	test r12, r12
	je @Error
	
	xor r14, r14
	clc
	lahf
	mov BFlags, ah

	;read op1 address
	mov rcx, op1
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rsi, (longval PTR [rax]).val_ptr
	;case nullptr
	test rsi, rsi
	je @Error
	
	;read op2 address
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rdi, (longval PTR [rax]).val_ptr
	;case nullptr
	test rdi, rdi
	je @Error
	
@do:
	;check fisrt op for owfl
	cmp r14, r11
	jb @if
	inc r11
	mov rcx, op1
	mov rdx, r11
	call ReallocLongVal
	test rax, rax
	je @Error
	mov rsi, rax
	;write zero re-ted to memory
	add rax, r11
	dec rax
	mov byte ptr[rax], 0
	
@if: ;add op2 to op1
	cmp r14, r12
	jnb @elseif
	mov al, byte ptr[rdi + r14]
	mov ah, BFlags
	sahf
	adc byte ptr[rsi + r14], al
	lahf
	mov BFlags, ah
	jmp @endif
	
@elseif: ;in case of end op2
	mov ah, BFlags
	sahf
	adc byte ptr[rsi + r14], 0
	lahf
	mov BFlags, ah

@endif:

	inc r14
	cmp r14, r12
	jb @do
	mov ah, BFlags
	sahf
	lahf
	mov BFlags, ah
	jc @do
	
	or rax, 1
	jmp @F
	
@Error:
	mov eax, 0
	
@@:	
	
	add rsp, 30h
	pop r14
	pop r12
	pop r11
	pop rdi
	pop rsi
	ret
LongValUnsignedAdd endp

LongValUnsignedSub proc op1:QWORD, op2: QWORD
;	Add second operand to first, not change
;	sign qword
;	ret: 
;		not a zero is case of success
;	Note: This function must not be called 
;	outside of module
;--------------------------------------------------------
	LOCAL BFlags:BYTE
	
	push rsi
	push rdi
	push r11
	push r12
	push r14
	sub rsp, 30h
	mov op1, rcx
	mov op2, rdx
	
	;read op1 size
	mov rcx, op1
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r11, (longval PTR [rax]).val_size
	;case zero size
	test r11, r11
	je @Error
	
	;read op2 size
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r12, (longval PTR [rax]).val_size
	;case zero size
	test r12, r12
	je @Error
	
	xor r14, r14
	clc
	lahf
	mov BFlags, ah

	;read op1 address
	mov rcx, op1
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rsi, (longval PTR [rax]).val_ptr
	;case nullptr
	test rsi, rsi
	je @Error
	
	;read op2 address
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rdi, (longval PTR [rax]).val_ptr
	;case nullptr
	test rdi, rdi
	je @Error
	
@do:
	;check fisrt op for owfl
	cmp r14, r11
	jb @if
	inc r11
	mov rcx, op1
	mov rdx, r11
	call ReallocLongVal
	test rax, rax
	je @Error
	mov rsi, rax
	;write zero re-ted to memory
	add rax, r11
	dec rax
	mov byte ptr[rax], 0
	
@if: ;add op2 to op1
	cmp r14, r12
	jnb @elseif
	mov al, byte ptr[rdi + r14]
	mov ah, BFlags
	sahf
	adc byte ptr[rsi + r14], al
	lahf
	mov BFlags, ah
	jmp @endif
	
@elseif: ;in case of end op2
	mov ah, BFlags
	sahf
	adc byte ptr[rsi + r14], 0
	lahf
	mov BFlags, ah

@endif:

	inc r14
	cmp r14, r12
	jb @do
	mov ah, BFlags
	sahf
	lahf
	mov BFlags, ah
	jc @do
	
	or rax, 1
	jmp @F
	
@Error:
	mov eax, 0
	
@@:	
	
	add rsp, 30h
	pop r14
	pop r12
	pop r11
	pop rdi
	pop rsi
	ret
LongValUnsignedSub endp

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

IntToLongVal proc ival:DWORD, desc:QWORD
	push r10
	push rdi
	sub rsp, 28h
	mov ival, ecx
	mov desc, rdx

	;Descriptor to longval ptr
	mov rcx, rdx
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rdi, rax
	
	;store int's sign to longval
	mov (longval PTR [rdi]).val_sign, 0
	mov ecx, ival
	test ecx, ecx
	jns @F
	neg ival
	mov (longval PTR [rdi]).val_sign, 1
	
@@:
	mov r10, 4
	mov eax, ival
	rol eax, 8
	
@@:	;Calculate length
	test al, al
	jnz @F
	
	cmp r10, 1
	jz @F
	
	dec r10
	rol eax, 8
	jmp @B

@@:	;Change array size
	mov rdx, r10
	mov rcx, desc
	call ReallocLongVal
	
	;Store int in array
	mov rcx, (longval PTR [rdi]).val_ptr
	mov eax, ival
@@:	
	mov byte ptr[rcx], al
	shr rax, 8
	inc rcx
	dec r10
	jne @B
	
	or rax, 1	
	jmp @F
	
@Error:
	xor rax, rax
	
@@:
	add rsp, 28h
	pop rdi
	pop r10
	ret
IntToLongVal endp

ReallocLongVal proc desc:QWORD, new_size:QWORD
	push rdi
	push r10
	sub rsp, 28h
	mov new_size, rdx
	
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov rdi, rax
	
	mov rdx, new_size
	cmp rdx, 7FFF8h
	ja @Error

	mov (longval PTR [rdi]).val_size, rdx
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, (longval PTR [rdi]).val_ptr
	mov r9, rdx
	call HeapReAlloc
	test rax, rax
	je @Error
	
	jmp @F
	
@Error:
	xor rax, rax
@@:
	add rsp, 28h
	pop r10
	pop rdi
	ret
ReallocLongVal endp

END