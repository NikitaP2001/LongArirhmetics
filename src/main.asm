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
		mov rcx, HEAP_GENERATE_EXCEPTIONS + HEAP_NO_SERIALIZE
		mov rdx, 0
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
		mov rdx, HEAP_GENERATE_EXCEPTIONS + HEAP_ZERO_MEMORY + HEAP_NO_SERIALIZE
		mov r8, 10 * 8
		call HeapAlloc
		test rax, rax
		jne @F
		
		or ecx, 1
		call ExitProcess
		jmp @endif
@@:	
		mov (VALSET PTR global_set).val_array, rax                
                
                mov r10, StashSize              
                mov rbx, OFFSET ValStash
        @for:  
                        call AllocLongVal
                        mov (VALREG ptr [rbx]).descriptor, rax
                        mov (VALREG ptr [rbx]).IsFree, 0      
                        add rbx, SIZEOF VALREG
                        dec r10
                        jne @for             
	
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

end
