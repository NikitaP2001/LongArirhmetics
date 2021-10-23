include user32.inc
include msvcrt.inc
include kernel32.inc
includelib user32.lib
includelib msvcrt.lib
includelib kernel32.lib

include main.inc
include longops.inc

DLL_PROCESS_ATTACH equ 1
DLL_PROCESS_DETACH equ 0
MB_OK EQU 0

.data
DllHeapHandle	QWORD	0

MsgAttach db "The DLL is loaded", 0 
MsgDetach db "The DLL is unloaded", 0
HeapAllocError db 8, "[-]Error allocating heap", 0

.code
DllMain proc hInstDll:QWORD, reason:QWORD, unused:QWORD
	sub rsp, 20h

	cmp edx, DLL_PROCESS_ATTACH
	jne @elseif
	
		xor rcx, rcx
		xor rdx, rdx
		xor r8, r8
		call HeapCreate
		test eax, eax
		jne @F
		
		lea ecx, HeapAllocError
		call DllMonitor
		
		or ecx, 1
		call ExitProcess
		jmp @endif
@@:	
		mov DllHeapHandle, rax
	
		mov rcx, OFFSET MsgAttach
		call DllMonitor
	jmp @endif
@elseif:	
	cmp edx, DLL_PROCESS_DETACH
	jne @endif
	
		cmp DllHeapHandle, 0
		je @F
@@:
		mov rcx, DllHeapHandle
		call HeapDestroy
	
		mov rcx, OFFSET MsgDetach
		call DllMonitor
@endif:

	mov eax, 1
	add rsp, 20h
	ret
DllMain endp

;	function needed in debug purposes
IFDEF DEBUG

DllMonitor proc msg:PTR BYTE
	LOCAL 	hConsole:QWORD,
			msg_len:DWORD
	sub rsp, 28h
	mov msg, rcx
	
	mov ecx, -11
	call GetStdHandle
	mov hConsole, rax
	
	mov rcx, msg
	call crt_strlen
	mov msg_len, eax
	
	mov rcx, hConsole
	mov rdx, msg
	mov r8d, msg_len
	xor r9, r9
	mov dword ptr[rsp+20], 0
	call WriteConsoleA
	
	mov ecx, 10
	call crt_putchar
	
	mov eax, 1
	add rsp, 28h
	ret
DllMonitor endp

.data
dump_pat	db	"%0#2x ", 0
error_print db "DumpLongVal: invalid longval struct"
.code
DumpLongVal proc val:PTR longval
	push rbx
	push rsi
	sub rsp, 18h
	mov val, rcx
	
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
