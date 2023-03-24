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
    resultadoRSA resd 3  ;almacena el resultado del RSA
    valor_actual resd 3  ;almacena el valor para las iteraciones del RSA

    endFlag resd 1        ; indica que ya es la ultima iteracion

    cantidadChars resd 2    ;almacena la cantidad de caracteres necesarios para escribir en el archivo de respuesta

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
	mov ecx, respuesta1         ;cargar la dirección del buffer en el registro ESI
	xor eax, eax                ;poner a cero el registro EAX
    xor ebx, ebx

make_D:
	mov bl, [ecx]               ;cargar caracter en bl
	cmp bl, ' '                 ;si el carácter es un espacio fin del numero
	je end_D
	sub bl, '0'                 ;convertir el caracter a int
	imul eax, 10                ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx                ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc ecx                     ;incrementa el puntero de los caracteres
	jmp make_D

end_D:
	mov dword [D], eax          ;almacenar el número en memoria en D
	inc ecx                     ;salta el espacio en blanco y continua

parse_N:
	xor eax, eax                ;reinicia el registro EAX
    xor ebx, ebx                ;reinicia el registro EBX
    xor edx, edx                ;reinicia el registro EDX
make_N:
	mov bl, [ecx]               ;cargar caracter en bl
	cmp edx, 4                  ;final del N cond parada
	je end_N
	sub bl, '0'                 ;convertir el caracter a int
	imul eax, 10                ;multiplicar el registro EAX por 10 para formar las decenas-centenas, etc
	add eax, ebx                ;agrega el nuevo numero y lo pone en el espacio de las unidades
	inc ecx                     ;incrementa el puntero de los caracteres
    inc edx                     ;incrementa el contador de iteraciones
	jmp make_N

end_N:
	mov dword [N], eax          ;almacenar el número en memoria en N
    

readFile:
    mov eax, 5                  ;abrir el archivo
    mov ebx, filename           ;nombre del archivo que contiene los pixeles encriptados
    mov ecx, 0 
    int 80h 

    mov eax, 3                  ;leer el archivo
    mov ebx, eax 
    mov ecx, buffer             ;almacena todos los caracteres leidos en el buffer
    mov edx, 1712374            ;cantidad de caracteres a leer
    int 80h 

    mov eax, 6                  ;cerrar el archivo
    int 80h 
    
    jmp _split1


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
	inc esi         ;incrementa el puntero de los caracteres
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
	inc esi             ;incrementa el puntero de los caracteres
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
    add eax, ebx        ;suma/concatena A y B (base)
    

    mov dword[resultadoRSA], 1      ;inicializa el resultado del RSA en 1
    mov ebx, dword[N]               ;asigna el valor de la llave N
    mov ecx, dword[D]               ;asigna el valor de la llave D
    xor edx, edx                    ;pone en 0 el registro edx
    div ebx                         ;calcula el modulo de la base para el primer ciclo
    mov dword[valor_actual], edx    ;guarda el modulo/residuo en valor_actual

binaryLoop:
    cmp ecx, 0                      ;condicion de parada del algoritmo RSA
    jne multiplicaciones            ;si no se cumple la condicion va a multiplicaciones
    jmp end_RSA                     ;si se cumple termina el RSA y va a end_RSA

multiplicaciones:
    xor edx, edx                    ;pone en 0 el registro edx
    mov edx, ecx                    ;le asigna a edx el valor de ecx (potencia)
    and edx, 1                      ;mascara para solo dejar el LSB 
    cmp edx, 1                      ;si es 1 quiere decir que el numero es impar y ademas que debe realizarse la operacion especial del RSA
    je impar                        ;va a impar donde se hace la operacion especial del RSA
    jmp par                         ;va a par donde solo se eleva el valor actual al cuadrado y se le saca el modulo

impar:                              ;operacion especial del RSA
    xor eax, eax                    ;pone en cero el registro EAX
    xor edx, edx                    ;pone en cero el registro EDX
    mov eax, dword[resultadoRSA]    ;recupera el valor del resultado del RSA y lo asigna a EAX
    mov edx, dword[valor_actual]    ;obtiene el valor actual que ha obtenido por las iteraciones y lo asigna a edx
    imul eax, edx                   ;multiplica el resultado del RSA por el valor actual
    xor edx, edx                    ;pone en cero el registro EDX
    div ebx                         ;divide EAX por EBX
    mov dword[resultadoRSA], edx    ;el residuo/modulo lo guarda en el resultado del RSA
    xor eax, eax                    ;pone en cero el registro EAX
    mov eax, dword[valor_actual]    ;asigna el resultado actual de las iteraciones a EAX
    imul eax, eax                   ;eleva el resultado actual al cuadrado
    xor edx, edx                    ;pone en cero el registro EDX
    div ebx                         ;divide EAX por EBX
    mov dword[valor_actual], edx    ;actualiza el resultado actual de las iteraciones
    shr ecx, 1                      ;Elimina el LSB del exponente
    jmp binaryLoop                  ;repite el ciclo

