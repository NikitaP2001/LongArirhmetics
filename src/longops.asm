include longval.inc
include main.inc
include stdprocs.inc
include longops.inc

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
	push r11
	push r12
	sub rsp, 28h
	mov op1, rcx
	mov op2, rdx
        
        mov rcx, op1
        call CompactLongVal
        
        mov rcx, op2
        call CompactLongVal
	
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
	pop r12
	pop r11
	ret
AddLongVal endp

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

MovLongVal proc dest:QWORD, source: QWORD
	sub rsp, 28h
	mov dest, rcx
	mov source, rdx
	
	;check first for dest
	call GetLongvalPtr
	test rax, rax
	je @Error
	
	mov rcx, source
	call GetLongvalPtr 
	test rax, rax
	je @Error
	mov r8, (longval ptr[rax]).val_size
	dec r8
	
        
	xor rdx, rdx
	mov r9, source
	mov rcx, dest
	call CutLongVal

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

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

align 16
CmpZeroLongVal proc desc:QWORD
; Dont export !
; Only for module-internal use
; Return:
;       eax - true / false
;-------------------------------
        push rbp
        mov rbp, rsp
        and rsp, -10h
        push rdi
        sub rsp, 28h
        
        call GetLongvalPtr
        mov rdi, (longval ptr[rax]).val_ptr
        mov rcx, (longval ptr[rax]).val_size
        
        xor rax, rax        
        repe scasb
        
        test rcx, rcx
        sete al       

        add rsp, 28h
        pop rdi
        leave
        ret
CmpZeroLongVal endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

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

PartialMultLongVal proc dest:QWORD,
                        op1:QWORD,
                        op2:QWORD,
                        p1:QWORD,
                        p2:QWORD,
                        p3:QWORD,
                        p4:QWORD
	push r14
        push r13
        push r12
        push r11
        push r10
        push rsi
        push rdi
        push rbx
	sub rsp, 58h
        mid1 EQU qword ptr[rsp+38h]
        mid2 EQU qword ptr[rsp+40h]
        mid3 EQU qword ptr[rsp+48h]
        mid4 EQU qword ptr[rsp+50h]
        
	mov dest, rcx
	mov op1, rdx
	mov op2, r8
	mov p1, r9
	
	cmp r9, p2      ;impossible to devide than multimly
	jne @F
                mov rax, p3
                cmp rax, p4
                jne @F
                
                ;get longval op1 ptr
                mov rcx, op1
                call GetLongvalPtr
                mov r11, rax
                
                ;get longval op2 ptr
                mov rcx, op2
                call GetLongvalPtr
                mov r12, rax
                
                mov rsi, (longval ptr[r11]).val_ptr
                mov rdi, (longval ptr[r12]).val_ptr
                
                add rsi, p1
                add rdi, p3
                movzx rax, byte ptr[rsi]
                mul byte ptr[rdi]
                
                mov rcx, rax
                mov rdx, dest
                call IntToLongVal
                
                or rax, 1
                jmp @end
                
@@:                
        ;check zero case ops        
        mov rcx, rdx
        call CmpZeroLongVal
        test rax, rax 
        jne @retzero
                mov rcx, op2
                call CmpZeroLongVal
                test rax, rax
                je @F        
@retzero:
        xor rcx, rcx
        mov rdx, dest
        call IntToLongVal
        or rax, 1
        jmp @end
@@:
        
        
        ;Try to devide op1 by half
        mov rax, p1
        mov mid1, rax   ;Initilize middle pointer
        mov mid2, rax
        cmp rax, p2
        je @F
        add rax, p2
        shr rax, 1
        mov mid1, rax
        inc rax
        mov mid2, rax
        
@@:     ;Try to devide op2 by half
        mov rax, p3
        mov mid3, rax    ;Initilize middle pointer
        mov mid4, rax
        cmp rax, p4     
        je @F
        add rax, p4
        shr rax, 1
        mov mid3, rax
        inc rax
        mov mid4, rax
        
