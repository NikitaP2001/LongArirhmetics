include ntdll.inc
include kernel32.inc
includelib ntdll.lib
includelib kernel32.lib

include longval.inc
include main.inc

.data
global_set VALSET <0, 0>
ValStash VALREG StashSize DUP(<>)

.code

AllocLongVal proc
;Add new longval to global_set
;return:
;	descriptor:QWORD
;-----------------------------
	push rdi
        push r10
        push r11
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
        mov (longval PTR [rdi]).mem_size, VALMEM_DEFAULT_SIZE
	mov rcx, DllHeapHandle
	mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
	mov r8, VALMEM_DEFAULT_SIZE
	call HeapAlloc
	je @Error
	mov (longval PTR [rdi]).val_ptr, rax
        
        mov r10, rax
@@:     
        mov rcx, r10
        call GetLongvalPtr
        test rax, rax
        je @F
        inc r10
        jmp @B
@@:        
        mov rax, r10
	mov (longval PTR [rdi]).descriptor, rax
        mov (longval PTR [rdi]).val_sign, 0
	
	jmp @Exit
@Error:
	
	xor rax, rax
@Exit:
	add rsp, 28h
        pop r11
        pop r10
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
	mov r8, (longval ptr[r8]).val_ptr
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
	mov qword ptr[rdi], 0
	
	;move last
	mov rcx, (VALSET PTR global_set).val_count
	mov rdx, (VALSET PTR global_set).val_array
	lea rdx, [rdx + rcx * 8 - 8]
	mov rax, qword ptr [rdx]
	mov qword ptr[rdx], 0
	mov qword ptr [rdi], rax
	
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


ReallocLongVal proc desc:QWORD, new_size:QWORD
	push rdi
	push r10
	push r11
        push r12
	sub rsp, 28h
	mov new_size, rdx
	
	call GetLongvalPtr
	test rax, rax
	je @Error
	mov r12, rax	               
        
	mov rdx, new_size
        cmp (longval PTR [r12]).mem_size, rdx
        jae @chvalsize
        	; Reallocate memory if news > mems
                mov (longval PTR [r12]).mem_size, rdx
                mov rcx, DllHeapHandle
                mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
                mov r8, (longval PTR [r12]).val_ptr
                mov r9, new_size
                call HeapReAlloc
                test rax, rax
                je @Error
                mov (longval PTR [r12]).val_ptr, rax
                
@chvalsize:   
        mov rdx, new_size
        cmp (longval PTR [r12]).val_size, rdx
        jae @F
                xor rax, rax
                mov rdi, (longval ptr[r12]).val_ptr
                add rdi, (longval PTR [r12]).val_size
                mov rcx, new_size
                sub rcx, (longval PTR [r12]).val_size
                cld
                rep stosb
@@:
	mov (longval PTR [r12]).val_size, rdx
        
        mov rax, (longval PTR [r12]).val_ptr
	jmp @F
	
@Error:
	xor rax, rax
@@:
	add rsp, 28h
        pop r12
	pop r11
	pop r10
	pop rdi
	ret
ReallocLongVal endp

CompactLongVal proc desc:QWORD
	push rdi
	push rbx
	sub rsp, 28h
	mov desc, rcx
	
	call GetLongvalPtr
	test rax, rax
	jz @Error
	
	mov rdi, (longval ptr[rax]).val_ptr
	mov rbx, (longval ptr[rax]).val_size
	add rdi, rbx
	dec rdi
	
@@:
	cmp byte ptr[rdi], 0
	jne @F
	
	cmp rbx, 1
	jbe @F
	
	dec rdi
	dec rbx
	cmp rbx, 1
	jmp @B
	
@@:
	mov rcx, desc
	mov rdx, rbx
	call ReallocLongVal
	test rax, rax
	jz @Error
	
	jmp @end
	
@Error:
	xor rax, rax

@end:
	add rsp, 28h
	pop rbx
	pop rdi
	ret
CompactLongVal endp

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

BinToLongVal proc dest:QWORD, source:PTR BYTE, s_size:QWORD
        push rsi
        push rdi        
        sub rsp, 28h
        mov dest, rcx
        mov source, rdx
        mov s_size, r8

        mov rdx, r8
        call ReallocLongVal
        test rax, rax
        je @Error               
        
        mov rdi, rax
        mov rsi, source        
        mov rcx, s_size
        lea rsi, [rsi+rcx-1]
@@:     
        dec rcx
        js @F
                mov al, byte ptr[rsi]
                mov byte ptr[rdi], al
                dec rsi
                inc rdi
                jmp @B
@@:
        or rax, 1
        jmp @end
@Error:
        xor rax, rax
@end:

        add rsp, 28h
        pop rdi
        pop rsi        
        ret
BinToLongVal endp

END