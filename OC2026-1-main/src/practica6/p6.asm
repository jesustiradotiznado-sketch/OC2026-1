%include "../../lib/pc_io.inc"  

section .text
    global _start       
    
_start:                   
    ; Se le pide la cadena al usuario
    mov edx, ncad
    call puts
    ; Configurar parámetros y llamar a Capturar
    movzx ax, byte [len]  ; ax longitud máxima 64
    mov edx, cad          
    call capturar
    mov al, [nlin]
    call putchar
    mov edx, msg_min  ; Llamar el convertir a minuscula
    call puts
    mov edx, cad
    call minusculas       ; Se convierte la cadena a minúsculas
    mov edx, cad
    call puts             ; Se imprime la cadena transformada
    mov al, [nlin]
    call putchar
    mov edx, msg_may      ; Llamar el convertir a mayuscula
    call puts
    mov edx, cad
    call mayusculas       ; Se convierte la cadena a mayúsculas
    mov edx, cad
    call puts             ; Se imprime la cadena transformada
    mov al, [nlin]        ; Salto de linea 
    call putchar
    call putchar
    mov eax, 1          ; Fin de programa
    int 0x80            

capturar:
    push edx
    push cx
    push bx
    mov cx, ax          
    dec cx              
    mov bx, cx          
.ciclo: 
    call getch          
    cmp al, 0x7f       
    je .borrar_char
    cmp al, 0x0a        
    je .salir
    cmp cx, 0
    je .ciclo
    call putchar        
    mov [edx], al       
    inc edx             
    dec cx              
    jmp .ciclo

.borrar_char:
    cmp cx, bx          
    je .ciclo           

    call borrar         
    dec edx             
    inc cx             
    jmp .ciclo

.salir:
    mov byte [edx], 0  
    pop bx
    pop cx
    pop edx
    ret

borrar:
    push ax 
    mov al, 0x8         
    call putchar    
    mov al, ' '         
    call putchar
    mov al, 0x8         
    call putchar   
    pop ax
    ret 


minusculas:
    push edx
    push eax
.ciclo:
    mov al, [edx]
    cmp al, 0           ; Se busca el caracter Nulo
    je .salir
    
    cmp al, 'A'         ; Si es menor que 'A', no es mayuscula
    jb .siguiente
    cmp al, 'Z'         ; Si es mayor que 'Z', no es mayuscula
    ja .siguiente
    
    add al, 32          ; Se convierte a minúscula sumando 32 al ASCII
    mov [edx], al       

.siguiente:
    inc edx             ; Avanza al siguiente caracter
    jmp .ciclo

.salir:
    pop eax
    pop edx
    ret

mayusculas:
    push edx
    push eax
.ciclo:
    mov al, [edx]
    cmp al, 0           ; Se busca el caracter nulo
    je .salir
    
    cmp al, 'a'         ; Si menor que 'a', no es minuscula
    jb .siguiente
    cmp al, 'z'         ; Si es mayor que 'z', no es minuscula
    ja .siguiente
    
    sub al, 32          ; Se Convierte a mayuscula restando 32 en ASCII
    mov [edx], al       

.siguiente:
    inc edx             ; Avanza al siguiente caracter
    jmp .ciclo

.salir:
    pop eax
    pop edx
    ret
;Aqui guardo los mensajes, yo del futuro NO SE TE VAYA A OLVIDAR EN EL EXAMEN xd
section .data
    ncad    db 0xa, 'Cadena: ', 0
    msg_min db 'Minusculas: ', 0
    msg_may db 'Mayusculas: ', 0
    nlin    db 0xa, 0
    len     db 64
    
section .bss
    cad times 64 db 0