@@:
        stalloc
        mov r10, rax
        
        mov rcx, rax
        mov rdx, op1
        mov r8, op2
        mov r9, p1
        mov rax, mid1
        mov qword ptr[rsp+20h], rax
        mov rax, p3
        mov qword ptr[rsp+28h], rax
        mov rax, mid3
        mov qword ptr[rsp+30h], rax
        call PartialMultLongVal   ; C = w * y
        
        stalloc
        mov r11, rax
        
        mov rcx, rax
        mov rdx, op1
        mov r8, op2
        mov r9, mid2
        mov rax, p2
        mov qword ptr[rsp+20h], rax
        mov rax, mid4
        mov qword ptr[rsp+28h], rax
        mov rax, p4
        mov qword ptr[rsp+30h], rax
        call PartialMultLongVal   ; D = x * z
        
        stalloc
        mov r12, rax
        
        mov rcx, rax
        mov rdx, p1
        mov r8, mid1
        mov r9, op1
        call CutLongVal ; get w
        
        stalloc
        mov r13, rax
        
        mov rcx, rax
        mov rdx, mid2
        mov r8, p2
        mov r9, op1
        call CutLongVal ; get x
        
        mov rcx, r12
        mov rdx, r13
        call AddLongVal ; w + x
        
        mov rcx, r13
        mov rdx, p3
        mov r8, mid3
        mov r9, op2
        call CutLongVal ; get y
        
        stalloc
        mov r14, rax
        
        mov rcx, r14
        mov rdx, mid4
        mov r8, p4
        mov r9, op2
        call CutLongVal ; get z
        
        mov rcx, r13
        mov rdx, r14
        call AddLongVal ; x + z
        
        mov rcx, r14    ; dest
        mov rdx, r12    ; op1
        mov r8, r13     ; op2
        call MultLongVal    ; (w + x) * (y + z) 
        
        mov rcx, r14
        mov rdx, r10
        call SubLongVal
        
        mov rcx, r14
        mov rdx, r11
        call SubLongVal ; E = (w + x) * (y + z) - C - D
        
        mov rbx, p2
        inc rbx
        sub rbx, p1     ; m = n / 2
        shr rbx, 1
        
        mov rcx, r14
        mov rdx, rbx
        call ShiftLongVal ; E * 100^m
        
        mov rcx, r11
        imul rdx, rbx, 2
        call ShiftLongVal ; D * 100^2m
        
        mov rcx, dest
        mov rdx, r10
        call MovLongVal
        
        mov rcx, dest
        mov rdx, r14
        call AddLongVal
        
        mov rcx, dest
        mov rdx, r11
        call AddLongVal
        
        stfree r10
        stfree r11
        stfree r12
        stfree r13
        stfree r14
        
        or rax, 1
        jmp @end
       
@Error:
        xor rax, rax
        
@end:

	add rsp, 58h
        pop rbx
	pop rdi
	pop rsi
	pop r10
	pop r11
        pop r12
        pop r13
        pop r14
	ret
PartialMultLongVal endp

MultLongVal proc dest:QWORD, op1:QWORD, op2: QWORD
        push rdi
        push rsi
        push r10
        push r11
	sub rsp, 40h
        mov dest, rcx
	mov op1, rdx
	mov op2, r8   
        
	;get op1 end pos
        mov rcx, rdx
	call GetLongvalPtr
	test rax, rax
        mov r10, rax
	je @Error
	mov rdi, (longval ptr[r10]).val_size             
        
        ;checl dest op
        mov rcx, dest
	call GetLongvalPtr
	test rax, rax
        mov r11, rax
	je @Error
        
        ;get op2 end pos
	mov rcx, op2
	call GetLongvalPtr       
	test rax, rax
	je @Error
	mov rsi, (longval ptr[rax]).val_size
        
        ;set destination op sign
        mov rcx, (longval ptr[r10]).val_sign
        mov rdx, (longval ptr[rax]).val_sign
        xor rcx, rdx                      
        mov r10, rcx
        mov (longval ptr[r11]).val_sign, 0        
        
        cmp rdi, rsi    ; make ops the same size
                setne al
                cmovb rdi, rsi
                cmova rsi, rdi

        cmp rsi, 1
        je @F
        
        mov rcx, rsi
        call RQwordToPowerOf2
        cmp rsi, rax
        je @F
               mov rsi, rax
               mov rdi, rax
               setne al
@@:
        test al, al
        je @F           ;Are going to change size?
                mov rcx, op1
                mov rdx, rdi
                call ReallocLongVal
                mov rcx, op2
                mov rdx, rsi
                call ReallocLongVal  
@@:

	dec rdi   
	dec rsi	
	
	mov rcx, dest
	mov rdx, op1
	mov r8, op2
	xor r9, r9
	mov qword ptr[rsp+20h], rdi
	mov qword ptr[rsp+28h], 0
	mov qword ptr[rsp+30h], rsi
	call PartialMultLongVal
	test rax, rax
	je @Error
        
        ;restore dest sign
        mov (longval ptr[r11]).val_sign, r10
        
        mov rcx, op1
        call CompactLongVal
        
        mov rcx, op2
        call CompactLongVal
        
        mov rcx, dest
        call CompactLongVal
	
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

END




