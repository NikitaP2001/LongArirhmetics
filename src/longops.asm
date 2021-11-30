include ntdll.inc
includelib ntdll.lib
include kernel32.inc
includelib kernel32.lib

include longval.inc
include main.inc
include stdprocs.inc
include longops.inc

.code

align 16
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
        mov rsi, rax
	mov r11, (longval PTR [rax]).val_size
	;case zero size
	test r11, r11
	je @Error
	
	;read op2 size
	mov rcx, op2
	call GetLongvalPtr
	test rax, rax
	je @Error
        mov rdi, rax
	mov r12, (longval PTR [rax]).val_size
	;case zero size
	test r12, r12
	je @Error
	
	xor r14, r14
	clc
	lahf
	mov BFlags, ah

	;read op1 address	
	mov rsi, (longval PTR [rsi]).val_ptr
	
	;read op2 address
	mov rdi, (longval PTR [rdi]).val_ptr             

align 4	
@do:
	cmp r14, r11
	jb @if
	inc r11
	mov rcx, op1
	mov rdx, r11
	call ReallocLongVal
	test rax, rax
	je @Error
	mov rsi, rax
	add rax, r11
	dec rax
	mov byte ptr[rax], 0
	
@if:    ;add op2 to op1
	cmp r14, r12
	jnb @elseif
	mov al, byte ptr[rdi + r14]
	mov ah, BFlags
	sahf
	adc byte ptr[rsi + r14], al
	lahf
	mov BFlags, ah
	jmp @endif
	
@elseif: 
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
	push r11
	push r12
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx        
	
        mov rcx, op1
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
        stalloc
        mov r11, rax
        mov rcx, rax
        mov rdx, op2
        call MovLongVal
	mov rcx, r11
	mov rdx, op1
	call USubLongVal
	mov rcx, op1
        mov rdx, r11
        call MovLongVal
        stfree r11
	or rax, 1
	jmp @end
	
@Error:
	xor rax, rax

@end:
	add rsp, 28h
	pop r12
	pop r11
	ret
AddLongVal endp

AddLongValByMod proc op1:QWORD, op2: QWORD, opmod:QWORD
        push rsi
        push rdi
        push rbx
        sub rsp, 28h
        
        mov rdi, rcx
        mov rsi, rdx
        mov rbx, r8
        
        call AddLongVal
        
        stalloc 
        mov r10, rax
        
        mov rcx, r10
        mov rdx, rdi
        mov r8, rdi
        mov r9, rbx
        call DivideLongVal
        
        stfree r10
@Error:        
        add rsp, 28h
        pop rbx
        pop rdi
        pop rsi
        ret
AddLongValByMod endp

SubLongValByMod proc op1:QWORD, op2: QWORD, opmod:QWORD
        push rsi
        push rdi
        push rbx
        sub rsp, 28h
        
        mov rdi, rcx
        mov rsi, rdx
        mov rbx, r8
        
        call SubLongVal
        
        stalloc 
        mov r10, rax
        
        mov rcx, r10
        mov rdx, rdi
        mov r8, rdi
        mov r9, rbx
        call DivideLongVal
        
        stfree r10
@Error:        
        add rsp, 28h
        pop rbx
        pop rdi
        pop rsi
        ret
SubLongValByMod endp

MultLongValByMod proc op1:QWORD, op2: QWORD, opmod:QWORD
        push rsi
        push rdi
        push rbx
        sub rsp, 28h
        
        mov rdi, rcx
        mov rsi, rdx
        mov rbx, r8
        
        mov r8, rcx              
        call MultLongVal
        
        stalloc 
        mov r10, rax
        
        mov rcx, r10
        mov rdx, rdi
        mov r8, rdi
        mov r9, rbx
        call DivideLongVal
        
        stfree r10
@Error:        
        add rsp, 28h
        pop rbx
        pop rdi
        pop rsi
        ret
MultLongValByMod endp

DivLongValByMod proc result:QWORD, reminder:QWORD, op1:QWORD, op2:QWORD, opmod:QWORD
        push rsi
        push rdi
        push rbx
        sub rsp, 28h        
        
        mov rdi, rcx
        mov rsi, rdx
        mov rbx, opmod
                             
        call DivideLongVal
        
        stalloc 
        mov r10, rax
        
        mov rcx, r10
        mov rdx, rdi
        mov r8, rdi
        mov r9, rbx
        call DivideLongVal
        
        mov rcx, r10
        mov rdx, rsi
        mov r8, rsi
        mov r9, rbx
        call DivideLongVal
        
        stfree r10
