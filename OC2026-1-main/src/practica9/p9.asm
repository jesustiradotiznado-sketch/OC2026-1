%include "../../lib/pc_io.inc"  	; incluir declaraciones de procedimiento externos
								; que se encuentran en la biblioteca libpc_io.a

section	.text
	global _start       ;referencia para inicio de programa
	global _imprimir     
	
_start:                

    push msg1       ;SEGUNDO PARAMETRO
    push msg2       ;PRIMER PARAMETRO
    call _imprimir
    add esp, 8 ;LIMPIA PARAMETROS DE LA FUNCION DE LA PILA

    
    push msg2       ;SEGUNDO PARAMETRO
    push msg1       ;PRIMER PARAMETRO
    call _imprimir
    add esp, 8 ;LIMPIA PARAMETROS DE LA FUNCION DE LA PILA

    
	mov	eax, 1	    	; seleccionar llamada al sistema para fin de programa
	int	0x80        	; llamada al sistema - fin de programa

    _imprimir:
        push ebp
        mov ebp , esp
        sub esp, 4          ; Reservar 4 bytes en la pila para la variable local [ebp-4]
        
        mov dword[ebp-4],msg3 ;VARIABLE LOCAL

        mov edx,[ebp-4]    ;VARIABLE LOCAL
	    call puts
        
        mov edx,[ebp+8]    ;PRIMER PARAMETRO
	    call puts
        mov edx,[ebp+12]   ;SEGUNDO PARAMETRO
	    call puts     

        mov esp, ebp        ; Restaurar el puntero de la pila (libera el espacio reservado para [ebp-4])
        pop ebp
        ret
    

section	.data
    msg1 db  'Hola mundo',0xa,0 
    msg2 db  'OC',0xa,0 
    msg3 db  'Practica 9',0xa,0 

