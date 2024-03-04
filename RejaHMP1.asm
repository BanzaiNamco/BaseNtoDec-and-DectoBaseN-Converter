%include "io64.inc"
section .data

outpt times 66 db 0x0

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
    ;TODO CHECK rax is a valid dec number
    
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
    GET_DEC 8, rax
    NEWLINE
    PRINT_STRING "Enter its radix: "
    GET_DEC 1, bl
    NEWLINE
    NEWLINE
    CMP BL, 16
    JG err
    CMP BL, 2
    JL err
    
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