@Error:        
        add rsp, 28h
        pop rbx
        pop rdi
        pop rsi
        ret
DivLongValByMod endp

LongValToPowerByMod proc desc:QWORD, power:QWORD, module:QWORD
        push rbx
        push rdi
        push r10
        sub rsp, 28h

        mov rdi, rcx
        mov rbx, r8

        call LongValToPower
        
        stalloc 
        mov r10, rax
        
        mov rcx, r10
        mov rdx, rdi
        mov r8, rdi
        mov r9, rbx
        call DivideLongVal
        
        stfree r10
@Error:       
        
        add rsp, 28h
        pop r10
        pop rdi
        pop rbx
        ret
LongValToPowerByMod endp

SubLongVal proc op1:QWORD, op2: QWORD
        push rbx
        push rsi
        push r10
        push r11
        sub rsp, 28h
        
        mov rbx, rcx
        mov r10, rdx
        
        mov rcx, rdx
        call GetLongvalPtr
        test rax, rax
        je @Error
        mov rsi, rax
        
        mov r11, (longval ptr[rax]).val_sign
        xor r11b, 1
        mov (longval ptr[rax]).val_sign, r11
        
        mov rcx, rbx
        mov rdx, r10
        call AddLongVal
        test rax, rax
        je @Error
        
        xor r11b, 1
        mov (longval ptr[rsi]).val_sign, r11
        
        or rax, 1
        jmp @end
@Error:
        xor rax, rax

@end:

        add rsp, 28h
        pop r11
        pop r10
        pop rsi
        pop rbx
        ret
SubLongVal endp

.code
XchgLongVal proc op1:QWORD, op2: QWORD
	push r10
        push rbx
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	stalloc
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

        stfree r10
	
	or rax, 1
	jmp @end
	
@Error:
	xor rax, rax

@end:

	add rsp, 28h
        pop rbx
	pop r10
	ret
XchgLongVal endp

.code

MovLongVal proc dest:QWORD, source: QWORD
        push r10
        push r11
	sub rsp, 30h
	mov dest, rcx
	mov source, rdx
	
	;check first for dest
	call GetLongvalPtr
	test rax, rax
	je @Error
        mov r10, rax
	
	mov rcx, source
	call GetLongvalPtr 
	test rax, rax
	je @Error
        mov r11, rax
	mov r8, (longval ptr[rax]).val_size
	dec r8
	
        ; mov val array
	xor rdx, rdx
	mov r9, source
	mov rcx, dest
	call CutLongVal
        
        ; mov sign
        mov rax, (longval ptr[r11]).val_sign
        mov (longval ptr[r10]).val_sign, rax

	or rax, 1
	jmp @end
		
@Error:
	xor rax, rax
	
@end:           
	add rsp, 30h
        pop r11
        pop r10
	ret
MovLongVal endp

UCmpLongVal proc op1:QWORD, op2:QWORD
	push r10
	push rbx
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
	
	stalloc	
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
	
	stfree r10
	
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

UCmpEqualLongVal proc op1:QWORD, op2: QWORD
        push r11
        push r12
        push rbx
        sub rsp, 28h
        mov r11, rcx
        mov r12, rdx        
        
        stalloc
        mov rbx, rax
        mov rcx, rax
        mov rdx, r11
        call MovLongVal       
        
        mov rcx, rbx
        mov rdx, r12                        
        call USubLongVal  
        test rax, rax
        je @False
        
        mov rcx, rbx
        call GetLongvalPtr
        mov rcx, (longval ptr[rax]).val_size
        
        cmp rcx, 1
        jne @False
        
        mov rax, (longval ptr[rax]).val_ptr
        cmp byte ptr[rax], 0
        jne @False
        
        or rax, 1
        jmp @end
@False:
@Error:
        xor rax, rax
@end:   
        stfree rbx
        
        add rsp, 28h
        pop rbx
        pop r12
        pop r11
        ret
UCmpEqualLongVal endp

CmpEqualLongVal proc op1:QWORD, op2:QWORD
        push r10
        push r11
        push rbx
        sub rsp, 28h
        
        mov r10, rcx
        mov r11, rdx
        
        call GetLongvalPtr
        mov rbx, (longval ptr[rax]).val_sign
        
        mov rcx, r11
        call GetLongvalPtr
        xor rbx, (longval ptr[rax]).val_sign
        
        test rbx, rbx
        jnz @False
     
        mov rcx, r10
        mov rdx, r11
        call UCmpEqualLongVal       
        
        jmp @end
@False:

@end:        
        add rsp, 28h
        pop rbx
        pop r11
        pop r10
        ret
