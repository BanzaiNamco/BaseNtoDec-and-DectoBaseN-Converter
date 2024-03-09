%include "io64.inc"
section .data

outpt times 66 db 0x0
deciOutput dq 0

section .text
global main
main:
    mov rbp, rsp; for correct debugging
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    xor rdx, rdx
    PRINT_STRING "Select mode: "
    GET_DEC 1, al
    NEWLINE
    CMP AL, 1
    JNE conv
    
    dec:
    PRINT_STRING "Enter a decimal number: "
    GET_DEC 8, rax
    NEWLINE
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, bl
    NEWLINE
    NEWLINE
    
    ; error checking (valid radix)
    CMP bl, 16
    JG err
    CMP bl, 2
    JL err
    call dectox
    PRINT_STRING "Output (radix-"
    PRINT_DEC 1, bl
    PRINT_STRING "): "
    PRINT_STRING [outpt]
    NEWLINE
    
    JMP fin
    
    conv:
    PRINT_STRING "Enter a number: "
    GET_HEX 8, rax
    NEWLINE
    PRINT_STRING "Enter its radix: "
    GET_DEC 1, bl
    NEWLINE
    NEWLINE
    
    ;error checking (valid radix)
    CMP BL, 16
    JG err
    CMP BL, 2
    JL err
    
    ;error checking (valid number)
    mov r8, rax
    valid?:
        xor r9, r9
        shrd r9, r8, 4
        shr r9, 60
        CMP r9b, bl
        JGE err2
        SHR r8, 4
        CMP r8, 0
        JNE valid?
    
    call xtodec
    PRINT_STRING "Output (Decimal): "
    PRINT_DEC 8, [deciOutput]
    NEWLINE
    
    JMP fin

    ;TODO check rax is a valid radix-n number
    
    err:
    PRINT_STRING "Invalid radix!"
    NEWLINE
    JMP fin
    err2:
    PRINT_STRING "Invalid radix-"
    PRINT_DEC 1, bl
    PRINT_STRING " number!"
    NEWLINE
    JMP fin
    err3:
    PRINT_STRING "Invalid number!"
    NEWLINE
    fin:
    PRINT_STRING "--Program Terminated--"
    xor rax, rax
    ret
    
dectox:
    lea rsi, [outpt]
    xor rcx, rcx
    L3:
        xor rdx,rdx
        DIV rbx
        CMP rdx, 10
        JL num
        sub rdx, 10
        add rdx, 0x41
        JMP nxt
        
        num:
        add rdx, 0x30
        nxt:
        mov [rsi + rcx], rdx
        inc rcx        
        CMP rax, 0
        JNE L3
        
    dec rcx
    xor rdi, rdi
    L4:
        cmp rdi, rcx
        jge fin2
        mov al, [rsi + rdi]
        mov r8b, [rsi + rcx]
        mov [rsi + rdi], r8b
        mov [rsi + rcx], al
        inc rdi
        dec rcx
        jmp L4
    fin2:
    ret

xtodec:
    MOV R8, RAX
    XOR RCX, RCX
    CHECK_DIGITS:
        MOV R9, R8
        AND R9, 0xF
               
        MOV RDI, RBX
        CMP RCX, 1
        JE L5
        CMP RCX, 2
        JGE L6
        
        add qword [deciOutput], r9  
        JMP increase
        L5:
            IMUL R9, RDI
            ADD qword [deciOutput], r9
            JMP increase
        L6:
            MOV R10, RDI
            MOV R11, RCX
            DEC R11
            power:
                IMUL R10, RDI
                DEC R11
                CMP R11, 0
                JNE power
             IMUL R9, R10
             ADD qword [deciOutput], r9
   
        increase:
            INC RCX 
 
        SHR R8, 4  
        CMP R8, 0 
        JNZ CHECK_DIGITS
        
    ret
