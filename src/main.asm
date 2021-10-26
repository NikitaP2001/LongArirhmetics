include user32.inc
include msvcrt.inc
include kernel32.inc
include ntdll.inc
includelib user32.lib
includelib msvcrt.lib
includelib kernel32.lib
includelib ntdll.lib

include main.inc
include longops.inc

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
		xor rcx, rcx
		xor rdx, rdx
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
		mov (VALSET PTR global_set).val_count, 1
		mov rcx, DllHeapHandle
		mov rdx, 8
		mov r8, 1 * 8
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
dump_pat	db	"%0#2x ", 0
error_print db "DumpLongVal: invalid longval struct"
.code
DumpLongVal proc desc:QWORD
	push rbx
	push rsi
	sub rsp, 18h
	
	call GetLongvalPtr
	mov rcx, rax
	
	mov rbx, (longval PTR [rcx]).val_size
	;case zero size
	test rbx, rbx
	je @Error
	
	lea rsi, (longval PTR [rcx]).val_ptr
	mov rsi, QWORD PTR [rsi]
	;case nullptr
	test rsi, rsi
	je @Error
	
@@:
	mov rcx, OFFSET dump_pat
	movzx rdx, byte ptr[rsi]
	call crt_printf
	
	inc rsi
	dec rbx
	
	test rbx, rbx
	je @F
	
	jmp @B

@Error:
	lea ecx, error_print
	call crt_puts
	
@@:
	mov ecx, 10
	call crt_putchar
	
	add rsp, 18h
	pop rsi
	pop rbx
	ret
DumpLongVal endp

ENDIF

end
