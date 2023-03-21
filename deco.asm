section .data
    filename db 'nums.txt',0
    res db 'res.txt',0
    ;num1 db 5 ;almacenará cada número encontrado
    ;num2 db 5 ;almacenará cada número encontrado
    mode db 'w', 0    ; modo de escritura

section .bss
    buffer resb 11
    A resd 1
    B resd 1
    resultado resd 1
    buffTemp resd 1
    text resb 10         ; cadena de caracteres para almacenar el número convertido
    temp resb 1

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
    mov edx, 11
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
    shl eax, 8
    add eax, ebx


toChar:
    mov edx, eax      ; guardar el valor original de EAX en EDX
    xor ecx, ecx      ; contador de dígitos
    mov ebx, 10       ; base decimal
    .convert_loop:
        xor edx, edx  ; limpiar edx para la división
        div ebx        ; dividir edx por 10
        add dl, '0'    ; convertir el resto a un carácter ASCII
        mov [text + ecx], dl ; guardar el carácter en la cadena de caracteres
        add ecx, 1     ; incrementar el contador de dígitos
        cmp eax, 0  ; comprobar si el cociente es cero
        jne .convert_loop  ; si no es cero, seguir dividiendo
    mov eax, edx      ; restaurar el valor original de EAX


_end_program:

    ; print del archivo
    mov eax, 4 
    mov ebx, 1 
    mov ecx, text 
    int 80h 
    


	mov eax, 1 ;preparar la llamada al sistema para salir
	xor ebx, ebx ;código de salida 0
	int 80h ;realizar la llamada al sistema

