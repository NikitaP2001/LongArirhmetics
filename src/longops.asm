include longops.inc

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



END