par:
    xor eax, eax                    ;pone en cero el registro EAX
    xor edx, edx                    ;pone en cero el registro EDX
    mov eax, dword[valor_actual]    ;asigna el resultado actual de las iteraciones a EAX
    imul eax, eax                   ;eleva el resultado actual al cuadrado
    div ebx                         ;divide EAX por EBX
    mov dword[valor_actual], edx    ;actualiza el resultado actual de las iteraciones
    shr ecx, 1                      ;Elimina el LSB del exponente
    jmp binaryLoop                  ;repite el ciclo

end_RSA:
    xor eax, eax                    ;pone en cero el registro EAX
    mov eax, dword[resultadoRSA]    ;asigna el resultado final del RSA a EAX
    
toChar:
    xor edx, edx                ;pone en cero el registro edx
    mov edx, eax                ;guardar el valor original de EAX en EDX
    xor ecx, ecx                ;contador de dígitos
    mov ebx, 10                 ;se ocupa dividir entre 10 para poder obtener digito a digito
    mov dword[text + 2], '0'    ;reinicia las tres posiciones de memoria donde se van a almacenar los caracteres
    mov dword[text + 1], '0'
    mov dword[text], '0'
    .convert_loop:
        xor edx, edx            ;pone en cero el registro EDX
        div ebx                 ;divide EAX por EBX
        add dl, '0'             ;convertir numero a char
        mov [text + ecx], dl    ;concatena el caracter a la cadena de caracteres guardada en text
        add ecx, 1              ;incrementa el contador de dígitos
        cmp eax, 0              ;comprueba si el cociente es cero y termina el ciclo si lo es
        jne .convert_loop       
    mov eax, edx                ;devuelve el valor original de EAX
resultSpin:
    xor edx, edx                ;pone en cero el registro EDX
    xor ecx, ecx                ;pone en cero el registro ECX
    mov ecx, text               ;se le asigna a ECX la posicion donde esta text
contadorChars:
    mov bl, [ecx]               ;cargar caracter actual en bl
	cmp bl, 0                   ;final del buffer cond parada
	je preSpin
	inc ecx                     ;incrementa el puntero de los caracteres
    inc edx                     ;incrementa el contador de los caracteres
	jmp contadorChars
preSpin:
    xor ecx, ecx                    ;pone en cero el registro ECX
    xor eax, eax                    ;pone en cero el registro EAX
    xor ebx, ebx                    ;pone en cero el registro EBX
    mov dword[cantidadChars], edx   ;guarda la cantidad de caracteres que tiene el numero para luego ser utilizado
    sub edx, 1                      ;se le resta 1 a la cantidad
spinChars:
    cmp edx, -1                     ;condicion de parada para voltear la cadena 
    je concatSpace                  
    mov bl, byte[text+edx]          ;obtiene un caracter de text y lo asigna a bl
    mov [resultado + ecx], ebx      ;agrega ese caracter al resultado que sera escrito en el txt
    inc ecx                         ;incrementa ECX para moverse a la derecha
    dec edx                         ;disminuye EDX con el fin de quedar en 0 la cantidad de caracteres y terminar el ciclo
    jmp spinChars

concatSpace:
    mov bl, ' '                     ;se le asigna el caracter espacio a bl
    mov [resultado + ecx], bl       ;se le concatena el espacio al resultado para simplificar la separacion en python
    

writeFile:
    ; Abrir el archivo para lectura y escritura
    mov eax, 5                          ;abrir el archivo    
    mov ebx, resultFile                 ;archivo donde se desea escribir
    mov ecx, 2       
    mov edx, 0644    
    int 80h          


    mov ebx, eax     

   ;toma referencia del final del archivo
    mov eax, 19                         ;lseek
    mov ecx, 0       
    mov edx, 2       
    int 80h          

    xor edi, edi                        ;pone en cero el registro EDI
    mov edi, dword[cantidadChars]       ;se asigna a EDI la cantidad de caracteres previamente obtenida
    add edi,1                           ;se le suma 1 correspondiente al ' ' concatenado

    ; Escribir el resultado en el archivo
    mov eax, 4                          ;orden para escribir en el archivo
    mov ecx, resultado                  ;contenido a escribir
    mov edx, edi                        ;longitud del texto
    int 80h          


    ; Cerrar el archivo
    mov eax, 6                          ;orden para cerrar el archivo
    int 80h    

    xor eax, eax                        ;pone en cero el registro EAX
    mov eax, dword[endFlag]             ;asigna a EAX el valor de la bandera de fin
    cmp eax, 1                          ;si la bandera es 1 termina el programa si no toma otros dos pixeles y se repite todo

    je _end_program
    jmp next_num



_end_program:

	mov eax, 1              ;preparar la llamada al sistema para salir
	xor ebx, ebx            ;código de salida 0
	int 80h                 ;realizar la llamada al sistema

last:
    mov dword [B], eax      ;almacenar el número en memoria
    mov dword [endFlag], 1  ;indica que ya es la ultima iteracion
    jmp _RSA                ;calcula el RSA de los ultimos pixeles

