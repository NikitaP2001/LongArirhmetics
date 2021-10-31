include user32.inc
include msvcrt.inc
include kernel32.inc
include ntdll.inc
includelib user32.lib
includelib msvcrt.lib
includelib kernel32.lib
includelib ntdll.lib

include main.inc
include longval.inc

DLL_PROCESS_ATTACH equ 1
DLL_PROCESS_DETACH equ 0
MB_OK EQU 0

.data
DllHeapHandle	QWORD	0

.code
DllMain proc hInstDll:QWORD, reason:QWORD, unused:QWORD
	sub rsp, 20h

	cmp edx, DLL_PROCESS_ATTACH
	jne @elseif
	
		;initilize heap
		mov rcx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
		xor rdx, 20480
		xor r8, r8
		call HeapCreate
		test eax, eax
		jne @F
		
		or ecx, 1
		call ExitProcess
		jmp @endif
@@:	
		mov DllHeapHandle, rax
		
		;initilize vals array
		mov (VALSET PTR global_set).val_count, 10
		mov rcx, DllHeapHandle
		mov rdx, 8
		mov r8, 10 * 8
		call HeapAlloc
		test rax, rax
		jne @F
		
		or ecx, 1
		call ExitProcess
		jmp @endif
@@:	
		mov (VALSET PTR global_set).val_array, rax
	
	jmp @endif
@elseif:	
	cmp edx, DLL_PROCESS_DETACH
	jne @endif
	
		cmp DllHeapHandle, 0
		je @F
@@:
		mov rcx, DllHeapHandle
		call HeapDestroy
		
@endif:

	mov eax, 1
	add rsp, 20h
	ret
DllMain endp

;	function needed in debug purposes
IFDEF DEBUG

.data
sizepat db "Set size: %llu", 10, 0

.data
dump_pat	db	"%02x ", 0
error_print db "DumpLongVal: invalid longval struct"
.code
DumpLongVal proc desc:QWORD
	push rdi
	push rbx
	push rsi
	sub rsp, 28h
	
	call GetLongvalPtr
	test rax, rax
	je @Error
	
	mov rdi, rax
	
	;write sign
	mov rax, (longval PTR [rdi]).val_sign
	test rax, rax
	je @F
	
	mov ecx, '-'
	call crt_putchar
	
@@:
	
	mov rbx, (longval PTR [rdi]).val_size
	;case zero size
	test rbx, rbx
	je @Error
	
	mov rsi, (longval PTR [rdi]).val_ptr
	;case nullptr
	test rsi, rsi
	je @Error
	
	add rsi, rbx
	dec rsi
	
@@:
	mov rcx, OFFSET dump_pat
	movzx rdx, byte ptr[rsi]
	call crt_printf
	
	dec rsi
	dec rbx
	
	test rbx, rbx
	je @F
	
	jmp @B

@Error:
	lea rcx, error_print
	call crt_puts
	
@@:
	mov ecx, 10
	call crt_putchar
	
	add rsp, 28h
	pop rsi
	pop rbx
	pop rdi
	ret
DumpLongVal endp

ENDIF

end
