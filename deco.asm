section .data
    filename db 'nums.txt',0
    res db 'res.txt',0
    mode db 'w', 0    ; modo de escritura

section .bss
    buffer resb 11
    A resd 1
    B resd 1
    resultado resd 1
    text resb 10         ; cadena de caracteres para almacenar el número convertido

section .text
    global _start

_start:

    mov eax, 5      ;abrir el archivo
    mov ebx, filename 
    mov ecx, 0 
    int 80h 


    cmp eax, -1     ;compueba si el archivo se abrio exitosamente
    je _error 


    mov eax, 3      ;leer el archivo
    mov ebx, eax 
    mov ecx, buffer 
    mov edx, 11
    int 80h 

; print del archivo
    ;mov eax, 4 
    ;mov ebx, 1 
    ;mov ecx, buffer 
    ;int 80h 


    mov eax, 6      ;cerrar el archivo
    int 80h 

    jmp _split1


_error:
    mov eax, 1      ;termina el programa si hay error de lectura
    mov ebx, 1 
    int 80h 


_split1:
	mov esi, buffer ;cargar la dirección del buffer en el registro ESI

next_num:
	xor eax, eax    ;poner a cero el registro EAX
    xor ebx, ebx

createN1:
	mov bl, [esi]   ;cargar caracter en bl
	cmp bl, 0       ;final del buffer cond parada
	je _RSA             
	cmp bl, ' '     ;si el carácter es un espacio fin del numero
	je end_num1
	sub bl, '0'     ;convertir el caracter a int
	imul eax, 10    ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx    ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc esi         ;incrementa el puntero de los bits
	jmp createN1

end_num1:
	mov dword [A], eax  ;almacenar el número en memoria en A
	inc esi             ;salta el espacio en blanco y continua
	jmp _split2


_split2:
	xor eax, eax        ;reinicia el registro EAX
    xor ebx, ebx        ;reinicia el registro EBX
next_char2:
	mov bl, [esi]       ;cargar caracter en bl
	cmp bl, 0           ;final del buffer cond parada
	je end_num2
	cmp bl, ' '         ;si el carácter es un espacio fin del numero
	je end_num2
	sub bl, '0'         ;convertir el caracter a int
	imul eax, 10        ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx        ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc esi             ;incrementa el puntero de los bits
	jmp next_char2

end_num2:
	mov dword [B], eax  ;almacenar el número en memoria
	inc esi             ;salta el espacio en blanco y continua

_RSA:
    mov eax, 0          ;poner a cero el registro EAX
    mov ebx, 0          ;poner a cero el registro EAX
    mov eax, dword [A]  ;toma el valor guardado en A y lo almacena en EAX
    mov ebx, dword [B]  ;toma el valor guardado en B y lo almacena en EBX
    shl eax, 8          ;toma un espacio de 8bits para luego concatenar A y B
    add eax, ebx        ;suma/concatena A y B


toChar:
    mov edx, eax                ; guardar el valor original de EAX en EDX
    xor ecx, ecx                ; contador de dígitos
    mov ebx, 10                 ;se ocupa dividir entre 10 para poder obtener digito a digito
    .convert_loop:
        xor edx, edx            ;poner en cero el registro EDX
        div ebx                 ;divide EAX por EBX
        add dl, '0'             ;convertir numero a char
        mov [text + ecx], dl    ;concatena el caracter a la cadena de caracteres guardada en text
        add ecx, 1              ;incrementa el contador de dígitos
        cmp eax, 0              ;comprueba si el cociente es cero y termina el ciclo si lo es
        jne .convert_loop       
    mov eax, edx                ;devuelve el valor original de EAX



_end_program:

    ; print del archivo
    mov eax, 4 
    mov ebx, 1 
    mov ecx, text 
    int 80h 
    


	mov eax, 1              ;preparar la llamada al sistema para salir
	xor ebx, ebx            ;código de salida 0
	int 80h                 ;realizar la llamada al sistema

