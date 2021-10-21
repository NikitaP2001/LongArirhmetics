include user32.inc
includelib user32.lib

.code
DllMain proc hInstDll:QWORD, reason:QWORD, unused:QWORD
	sub rsp, 8h

	mov eax, 1
	ret
DllMain endp

end