CmpEqualLongVal endp

CmpLowerLongVal proc op1:QWORD, op2: QWORD
        push r10
        push r11
        sub rsp, 30h
        
        mov op1, rcx
        mov op2, rdx
        
        call GetLongvalPtr
        mov r10, rax
        
        mov rcx, op2
        call GetLongvalPtr
        mov r11, rax
        
        mov rcx, (longval ptr[r10]).val_sign
        mov rdx, (longval ptr[r11]).val_sign
        cmp rcx, 1
        je @F
                cmp rdx, 1
                je @1
                        ; both be zero
                        mov rcx, op1
                        mov rdx, op2
                        call UCmpLongVal
                        test rax, rax
                        sete cl
                        movzx rax, cl
                        jmp @end                
        @1:
                        ; op1 >= 0 op2 < 0
                        jmp @False
@@:     
                cmp rdx, 1
                je @2
                        ; op1 < 0 op2 >= 0
                        jmp @True
        @2:        
                        ; op1 < 0 op2 < 0
                        mov rcx, op2
                        mov rdx, op1
                        call UCmpLongVal
                        test rax, rax
                        sete cl
                        movzx rax, cl
                        jmp @end       
@False:
        xor rax, rax
        jmp @end
@True:        
        or rax, 1
        jmp @end
@end:
        add rsp, 30h
        pop r11
        pop r10
        ret
CmpLowerLongVal endp

CutLongVal proc dest:QWORD, p1:QWORD, p2:QWORD, source:QWORD
;	Copies part of source from p1 pos to p2 pos to
;	dest. Error checking must be done outside
;		@dest -	logval for insert bytes to
;		@p1 - from which byte start copy,
;		expects to be >= 0 , < p2 and < source len
;		@p3	- to which byte copy, expects to
;		be >= 0 and < source len
;		@source - lonval to copy bytes from
;	This function must not be exported or used
;	outside of this module
;------------------------------------------------
	push rsi
	push rdi
	sub rsp, 28h        
	mov dest, rcx
	mov p1, rdx
	mov p2, r8
	mov source, r9        	
	
	mov rcx, source
	call GetLongvalPtr
	mov rsi, (longval ptr[rax]).val_ptr
	add rsi, p1
	
	mov rdx, p2
	sub rdx, p1
	inc rdx
	mov rcx, dest
	call ReallocLongVal	
        
        mov rcx, dest
        call GetLongvalPtr
	mov rdi, (longval ptr[rax]).val_ptr
        
	mov rcx, p2
	sub rcx, p1
	inc rcx	
        cld
	rep movsb        	
        
	mov rcx, dest
	call CompactLongVal       
                
	add rsp, 28h
	pop rdi
	pop rsi
	ret
CutLongVal endp

ShiftLongVal proc desc:QWORD, shift:QWORD
;       Makes logical right shift of
;       longval value
;       Expects valid longval descriptor
;------------------------------
        push rbx
        push r11
        push r12
        push r13
        push rdi
        push rsi
        sub rsp, 28h
        mov r11, rcx
        mov r12, rdx
        call GetLongvalPtr
        mov rbx, rax
        
        mov rcx, r11
        mov r13, (longval ptr[rax]).val_size
        mov rdx, r13
        add rdx, r12
        call ReallocLongVal
        
        mov rdi, (longval ptr[rbx]).val_ptr
        mov rcx, r13
        lea rdi, [rdi+rcx-1]
        mov rsi, rdi
        add rdi, r12
        
        std
        rep movsb
        
        mov rdi, (longval ptr[rbx]).val_ptr
        mov rcx, r12
        xor rax, rax
        cld
        rep stosb
            
        add rsp, 28h
        pop rsi
        pop rdi
        pop r13
        pop r12
        pop r11
        pop rbx
        ret
ShiftLongVal endp

MultLongVal proc dest:QWORD, op1:QWORD, op2: QWORD
        push rdi
        push rsi
        push r10
        push r11
	sub rsp, 40h
        mov dest, rcx
	mov op1, rdx
	mov op2, r8   
        
	;get op1 ptr
        mov rcx, rdx
	call GetLongvalPtr
	test rax, rax
        mov r10, rax
	je @Error          
        
        ;get dest ptr
        mov rcx, dest
	call GetLongvalPtr
	test rax, rax
        mov r11, rax
	je @Error
        
        ;get op2 ptr
	mov rcx, op2
	call GetLongvalPtr       
	test rax, rax
	je @Error
        
        ;set destination op sign
        mov rcx, (longval ptr[r10]).val_sign
        mov rdx, (longval ptr[rax]).val_sign
        xor rcx, rdx                      
        mov r10, rcx
        mov (longval ptr[r11]).val_sign, 0              
       
        mov rcx, dest
        mov rdx, op1
        mov r8, op2
	call MultLongValInternal
	test rax, rax
	je @Error
        
        ;restore dest sign
        mov (longval ptr[r11]).val_sign, r10       
	
	or rax, 1
	jmp @end
	
