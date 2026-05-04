%include "../../lib/pc_io.inc"  

section .text
    global _start       
    
_start:     
    
    mov edx, msg_in
    call puts

    
    mov eax, 3          
    mov ebx, 0          
    mov ecx, cad        
    mov edx, 64         ; maximo 64 caracteres
    int 0x80

    ; Se llama el ATOI para convertir el ASCII
    mov esi, cad        ; Es la dirección de inicio de la cadena
    call atoi           ; El resultado entero se queda en EAX

    ; Se imprime
    push eax            ; Se guarda en EAX temporalmente
    mov edx, msg_out
    call puts
    pop eax             ; Recuperar el número entero en EAX

    ; Se llama el ITOA para convertir de entero a cadena
    mov edx, cad_res    ; Dirección de la cadena de destino
    mov bl, byte[lencad]
    call itoa
    call puts           ; Imprimir el número convertido
    
    mov al, 10
    call putchar


    mov eax, 1          
    mov ebx, 0
    int 0x80            
atoi:
    ;esi es la dirección de inicio de cadena
    ;eax es el número entero con signo
    push ebx
    push ecx
    push edx

    mov eax, 0          ; Se inicia en 0
    mov ecx, 1          ; El signo para que sea positivo osea 1

.ignorar_espacios:
    mov bl, byte [esi]
    cmp bl, ' '         ; revisar que sea un espacio
    je .siguiente_espacio
    cmp bl, 9           ; Revisar que no sea un tab
    je .siguiente_espacio
    jmp .revisar_signo

.siguiente_espacio:
    inc esi
    jmp .ignorar_espacios

.revisar_signo:
    cmp bl, '-'         
    jne .revisar_positivo
    mov ecx, -1         ; Si no se hace el salto, cambiar el multiplicador a negativo
    inc esi
    jmp .convertir_digitos

.revisar_positivo:
    cmp bl, '+'         ; Se revisa si es positivo
    jne .convertir_digitos
    inc esi             

.convertir_digitos:
    mov bl, byte [esi]
    cmp bl, '0'
    jl .fin             ; menor que 0 puede ser letras, puntos o nulos
    cmp bl, '9'
    jg .fin             ; mayor que 9 son letras

    mov edx, 10
    imul eax, edx

    ; Se convierte a ASCII
    sub bl, '0'
    movzx ebx, bl       
    add eax, ebx        ; Se suma el digito al total

    inc esi
    jmp .convertir_digitos

.fin:
    imul eax, ecx       ; Si no se cambió el multiplicador sera por 1, sino, sera -1
    pop edx
    pop ecx
    pop ebx
    ret

impArreglo:
    push ecx
    push esi
    mov ecx,0
    mov esi,0
    mov cl,dl   
    .cicloImpArr:
    push eax
    push edx
    ;PARAMETRO DE ITOA
    mov edx,eax
    mov eax,dword[edx+esi*4]    
    mov edx,cad
    mov bl,byte[lencad]
    call itoa

    mov edx,cad
    call puts
    mov al,' '
    call putchar

    inc esi
    pop edx
    pop eax
    loop .cicloImpArr

    pop esi
    pop ecx
    ret 
    
itoa:
    ;eax NUMERO ENTERO
    ;edx CADENA
    ;bl Longitud de la cadena        
    push dword[divBase]
    pop dword[divi]

    push esi
    mov esi,0
    mov dword[cociente],0
    mov dword[residuo],0
    mov dword[numero],eax        
    cmp eax,0
    jge .while 
    mov byte[edx+esi],'-'
    inc esi
    neg eax
    mov dword[numero], eax
    
    .while:
    push eax
    push edx
    mov edx,0
    idiv dword[divi]
    cmp eax,0
    jne .salir
    mov edx,0
    mov eax,dword[divi]
    idiv dword[base]
    mov dword[divi],eax                
    pop edx
    pop eax
    jmp .while
    
    .salir:
    pop edx
    pop eax

    .do:
    push edx
    mov edx,0
    mov eax,dword[numero]
    idiv dword[divi]
    mov dword[cociente],eax
    mov dword[residuo],edx
    pop edx

    add dword[cociente],'0'
    push ebx
    mov bl,byte[cociente]
    mov byte[edx+esi],bl
    pop ebx
    inc esi
    push dword[residuo]
    pop dword[numero]
    push edx
    mov edx,0
    mov eax,dword[divi]
    idiv dword[base]
    mov dword[divi],eax  
    pop edx
    cmp dword[divi],0
    je .final_itoa        
    jmp .do        

.final_itoa:
    mov byte[edx+esi],0
    pop esi
    ret


section .data
    msg_in db 
    msg_out db 
    ncad db 0xa,'Arreglo: ',0
    nlin db 0xa
    
    lencad db 64
    cad times 64 db 0       
    cad_res times 64 db 0   
    len db 5
    arr dd 24,4,3,2,52

    numero dd 0
    cociente dd 0
    residuo dd 0
    base dd 10
    divBase dd 1000000000
    divi dd 0