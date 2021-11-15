include main.inc

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

.code


align 16
RQwordToPowerOf2 proc val:QWORD        
        mov rax, 1        

align 4        
@while:        
        cmp rax, rcx
        jge @Found  
        shl rax, 1
        jmp @while
@Found:
        
        ret
RQwordToPowerOf2 endp



END