@Error:
	xor rax, rax

@end:

	add rsp, 40h
        pop r11
        pop r10
        pop rsi
        pop rdi
	ret
MultLongVal endp

DoubleToLongVal proc dval:QWORD, desc:QWORD
        ibuf EQU dword ptr[rbp-8]
        push rbx
        push rsi
        push rdi
        sub rsp, 30h
        movsd dval, xmm0
        
        mov rcx, rdx
        mov rdi, rcx
        call GetLongvalPtr
        test rax, rax
        je @Error
        mov rbx, rax
        
        fld dval
        fldz        
        fcomp
        fstsw ax
        fwait
        sahf
        jb @F
        
        fchs 
        mov (longval ptr[rbx]).val_sign, 1             
@@:       

        sub rcx, rcx
        mov rdx, rdi
        call IntToLongVal
        
        ; initilize multiplier
        call AllocLongVal
        mov rsi, rax
        
        mov ibuf, 07FFFFFFFh ; max int valu
        
        fild ibuf
        fcomp
        fstsw ax
        fwait
        sahf
        jbe @F
        
        fistp ibuf
        
        mov ecx, ibuf
        mov rdx, rsi
        call IntToLongVal
        
        mov rcx, rdi
        mov rdx, rsi
        call AddLongVal
        
        mov rcx, rsi
        call FreeLongVal
        
        jmp @end
@@:        
        mov rcx, 07FFFFFFFh
        mov rdx, rsi
        call IntToLongVal  
        
        mov rcx, 1
        mov rdx, rdi
        call IntToLongVal

@@:     
        fild ibuf
        fcomp
        fstsw ax
        sahf
        ja @mulfpu       
        
        mov rcx, rdi
        mov rdx, rdi
        mov r8, rsi
        call MultLongVal
        
        fidiv ibuf
        
        jmp @B 
        
@mulfpu:
        fistp ibuf
        
        mov ecx, ibuf
        mov rdx, rsi
        call IntToLongVal
        
        mov rcx, rdi
        mov rdx, rdi
        mov r8, rsi
        call MultLongVal
        
        mov rcx, rsi
        call FreeLongVal
        
        or rax, 1
        jmp @end
        
@Error:
        xor rax, rax
@end:

        add rsp, 30h
        pop rdi
        pop rsi
        pop rbx
        ret
DoubleToLongVal endp

DivideLongVal proc result:QWORD, reminder:QWORD, op1:QWORD, op2:QWORD
        push rdi
        push rsi   
        push r10
        sub rsp, 28h
        mov result, rcx
        mov reminder, rdx
        mov op1, r8
        mov op2, r9
        stalloc
        mov r10, rax
        
        mov rcx, r10
        mov rdx, op1
        call MovLongVal
        
        ; calculate result sign
        mov rcx, op1
        call GetLongvalPtr
        test rax, rax
        je @Error
        
        mov rsi, (longval ptr[rax]).val_sign
        
        mov rcx, op2
        call GetLongvalPtr
        test rax, rax
        je @Error
        
        mov rdi, (longval ptr[rax]).val_sign
        
        xor rsi, rdi                
        
        mov rcx, result
        mov rdx, reminder
        mov r8, op1
        mov r9, op2        
        call UDivideLongVal
        
        mov rcx, op1
        mov rdx, r10 
        call MovLongVal
        
        ; store sign in res and reminder
        mov rcx, result
        call GetLongvalPtr
        mov (longval ptr [rax]).val_sign, rsi
        
        mov rcx, reminder
        call GetLongvalPtr
        mov (longval ptr [rax]).val_sign, rsi
        
        or rax, 1
        jmp @end
@Error:        
        xor rax, rax
@end:        
        stfree r10
        add rsp, 28h
        pop r10
        pop rsi
        pop rdi
        ret
DivideLongVal endp

