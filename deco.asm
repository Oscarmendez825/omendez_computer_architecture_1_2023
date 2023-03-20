section .data
    filename db 'nums.txt',0
    res db 'res.txt',0
    ;num1 db 5 ;almacenará cada número encontrado
    ;num2 db 5 ;almacenará cada número encontrado
    mode db 'w', 0    ; modo de escritura

section .bss
    buffer resb 8
    A resd 1
    B resd 1
    resultado resd 1
    buffTemp resd 1
    text resb 10         ; cadena de caracteres para almacenar el número convertido

section .text
    global _start

_start:
    ; abrir el archivo
    mov eax, 5 
    mov ebx, filename 
    mov ecx, 0 
    int 80h 

; comprobar si el archivo se abrió correctamente
    cmp eax, -1
    je _error 

; leer el archivo
    mov eax, 3  
    mov ebx, eax 
    mov ecx, buffer 
    mov edx, 8
    int 80h ; llama al sistema

; print del archivo
    ;mov eax, 4 
    ;mov ebx, 1 
    ;mov ecx, buffer 
    ;int 80h 

; cerrar el archivo
    mov eax, 6 
    int 80h 

    ;mov edi, 1 ;registro que controla cual split realizar

    jmp _split1


_error:
    mov eax, 1 
    mov ebx, 1 
    int 80h 


_split1:
	mov esi, buffer ;cargar la dirección del buffer en el registro ESI

next_num:
	xor eax, eax ;poner a cero el registro EAX
    xor ebx, ebx

createN1:
	mov bl, [esi] ;cargar caracter en bl
	cmp bl, 0 ;final del buffer cond parada
	je _RSA
	cmp bl, ' ' ;si el carácter es un espacio fin del numero
	je end_num1
	sub bl, '0' ;convertir el caracter a int
	imul eax, 10 ;multiplicar el registro EAX por 10
	add eax, ebx 
	inc esi 
	jmp createN1

end_num1:
	mov dword [A], eax ;almacenar el número en memoria
	inc esi ;avanzar al siguiente carácter del buffer (el espacio en blanco)
	jmp _split2


_split2:
	xor eax, eax ;poner a cero el registro EAX
    xor ebx, ebx
next_char2:
	mov bl, [esi] ;cargar caracter en bl
	cmp bl, 0 ;final del buffer cond parada
	je end_num2
	cmp bl, ' ' ;si el carácter es un espacio fin del numero
	je end_num2
	sub bl, '0' ;convertir el caracter a int
	imul eax, 10 ;multiplicar el registro EAX por 10
	add eax, ebx 
	inc esi 
	jmp next_char2

end_num2:
	mov dword [B], eax ;almacenar el número en memoria
	inc esi ;avanzar al siguiente carácter del buffer (el espacio en blanco)

_RSA:
    mov eax, 0 ;poner a cero el registro EAX
    mov ebx, 0
    mov eax, dword [A]
    mov ebx, dword [B]
    add eax,ebx

_potencia:
    mov ecx, 10 ;aqui va el valor de D
    mov edx, 1 ;contador de la potencia
    imul eax, eax
    add edx, 1
    cmp ecx, edx
    jne _potencia
    jmp _modulo

_modulo:
    xor edx, edx   ; Inicializar edx a cero
    mov ebx, 3     ; Colocar el divisor en ebx
    div ebx        ; Dividir eax por ebx
    mov eax, edx   ; Mover el valor de edx a eax (el resto de la división)
    mov dword [resultado], eax

_convertChar:
    ; mover el número a un registro
    mov eax, dword [resultado]

    ; convertir el número en una cadena de caracteres
    mov ebx, 10        ; base decimal
    xor ecx, ecx       ; contador de dígitos
    xor edx, edx       ; limpiar edx para la división
    .convert_loop:
        div ebx          ; dividir eax por 10
        add edx, '0'     ; convertir el resto a un carácter ASCII
        mov [text + ecx], dl  ; guardar el carácter en la cadena de caracteres
        inc ecx          ; incrementar el contador de dígitos
        test eax, eax    ; comprobar si el cociente es cero
        jnz .convert_loop ; si no es cero, seguir dividiendo






_end_program:

    ; print del archivo
    mov eax, 4 
    mov ebx, 1 
    mov ecx, text 
    int 80h 

	mov eax, 1 ;preparar la llamada al sistema para salir
	xor ebx, ebx ;código de salida 0
	int 80h ;realizar la llamada al sistema

