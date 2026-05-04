%include "../../lib/pc_io.inc"  

section .text
    global _start       
    
_start:     
    ; Se acaba 
    mov esi, arr
    movzx ecx, byte [len]
    call capturarArreglo

    ; Se muestra arreglo original
    mov edx, msg_original
    call puts
    mov esi, arr
    movzx ecx, byte [len]
    call mostrarArreglo

    ; Se Ordena arreglo
    mov esi, arr
    movzx ecx, byte [len]
    call ordenarArreglo

    ; Se Muestra arreglo ordenado
    mov edx, msg_ordenado
    call puts
    mov esi, arr
    movzx ecx, byte [len]
    call mostrarArreglo

    mov eax, 1          
    mov ebx, 0
    int 0x80            
capturarArreglo:
    ; Recibe: esi = dirección de inicio del arreglo, ecx = cantidad de elementos
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov edi, 0          ; Índice del arreglo
.loop_cap:
    push ecx
    push esi
    push edi

    ; Imprimir mensaje de captura
    mov edx, msg_in
    call puts

    ; Leer entrada del usuario
    mov eax, 3          
    mov ebx, 0          
    mov ecx, cad        
    mov edx, 64         
    int 0x80

    ; Convertir a entero
    mov esi, cad        
    call atoi           

    pop edi
    pop esi
    pop ecx

    ; Guardar el entero en el arreglo
    mov dword [esi + edi*4], eax
    inc edi
    loop .loop_cap

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

mostrarArreglo:
    ; Recibe: esi = dirección de inicio del arreglo, ecx = cantidad de elementos
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, 0
.cicloImpArr:
    push ecx
    push esi
    push edi

    ; Extraer elemento y convertir a ASCII
    mov eax, dword [esi + edi*4]    
    mov edx, cad_res
    mov bl, byte [lencad]
    call itoa

    ; Imprimir elemento
    mov edx, cad_res
    call puts
    mov al, ' '
    call putchar

    pop edi
    pop esi
    pop ecx

    inc edi
    loop .cicloImpArr

    ; Salto de línea al terminar de imprimir el arreglo
    mov al, 10
    call putchar

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret 

ordenarArreglo:
    ; Recibe: esi = dirección de inicio del arreglo, ecx = cantidad de elementos (n)
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    cmp ecx, 1
    jle .fin_sort       ; Si el arreglo tiene 1 o 0 elementos, ya está ordenado

    mov eax, 0          ; i = 0
    mov edi, ecx
    dec edi             ; Límite exterior (n-2 en lógica de salto, que es n-1 como límite superior exclusivo)

.loop_i:
    cmp eax, edi        ; para i=0 hasta n-2
    jge .fin_sort

    mov edx, eax        ; minimo = i
    
    mov ebx, eax   
    inc ebx             ; j = i + 1

.loop_j:
    cmp ebx, ecx        ; para j=i+1 hasta n-1
    jge .end_j

    ; si arreglo[j] < arreglo[minimo] entonces
    mov ebp, dword [esi + ebx*4]   
    cmp ebp, dword [esi + edx*4]   
    jge .next_j
    
    mov edx, ebx        ; minimo = j

.next_j:
    inc ebx
    jmp .loop_j

.end_j:
    cmp edx, eax        ; si minimo != i
    je .next_i

    ; intercambiar arreglo[i] con arreglo[minimo]
    mov ebp, dword [esi + eax*4]
    push dword [esi + edx*4]
    pop dword [esi + eax*4]
    mov dword [esi + edx*4], ebp

.next_i:
    inc eax
    jmp .loop_i

.fin_sort:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

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

.fin_atoi: ; Renombrado local para no chocar
    imul eax, ecx       ; Si no se cambia el multiplicador sera por 1, sino, sera -1
    pop edx
    pop ecx
    pop ebx
    ret

.fin:
    jmp .fin_atoi
    
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
    msg_in db 'Captura un elemento para el arreglo: ', 0
    msg_original db 0xa, 'Arreglo original: ', 0
    msg_ordenado db 0xa, 'Arreglo ordenado: ', 0
    nlin db 0xa
    
    lencad db 64
    cad times 64 db 0       
    cad_res times 64 db 0   
    len db 5
    arr times 5 dd 0    ; Aqui se reserva el espacio del arreglo en este caso 5
    
    numero dd 0
    cociente dd 0
    residuo dd 0
    base dd 10
    divBase dd 1000000000
    divi dd 0