UDivideLongVal proc result:QWORD, reminder:QWORD, op1:QWORD, op2:QWORD
        push rsi
        push rdi
        push r10
        push r11
        push r12
        push r13
        sub rsp, 28h
        mov result, rcx
        mov reminder, rdx
        mov op1, r8
        mov op2, r9

        ; A < B 
        mov rcx, op1
	mov rdx, op2
	call UCmpLongVal
	test rax, rax
	jnz @F   ; return A as reminder
                xor rcx, rcx
                mov rdx, result
                call IntToLongVal
                
                mov rcx, reminder
                mov rdx, op1
                call MovLongVal
                
                jmp @end        
@@:        
        ; calculate length of shift
        mov rcx, op1
        call GetLongvalPtr
        mov r11, rax
        mov rdi, (longval ptr[rax]).val_size
        
        mov rcx, op2
        call GetLongvalPtr
        mov r12, rax
        mov rsi, (longval ptr[rax]).val_size
        
        sub rdi, rsi
        
        stalloc         ; B0 = B
        mov r10, rax
        mov rcx, rax
        mov rdx, op2
        call MovLongVal
        
        ; shift B0
        mov rcx, r10
        mov rdx, rdi
        call ShiftLongVal
        
        mov rax, (longval ptr[r11]).val_ptr
        mov rcx, (longval ptr[r11]).val_size
        lea rax, [rax+rcx-1]
        movzx r13, byte ptr[rax]
        
        ; A < B0 
        mov rcx, op1
	mov rdx, r10
	call UCmpLongVal
	test rax, rax
	jnz @F   ; shift B by length of shift - 1
                mov rcx, r10
                mov rdx, op2
                call MovLongVal                
                dec rdi
                mov rcx, r10
                mov rdx, rdi
                call ShiftLongVal    
                
                mov rax, (longval ptr[r11]).val_ptr
                mov rcx, (longval ptr[r11]).val_size
                lea rax, [rax+rcx-2]
                movzx r13, byte ptr[rax+1]
                shl r13, 8
                mov r13b, byte ptr[rax]
@@:        
        ; aprocimate divide       
        mov rax, (longval ptr[r12]).val_ptr
        mov rcx, (longval ptr[r12]).val_size
        lea rax, [rax+rcx-1]
        movzx r8, byte ptr[rax]
        inc r8
                
        mov rax, r13
        xor rdx, rdx
        div r8w
        movzx rsi, ax
        
        stalloc
        mov r13, rax
        stalloc
        mov r14, rax
        
        mov rcx, r13
        mov rdx, r10
        call MovLongVal
        
        mov rcx, rsi
        mov rdx, r14
        call IntToLongVal
        
        mov rcx, r13
        mov rdx, r13
        mov r8, r14
        call MultLongValInternal                
        
        mov rcx, op1
        mov rdx, r13
        call USubLongVal
        
        stfree r13
        stfree r14
                
@@:                
        mov rcx, op1
        mov rdx, r10
        call UCmpLongVal
        test rax, rax
        jz @F
                inc rsi
                ; A - B0
                mov rcx, op1
                mov rdx, r10
                call USubLongVal                                
        jmp @B
               
@@:                   
        mov rcx, rsi
        mov rdx, result
        call IntToLongVal
        
        test rdi, rdi
        jz @F        
                mov rcx, result
                mov rdx, rdi
                call ShiftLongVal
@@:                                             
       
        mov rcx, r10
        mov rdx, reminder
        mov r8, op1
        mov r9, op2
        call UDivideLongVal
        
        mov rcx, result
        mov rdx, r10
        call UAddLongVal

        stfree r10
                
        or rax, 1
        jmp @end
@Error:    
        xor rax, rax
    
@end:        
        add rsp, 28h
        pop r13
        pop r12
        pop r11
        pop r10
        pop rdi
        pop rsi
        ret
UDivideLongVal endp

align 16
MultLV2Byte proc desc:QWORD, op:QWORD   
        push rdi
        push r10
        push r11
        push r12
        sub rsp, 28h
        mov r11, rcx
        mov r12, rdx
        
        call GetLongvalPtr
        
        mov r10, (longval ptr[rax]).val_size        
        inc r10
        
        mov rcx, r11
        mov rdx, r10
        call ReallocLongVal
        
        mov rcx, r11
        call GetLongvalPtr
        mov rdi, (longval ptr[rax]).val_ptr
        
        xor rcx, rcx
align 4
@@:             
        mov al, byte ptr[rdi]
        mul r12b
        add ax, cx
        mov byte ptr[rdi], al
        movzx ecx, ah
               
        inc rdi
        dec r10
        jnz @B
        
        mov rcx, r11
        call CompactLongVal
        
        add rsp, 28h
        pop r12
        pop r11
        pop r10
        pop rdi
        ret        
MultLV2Byte endp

