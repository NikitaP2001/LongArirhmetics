include longval.inc
include main.inc

.code

UAddLongVal proc op1:QWORD, op2: QWORD
;	Add second operand to first, not change
;	sign qword BUT in case of sero result 
;	set sign to 0
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
	sub rsp, 28h
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
	
	add rsp, 28h
	pop r14
	pop r12
	pop r11
	pop rdi
	pop rsi
	ret
UAddLongVal endp

USubLongVal proc op1:QWORD, op2: QWORD
;	Sub second operand from first, not change
;	sign qword. First operand MUST be less 
;	than second by module.
;	ret: 
;		not a zero is case of success
;	Note: This function must not be called 
;	outside of this module
;--------------------------------------------------------
	LOCAL BFlags:BYTE
	
	push rsi
	push rdi
	push r11
	push r12
	push r14
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	;read op1 size
	mov rcx, op1
	call GetLongvalPtr
	test rax, rax
	mov rsi, rax
	je @Error
	mov r11, (longval PTR [rax]).val_size
	;case zero size
	test r11, r11
	je @Error
	
	;read op2 size
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	mov rdi, rax
	je @Error
	mov r12, (longval PTR [rax]).val_size
	;case zero size
	test r12, r12
	je @Error
	
	;len op2 > len op1
	cmp r12, r11
	ja @Error
	
	xor r14, r14
	clc
	lahf
	mov BFlags, ah

	;read op1 address
	mov rsi, (longval PTR [rsi]).val_ptr
	;case nullptr
	test rsi, rsi
	je @Error
	
	;read op2 address
	mov rdi, (longval PTR [rdi]).val_ptr
	;case nullptr
	test rdi, rdi
	je @Error
	
@do:
	
@if: ;sub op2 from op1
	cmp r14, r12
	jnb @elseif
	mov al, byte ptr[rdi + r14]
	mov ah, BFlags
	sahf
	sbb byte ptr[rsi + r14], al
	lahf
	mov BFlags, ah
	jmp @endif
	
@elseif: ;in case of end op2
	mov ah, BFlags
	sahf
	sbb byte ptr[rsi + r14], 0
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
	jnc @F
	
	;op1 > op2
	cmp r14, r11
	je @Error
	
	jmp @do
	
@@:
	;check zero result
	cmp r14, r11
	jne @F
	
	cmp byte ptr[rsi+r14-1], 0
	jne @F
	mov rcx, op1
	call GetLongvalPtr
	mov (longval ptr[rax]).val_sign, 0
	
@@:
	
	mov rcx, op1
	call CompactLongVal
	test rax, rax
	jz @Error
	
	or rax, 1
	jmp @F
	
@Error:
	mov eax, 0
	
@@:	
	
	add rsp, 28h
	pop r14
	pop r12
	pop r11
	pop rdi
	pop rsi
	ret
USubLongVal endp

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

AddLongVal proc op1:QWORD, op2: QWORD
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r11, rax
	
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r12, rax
	
	mov rax, (longval ptr[r11]).val_sign
	test rax, rax
	jne @op1lz
	
	mov rax, (longval ptr[r12]).val_sign
	test rax, rax
	jne @diffsign
	
@onesign:
	mov rcx, op1
	mov rdx, op2
	call UAddLongVal
	test rax, rax
	je @Error
	or rax, 1
	jmp @end
	
@op1lz: ;op1 < 0
	mov rax, (longval ptr[r12]).val_sign
	test rax, rax
	jne @onesign

@diffsign:
	;compare
	mov rcx, op1
	mov rdx, op2
	call UCmpLongVal
	test rax, rax
	jz @F
	
	;|op2| < |op1|
	mov rcx, op1
	mov rdx, op2
	call USubLongVal
	test rax, rax
	je @Error
	or rax, 1
	jmp @end
	
@@: ;|op2| >= |op1|
	mov rcx, op2
	mov rdx, op1
	call USubLongVal
	test rax, rax
	je @Error
	mov rcx, op1
	mov rdx, op2
	call XchgLongVal
	or rax, 1
	jmp @end
	
@Error:
	xor rax, rax

@end:
	add rsp, 28h
	ret
AddLongVal endp

XchgLongVal proc op1:QWORD, op2: QWORD
	push r10
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	call AllocLongVal
	test rax, rax
	je @Error
	mov r10, rax
	
	mov rcx, r10
	mov rdx, op1
	call MovLongVal
	test rax, rax
	je @Error
	
	mov rcx, op1
	mov rdx, op2
	call MovLongVal
	test rax, rax
	je @Error
	
	mov rcx, op2
	mov rdx, r10
	call MovLongVal
	test rax, rax
	je @Error
	
	mov rcx, r10
	call FreeLongVal
	test rax, rax
	je @Error
	
	or rax, 1
	jmp @end
	
@Error:
	xor rax, rax

@end:

	add rsp, 28h
	pop r10
	ret
XchgLongVal endp

MovLongVal proc dest:QWORD, source: QWORD
	sub rsp, 28h

	call UAddLongVal
	test rax, rax
	je @Error
	or rax, 1
	jmp @end
		
@Error:
	xor rax, rax
	
@end:

	add rsp, 28h
	ret
MovLongVal endp

UCmpLongVal proc op1:QWORD, op2:QWORD
	push r10
	push rbx
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	call AllocLongVal
	test rax, rax
	je @Error
	
	mov r10, rax
	
	mov rcx, r10
	mov rdx, op1
	call MovLongVal
	test rax, rax
	je @Error
	
	mov rcx, r10
	mov rdx, op2
	call USubLongVal
	mov rbx, rax
	
	mov rcx, r10
	call FreeLongVal
	test rax, rax
	je @Error
	
	mov rax, rbx
	jmp @end

@Error:
	xor rax, rax
	
@end:

	add rsp, 28h
	pop rbx
	pop r10
	ret
UCmpLongVal endp

CutLongVal proc dest:QWORD, p1:DWORD, p2:DWORD, tar:QWORD
	sub rsp, 28h
	mov dest, rcx
	mov p1, edx
	mov p2, r8d
	mov tar, r9


	add rsp, 28h
	ret
CutLongVal endp
	
END




