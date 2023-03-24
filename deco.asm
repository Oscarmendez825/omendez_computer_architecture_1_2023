section .data
    filename db '0.txt',0
    resultFile db 'resultados.txt',0
    mensaje1 db 'Ingrese las llaves D y N de la forma D N ', 0Ah ,'Las llaves D y N deben ser de 4 digitos, de lo contrario rellene con ceros:'
    error_msg db 'Error al abrir el archivo', 0
section .bss
    buffer resb 1712374
    A resd 1
    B resd 1

    respuesta1 resb 9 ; reserva 9 bytes el input de las llaves D y N
    D resd 2
    N resd 2

    text resb 10         ; cadena de caracteres para almacenar el número convertido
    resultado resb 10    ;cadena de caracteres que almacena el resultado final
    resultadoRSA resd 3
    valor_actual resd 3

    endFlag resd 1

    cantidadChars resd 2

section .text
    global _start

_start:
    ; mostrar mensaje1
    mov eax, 4
    mov ebx, 1
    mov ecx, mensaje1
    mov edx, 117
    int 0x80

    ; leer respuesta1
    mov eax, 3
    mov ebx, 0
    mov ecx, respuesta1
    mov edx, 9
    int 0x80

_parse_D:
	mov ecx, respuesta1 ;cargar la dirección del buffer en el registro ESI
	xor eax, eax    ;poner a cero el registro EAX
    xor ebx, ebx

make_D:
	mov bl, [ecx]   ;cargar caracter en bl
	cmp bl, ' '     ;si el carácter es un espacio fin del numero
	je end_D
	sub bl, '0'     ;convertir el caracter a int
	imul eax, 10    ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx    ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc ecx         ;incrementa el puntero de los bits
	jmp make_D

end_D:
	mov dword [D], eax  ;almacenar el número en memoria en A
	inc ecx             ;salta el espacio en blanco y continua

parse_N:
	xor eax, eax        ;reinicia el registro EAX
    xor ebx, ebx        ;reinicia el registro EBX
    xor edx, edx
make_N:
	mov bl, [ecx]       ;cargar caracter en bl
	cmp edx, 4           ;final del buffer cond parada
	je end_N
	sub bl, '0'         ;convertir el caracter a int
	imul eax, 10        ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx        ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc ecx             ;incrementa el puntero de los bits
    inc edx
	jmp make_N

end_N:
	mov dword [N], eax  ;almacenar el número en memoria
    

readFile:
    mov eax, 5      ;abrir el archivo
    mov ebx, filename 
    mov ecx, 0 
    int 80h 


    cmp eax, -1     ;compueba si el archivo se abrio exitosamente
    je _error 


    mov eax, 3      ;leer el archivo
    mov ebx, eax 
    mov ecx, buffer 
    mov edx, 1712374
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
	je last             
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
	je last
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
    xor eax, eax          ;poner a cero el registro EAX
    xor ebx, ebx          ;poner a cero el registro EAX
    xor edx, edx
    xor ecx, ecx
    mov eax, dword [A]  ;toma el valor guardado en A y lo almacena en EAX
    mov ebx, dword [B]  ;toma el valor guardado en B y lo almacena en EBX
    shl eax, 8          ;toma un espacio de 8bits para luego concatenar A y B
    add eax, ebx        ;suma/concatena A y B
    

    mov dword[resultadoRSA], 1
    mov ebx, dword[N]
    mov ecx, dword[D]
    xor edx, edx
    div ebx
    mov dword[valor_actual], edx

binaryLoop:
    cmp ecx, 0
    jne multiplicaciones
    jmp end_RSA

multiplicaciones:
    xor edx, edx
    mov edx, ecx
    and edx, 1
    cmp edx, 1
    je impar
    jmp par

impar:
    xor eax, eax          ;poner a cero el registro EAX
    xor edx, edx
    mov eax, dword[resultadoRSA]
    mov edx, dword[valor_actual]
    imul eax, edx
    xor edx, edx
    div ebx
    mov dword[resultadoRSA], edx
    xor eax, eax
    mov eax, dword[valor_actual]
    imul eax, eax
    xor edx, edx
    div ebx
    mov dword[valor_actual], edx
    shr ecx, 1
    jmp binaryLoop

par:
    xor eax, eax          ;poner a cero el registro EAX
    xor edx, edx
    mov eax, dword[valor_actual]
    imul eax, eax
    div ebx
    mov dword[valor_actual], edx
    shr ecx, 1
    jmp binaryLoop

end_RSA:
    xor eax, eax
    mov eax, dword[resultadoRSA]
    
toChar:
    xor edx, edx
    mov edx, eax                ; guardar el valor original de EAX en EDX
    xor ecx, ecx                ; contador de dígitos
    mov ebx, 10                 ;se ocupa dividir entre 10 para poder obtener digito a digito
    mov dword[text + 2], '0'
    mov dword[text + 1], '0'
    mov dword[text], '0'
    .convert_loop:
        xor edx, edx            ;poner en cero el registro EDX
        div ebx                 ;divide EAX por EBX
        add dl, '0'             ;convertir numero a char
        mov [text + ecx], dl    ;concatena el caracter a la cadena de caracteres guardada en text
        add ecx, 1              ;incrementa el contador de dígitos
        cmp eax, 0              ;comprueba si el cociente es cero y termina el ciclo si lo es
        jne .convert_loop       
    mov eax, edx                ;devuelve el valor original de EAX
resultSpin:
    xor edx, edx
    xor ecx, ecx
    mov ecx, text
contadorChars:
    mov bl, [ecx]       ;cargar caracter en bl
	cmp bl, 0          ;final del buffer cond parada
	je preSpin
	inc ecx             ;incrementa el puntero de los bits
    inc edx
	jmp contadorChars
preSpin:
    xor ecx, ecx
    xor eax, eax
    xor ebx, ebx
    mov dword[cantidadChars], edx
    sub edx, 1
spinChars:
    cmp edx, -1
    je concatSpace
    mov bl, byte[text+edx]
    mov [resultado + ecx], ebx
    inc ecx
    dec edx
    jmp spinChars

concatSpace:
    mov bl, ' '
    mov [resultado + ecx], bl
    

writeFile:
    ; Abrir el archivo para lectura y escritura
    mov eax, 5              ;abrir el archivo    
    mov ebx, resultFile     ;archivo donde se desea escribir
    mov ecx, 2       
    mov edx, 0644    
    int 80h          


    mov ebx, eax     

   ;toma referencia del final del archivo
    mov eax, 19              ;lseek
    mov ecx, 0       
    mov edx, 2       
    int 80h          

    xor edi, edi
    mov edi, dword[cantidadChars]
    add edi,1

    ; Escribir el resultado en el archivo
    mov eax, 4              ;orden para escribir en el archivo
    mov ecx, resultado      ;contenido a escribir
    mov edx, edi              ;longitud del texto
    int 80h          


    ; Cerrar el archivo
    mov eax, 6              ;orden para cerrar el archivo
    int 80h    

    xor eax, eax
    mov eax, dword[endFlag]
    cmp eax, 1

    je _end_program
    jmp next_num



_end_program:

    ; print del archivo
    mov eax, 4 
    mov ebx, 1 
    mov ecx, buffer 
    int 80h 

	mov eax, 1              ;preparar la llamada al sistema para salir
	xor ebx, ebx            ;código de salida 0
	int 80h                 ;realizar la llamada al sistema

last:
    mov dword [B], eax  ;almacenar el número en memoria
    mov dword [endFlag], 1
    jmp _RSA