MultLongValInternal proc dest:QWORD, op1:QWORD, op2:QWORD
        push rbx
        push rdi
        push r10
        push r11
        push r12
        sub rsp, 28h
        mov dest, rcx
        mov op1, rdx
        mov op2, r8

        mov rcx, op2
        call GetLongvalPtr
        mov rbx, (longval ptr[rax]).val_size
        mov rdi, (longval ptr[rax]).val_ptr               
        
        ; buffer for reuslt
        stalloc
        mov r12, rax
        xor rcx, rcx
        mov rdx, r12
        call IntToLongVal
        
        stalloc
        mov r10, rax
        
        xor r11, r11
@@:        
        cmp r11, rbx
        je @F
                mov rcx, r10
                mov rdx, op1
                call MovLongVal
                
                mov rcx, r10
                mov rdx, r11
                call ShiftLongVal
                
                mov rcx, r10
                movzx rdx, byte ptr[rdi+r11]
                call MultLV2Byte
                
                mov rcx, r12
                mov rdx, r10
                call UAddLongVal
                
                inc r11
                jmp @B
@@:                
        mov rcx, dest
        mov rdx, r12
        call MovLongVal
          
        stfree r10
        stfree r12
        
        or rax, 1
        jmp @end
@Error:
        xor rax, rax
@end:
        add rsp, 28h
        pop r12
        pop r11
        pop r10
        pop rdi
        pop rbx
        ret
MultLongValInternal endp

LongValToPower proc desc:QWORD, power:QWORD
        push rbx
        push rsi
        push rdi
        sub rsp, 28h

        mov rbx, rdx
        mov rdi, rcx
        
        test rbx, rbx
        jnz @F
                mov rcx, 1
                mov rdx, rdi
                call IntToLongVal
                jmp @end
@@:     
        stalloc
        mov rsi, rax
        mov rcx, rsi
        mov rdx, rdi
        call MovLongVal
        
        dec rbx
@@:        
        test rbx, rbx
        je @end
        dec rbx
        
        mov rcx, rdi
        mov rdx, rdi
        mov r8, rsi
        call MultLongVal
        
        jmp @B
@Error:
        
@end:
        add rsp, 28h
        pop rdi
        pop rsi
        pop rbx
        ret
LongValToPower endp

LongValSquareRoot proc result:QWORD, operand:QWORD
lvquotient      EQU qword ptr[rbp-10h]
lvreminder      EQU qword ptr[rbp-18h]
lvselling       EQU qword ptr[rbp-20h]
lvfloor         EQU qword ptr[rbp-28h]
lvdivisor       EQU qword ptr[rbp-30h]
        push r10
        sub rsp, 58h
        mov result, rcx
        mov operand, rdx

        stalloc 
        mov lvselling, rax
        
        mov rcx, rax
        mov rdx, operand
        call MovLongVal
        
        stalloc
        mov lvfloor, rax
        xor rcx, rcx
        mov rdx, rax
        call IntToLongVal        
        
        stalloc
        mov lvquotient, rax
        stalloc
        mov lvreminder, rax
        
        ; 2 for divisor
        stalloc
        mov lvdivisor, rax
        mov rcx, 2
        mov rdx, rax
        call IntToLongVal
        
        mov rcx, lvquotient
        mov rdx, lvselling
        call MovLongVal
        
        stalloc
        mov r10, rax
@@:     

        mov rcx, lvquotient
        mov rdx, operand
        call checksquareroot
        test rax, rax
        jne @end  

        mov rcx, r10
        mov rdx, lvselling
        call MovLongVal
        
        mov rcx, r10
        mov rdx, lvfloor
        call UAddLongVal     

        mov rcx, lvquotient
        mov rdx, lvreminder
        mov r8, r10
        mov r9, lvdivisor
        call DivLongValByMod                    
        
        mov rcx, r10
        mov rdx, lvquotient
        call MovLongVal
        
        mov rcx, r10
        mov rdx, 2
        call LongValToPower        
        
        mov rcx, operand
        mov rdx, r10
        call UCmpLongVal
        test rax, rax
        jne @smaller
                
                mov rcx, lvselling
                mov rdx, lvquotient                        
                call MovLongVal
                jmp @B
@smaller:        
                mov rcx, lvfloor
                mov rdx, lvquotient
                call MovLongVal
                jmp @B
        
@Error:
@end:
        mov rcx, result
        mov rdx, lvquotient
        call MovLongVal
        
        mov rax, lvquotient
        stfree rax
        mov rax, lvdivisor
        stfree rax
        mov rax, lvreminder
        stfree rax
        mov rax, lvselling
        stfree rax
        mov rax, lvfloor
        stfree rax
        stfree r10
        
        add rsp, 58h
        pop r10
        ret
