include user32.inc
includelib user32.lib

DLL_PROCESS_ATTACH equ 1
DLL_PROCESS_DETACH equ 0
MB_OK equ 0

.data
AppName db "longar64.dll", 0
MsgAttach db "The DLL is loaded", 0 
MsgDetach db "The DLL is unloaded", 0 

.code
DllMain proc hInstDll:QWORD, reason:QWORD, unused:QWORD
	sub rsp, 8h

	test edx, DLL_PROCESS_ATTACH
	jne @F
		mov rcx, OFFSET MsgAttach
		call DllMonitor
	jmp @endif
@@:	
	test edx, DLL_PROCESS_DETACH
	jne @endif
		mov rcx, OFFSET MsgDetach
		call DllMonitor
@endif:

	mov eax, 1
	ret
DllMain endp

DllMonitor proc msg:PTR BYTE
	sub rsp, 28h
	
	xchg ecx, r8d
	xor ecx, ecx
	mov rdx, OFFSET AppName
	mov r9d, MB_OK
	call MessageBoxA

	ret
DllMonitor endp

end
