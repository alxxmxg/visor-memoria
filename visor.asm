; Proyecto Módulo 1 - Visor de Memoria
; Lenguajes de Interfaz (SCC-1014)

extrn GetStdHandle:proc
extrn WriteFile:proc

.data
    arreglo DQ 5, 10, 15, 20, 25, 30, 35, 40, 45, 50
    str_dir DB 'Direccion: ', 0
    str_val DB ' Valor: ', 0
    newline DB 13, 10, 0
    buffer DB 32 DUP(0)
    hex_chars DB '0123456789ABCDEF'
    hConsole DQ 0
    bytes_escritos DQ 0

.code

print_hex_qword proc
    push rbx
    push rcx
    push rdx
    sub rsp, 20h          ; Ajuste silencioso de pila

    mov rcx, 16
    add rdi, 15
    mov rbx, 0Fh

hex_loop:
    mov rdx, rax
    and rdx, rbx
    movzx rdx, byte ptr [hex_chars + rdx]
    mov [rdi], dl
    dec rdi
    shr rax, 4
    loop hex_loop

    add rdi, 1
    call print_string

    add rsp, 20h          ; Restaurar pila
    pop rdx
    pop rcx
    pop rbx
    ret
print_hex_qword endp

print_string proc
    push rcx
    push rdx
    push r8
    push r9
    push rdi
    sub rsp, 30h          ; Espacio requerido por Windows para WriteFile

    mov rcx, -1
    xor al, al
    repne scasb
    not rcx
    dec rcx
    mov r8, rcx

    mov rdi, [rsp+30h]    ; Restaurar inicio de cadena silenciosamente
    
    mov rcx, hConsole   
    mov rdx, rdi        
    lea r9, bytes_escritos 
    mov qword ptr [rsp+20h], 0 ; 5to parametro obligatorio
    call WriteFile
    
    add rsp, 30h
    pop rdi
    pop r9
    pop r8
    pop rdx
    pop rcx
    ret
print_string endp

main proc
    sub rsp, 28h

    mov rcx, -11
    call GetStdHandle
    mov hConsole, rax

    lea rbx, arreglo
    mov rcx, 10

recorrer_arreglo:
    push rcx
    sub rsp, 28h          ; Mantener alineacion de Windows x64 dentro del bucle

    lea rdi, str_dir
    call print_string
    
    mov rax, rbx 
    lea rdi, buffer
    call print_hex_qword

    lea rdi, str_val
    call print_string
    
    mov rax, [rbx]
    lea rdi, buffer
    call print_hex_qword

    lea rdi, newline
    call print_string

    add rsp, 28h          ; Limpiar antes de hacer pop
    pop rcx
    
    add rbx, 8
    loop recorrer_arreglo

    xor eax, eax
    add rsp, 28h
    ret
main endp
end