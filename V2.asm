%include "io64.inc"
section .data

outpt times 67 db 0x0
deciOutput dq 0

section .text
global main
main:
    mov rbp, rsp; for correct debugging
    NEWLINE
    NEWLINE
    PRINT_STRING "--Number Base Conversion--"
    NEWLINE
    PRINT_STRING "1. Decimal to Radix-N"
    NEWLINE
    PRINT_STRING "2. Radix-N to Decimal"
    NEWLINE
    NEWLINE
    
    xor rdi,rdi
    PRINT_STRING "Select mode: "
    GET_DEC 1, dil
    
    push rdi
    
    call change_mode
    
    NEWLINE
    PRINT_STRING "--Program Terminated--"
    NEWLINE
    xor rax, rax
    ret

change_mode:
    mov rbp, rsp
    mov rax, [rbp + 8]
    cmp al, 1
    JE dectoradix
    cmp al, 2
    JE radixtodec
    
    PRINT_STRING "Invalid mode!"
    NEWLINE
    jmp return
    
    dectoradix:
        call mode1
        jmp return
        
    radixtodec:
        call mode2
    
    return:
        ret 8
    
mode1:
    PRINT_STRING "Enter a decimal number: "
    GET_DEC 8, rax
    PRINT_STRING "Enter a desired radix: "
    GET_DEC 1, bl
    NEWLINE
    
    ;Check if radix is valid
    cmp bl, 16
    JG err
    cmp bl, 2
    JL err
    
    ;check if number is negative
    cmp rax, 0
    JGE conver
    neg rax
    xor r15, r15
    inc r15
    
    conver:
    push rax
    call mode1conv
    ret
        
mode2:
    GET_STRING outpt, 65 ;eat the extra stuff at the end
    PRINT_STRING "Enter a number: "
    GET_STRING outpt, 65
    PRINT_STRING "Enter its radix: "
    xor rbx, rbx
    GET_DEC 1, bl
    NEWLINE
    
    ;Check if radix is valid
    cmp bl, 16
    JG err
    cmp bl, 2
    JL err
    
    ;check if number is valid
    lea rsi, [outpt]
    xor rcx, rcx
    xor rax, rax
    xor r8, r8
    xor r15, r15
    cmp byte[rsi + rcx], "-"
    JNE L2
    inc r15
    inc rcx
    
    L2:
        mov r8b, byte[rsi + rcx]
        cmp r8b, 0x39
        JG alphanumeric
        cmp r8b, 0x30
        JL err2
        
        ;if al is a number
        sub r8b, 0x30 ;bring it back to hex vals
        
        cmp r8b, bl ;check if valid for given radix
        JGE err2
        
        jmp transferdigits2
        
    alphanumeric:
        cmp r8b, 0x5A
        JL a2
        sub r8b, 0x20 ;convert to capital
        
    a2:
        sub r8b, 0x37 ;bring to proper hex val
        cmp r8b, bl 
        JGE err2 ;if not valid
        
    transferdigits2:
        shl r8, 60
        shld rax, r8, 4 ;otherwise enter into rax
        inc rcx ;move to the next digit
        cmp byte[rsi + rcx], 0xa ;check if at the end of the string
        JE convert2
        sub rcx, r15
        cmp rcx, 16 ;check if rax is full
        add rcx, r15
        JE convert2
        JMP L2
    
    convert2:
        push rax
        call mode2conv
        ret
    
    err:
        PRINT_STRING "Invalid Radix!"
        NEWLINE
        ret
    err2:
        PRINT_STRING "Invalid Radix-"
        PRINT_DEC 1, bl
        PRINT_STRING " Number!"
        NEWLINE
        ret


mode1conv:
    mov rbp, rsp
    lea rsi, [outpt]
    mov rax, [rbp + 8]
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
        jge fin
        mov al, [rsi + rdi]
        mov r8b, [rsi + rcx]
        mov [rsi + rdi], r8b
        mov [rsi + rcx], al
        inc rdi
        dec rcx
        jmp L4
        
    fin:
        PRINT_STRING "Output (radix-"
        PRINT_DEC 1, bl
        PRINT_STRING "): "
        cmp r15, 1
        jne pos2
        PRINT_STRING "-"
    pos2:
        PRINT_STRING [outpt]
        NEWLINE
    ret 8

mode2conv:
    mov rbp, rsp
    mov rax, [rbp + 8]
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
        
    PRINT_STRING "Output (Decimal): "
    cmp r15, 1
    JNE pos
    PRINT_STRING "-"
    
    pos:
    PRINT_UDEC 8, [deciOutput]
    NEWLINE
    ret 8