section .data
    filename db '5.txt',0
    buffer times 635918 db 0
    num db 0 ;almacenará cada número encontrado
    

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
    mov edx, 635918 
    int 80h ; llama al sistema

; print del archivo
    mov eax, 4 
    mov ebx, 1 
    mov ecx, buffer 
    int 80h 

; cerrar el archivo
    mov eax, 6 
    int 80h 

    jmp _split


_error:
    mov eax, 1 
    mov ebx, 1 
    int 80h 


_split:
	mov esi, buffer ;cargar la dirección del buffer en el registro ESI

next_num:
	xor eax, eax ;poner a cero el registro EAX

next_char:
	mov bl, [esi] ;cargar caracter en bl
	cmp bl, 0 ;final del buffer cond parada
	je end_split
	cmp bl, ' ' ;si el carácter es un espacio fin del numero
	je end_num
	sub bl, '0' ;convertir el caracter a int
	imul eax, 10 ;multiplicar el registro EAX por 10
	add eax, ebx 
	inc esi 
	jmp next_char

end_num:
	mov [num], al ;almacenar el número en memoria
	inc esi ;avanzar al siguiente carácter del buffer (el espacio en blanco)
	jmp next_num

end_split:
	mov eax, 1 ;preparar la llamada al sistema para salir
	xor ebx, ebx ;código de salida 0
	int 80h ;realizar la llamada al sistema