LongValSquareRoot endp

checksquareroot proc root:QWORD, xval:QWORD        
        push rbx
        push r10
        push r11
        push r12
        sub rsp, 28h
        
        mov rbx, rcx
        mov r10, rdx
        
        stalloc
        mov r11, rax
        
        stalloc
        mov r12, rax
        
        mov rcx, r11
        mov rdx, rbx
        call MovLongVal
        
        mov rcx, r11
        mov rdx, 2
        call LongValToPower
        
        mov rcx, r10
        mov rdx, r11
        call UCmpLongVal
        test rax, rax
        je @False
        
        mov rcx, r11
        mov rdx, rbx
        call MovLongVal        
        
        mov rcx, 1
        mov rdx, r12
        call IntToLongVal
        
        mov rcx, r11
        mov rdx, r12
        call UAddLongVal
        
        mov rcx, r11
        mov rdx, 2
        call LongValToPower
        
        mov rcx, r10
        mov rdx, r11
        call UCmpLongVal
        test rax, rax
        jne @False
        
        or rax, 1
        jmp @end
@Error:        
@False:
        xor rax, rax
@end:    
        stfree r11
        stfree r12
    
        add rsp, 28h
        pop r12
        pop r11
        pop r10
        pop rbx
        ret
checksquareroot endp    

InverseByMult proc aval:QWORD, bval:QWORD, xcoff:QWORD
lvold_r         EQU     qword ptr[rbp-10h]
lvold_s         EQU     qword ptr[rbp-18h]
lvold_t         EQU     qword ptr[rbp-20h]
lvr             EQU     qword ptr[rbp-28h]
lvs             EQU     qword ptr[rbp-30h]
lvt             EQU     qword ptr[rbp-38h]
lvprov          EQU     qword ptr[rbp-40h]
lvzero          EQU     qword ptr[rbp-48h]
lvquotient      EQU     qword ptr[rbp-50h]         
lvmult          EQU     qword ptr[rbp-58h]  
        sub rsp, 80h   
        mov aval, rcx
        mov bval, rdx
        mov xcoff, r8
        stalloc
        mov lvold_r, rax
        stalloc
        mov lvold_s, rax
        stalloc
        mov lvold_t, rax
        stalloc
        mov lvr, rax
        stalloc
        mov lvs, rax
        stalloc
        mov lvt, rax
        stalloc
        mov lvprov, rax
        stalloc
        mov lvzero, rax  
        stalloc
        mov lvquotient, rax
        stalloc
        mov lvmult, rax

        xor rcx, rcx
        mov rdx, lvzero
        call IntToLongVal
        
        mov rcx, lvold_r
        mov rdx, aval
        call MovLongVal
        mov rcx, lvr
        mov rdx, bval
        call MovLongVal                
        
        mov rcx, 1
        mov rdx, lvold_s
        call IntToLongVal
        mov rcx, 0
        mov rdx, lvs
        call IntToLongVal
        
        mov rcx, 0
        mov rdx, lvold_t
        call IntToLongVal
        mov rcx, 1
        mov rdx, lvt
        call IntToLongVal               
@@:        

        mov rcx, lvr
        mov rdx, lvzero
        call CmpEqualLongVal
        test rax, rax
        jne @F      
        
                mov rcx, lvquotient
                mov rdx, lvprov
                mov r8, lvold_r
                mov r9, lvr
                call DivideLongVal 
                
                mov rcx, lvprov
                mov rdx,  lvr
                call MovLongVal                
                mov rcx, lvmult
                mov rdx, lvquotient
                mov r8, lvprov
                call MultLongVal                
                mov rcx,lvold_r
                mov rdx, lvmult
                call SubLongVal
                mov rcx, lvr
                mov rdx, lvold_r
                call MovLongVal
                mov rcx, lvold_r
                mov rdx, lvprov
                call MovLongVal                
                
                mov rcx, lvprov
                mov rdx,  lvs
                call MovLongVal
                mov rcx, lvmult
                mov rdx, lvquotient
                mov r8, lvprov
                call MultLongVal
                mov rcx, lvold_s                
                mov rdx, lvmult
                call SubLongVal
                mov rcx, lvs
                mov rdx, lvold_s
                call MovLongVal
                mov rcx, lvold_s
                mov rdx, lvprov
                call MovLongVal               
                
                mov rcx, lvprov
                mov rdx,  lvt
                call MovLongVal
                mov rcx, lvmult
                mov rdx, lvquotient
                mov r8, lvprov
                call MultLongVal
                mov rcx,lvold_t
                mov rdx, lvmult
                call SubLongVal
                mov rcx, lvt
                mov rdx, lvold_t
                call MovLongVal
                mov rcx, lvold_t
                mov rdx, lvprov
                call MovLongVal
                
                jmp @B
@@:       
        mov rcx, xcoff
        mov rdx, lvold_s
        call MovLongVal 
        mov rcx, xcoff
        mov rdx, lvzero
        call CmpLowerLongVal
        test rax, rax
        jz @end
                mov rcx, xcoff
                mov rdx, bval
                call AddLongVal        
@Error:  
@end:
        mov rax, lvold_r
        stfree rax
        mov rax, lvold_s
        stfree rax
        mov rax, lvold_t
        stfree rax
        mov rax, lvr
        stfree rax
        mov rax, lvs
        stfree rax
        mov rax, lvt
        stfree rax
        mov rax, lvprov
        stfree rax
        mov rax, lvzero
        stfree rax
        mov rax, lvquotient
        stfree rax        
        mov rax, lvmult
        stfree rax
        add rsp, 80h
        ret
InverseByMult endp

SolveCongruences proc result:QWORD, psys:PTR QWORD, count:QWORD
lvvecMi         EQU qword ptr[rbp-28h]
temp            EQU qword ptr[rbp-30h]
lvM             EQU qword ptr[rbp-38h]
reminder        EQU qword ptr[rbp-40h]
        push rbx
        push rsi
        push rdi
        push r10
        sub rsp, 60h
        mov result, rcx
        mov psys, rdx
        mov count, r8

        ; for Mi vector
        mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
        mov r8, count
        shl r8, 3
        call HeapAlloc
        mov lvvecMi, rax

        stalloc
        mov reminder, rax
        stalloc
        mov temp, rax
        ; for m - value
        stalloc
        mov lvM, rax
        
        mov rcx, 1
        mov rdx, lvM
        call IntToLongVal
        
        ; calculate M and preallocate longvals for Mi-s
        mov rbx, count
        mov rdi, psys
        mov r10, lvvecMi
@@:     
                mov rcx, lvM
                mov rdx, lvM
                mov r8, qword ptr[rdi+8h]
                call MultLongVal                 

                ; allocate for Mi
                call AllocLongVal
                mov qword ptr[r10], rax                                                
                
                add r10, 8h
                add rdi, 10h
                dec rbx
                jne @B      
        
        ; calculate Mi-s
        mov rbx, count
        mov rdi, lvvecMi
        mov rsi, psys
@@:
                mov rcx, qword ptr[rdi]
                mov rdx, temp
                mov r8, lvM
                mov r9, qword ptr[rsi+8h]
                call DivideLongVal
                add rsi, 10h
                add rdi, 8h
                dec rbx
                jne @B
                
        xor rcx, rcx
        mov rdx, result
        call IntToLongVal
        
        ; finally calculate x
        mov rbx, count
        mov rsi, lvvecMi
        mov r10, psys
@@:             
                
                mov rcx, qword ptr[rsi]    ; Mi
                mov rdx, qword ptr[r10+8h] ; by mod ai
                mov r8, temp
                call InverseByMult                 

                mov rcx, temp
                mov rdx, qword ptr[rsi]
                mov r8, temp
                call MultLongVal
                
                mov rcx, temp
                mov rdx, qword ptr[r10]
                mov r8, temp
                call MultLongVal
                
                mov rcx, result
                mov rdx, temp
                call AddLongVal                
                
                add r10, 10h
                add rsi, 8h
                dec rbx
                jne @B
        
        mov rcx, temp
        mov rdx, reminder
        mov r8, result
        mov r9, lvM
        call DivideLongVal
        mov rcx, result
        mov rdx, reminder
        call MovLongVal
        
@Error:
@end:        
        mov rax, temp
        stfree rax
        mov rax, lvM
        stfree rax
        mov rax, reminder
        stfree rax    
        
        mov rbx, count
        mov rdi, lvvecMi
@@:        
                mov rcx, qword ptr[rdi]                
                call FreeLongVal
                
                add rdi, 8
                dec rbx
                jne @B
                
        mov rcx, DllHeapHandle
	xor rdx, rdx
        mov r8, lvvecMi
        call HeapFree

        add rsp, 60h
        pop r10
        pop rdi
        pop rsi
        pop rbx
        ret
SolveCongruences endp

END




