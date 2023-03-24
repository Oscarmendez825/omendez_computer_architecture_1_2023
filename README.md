# Diseño e Implementación de un ASIP de desencriptación mediante RSA

Este es un proyecto realizado en ensamblador X86 y en Python.

## Instalación

Para instalar todas las herramientas necesarias:
### Compilador x86

```bash
sudo apt update
sudo apt install nasm gdb
```
### Python3 y librería necesaria
```bash
sudo apt update
sudo apt install python3-pip
pip install pillow
```

## Uso
Si desea ejecutar todo de manera separada debe ejecutar lo siguiente:
```bash
nasm -felf64 -o deco.o deco.asm -g
ld -o deco deco.o
./deco
#Aqui el sistema se encarga de solicitar las llaves de D y N, estas deben ser de 4 
#digitos, en caso de que no sea así debe rellernar con ceros. Ejemplo: 0021 8574
python3 main.py
```
Si desea ejecutar todo de automáticamente debe ejecutar lo siguiente:
```bash
make
```
## Editor de texto utilizado

Para la edición y diseño del código se utilizó [VSCode](https://code.visualstudio.com/)

## Instrucciones utilizadas 
```assembly
mov, imul, int, xor, je, sub, add, inc, jmp, shl, shr, jne, dec
```
## Directivas utilizadas 
```assembly
section .data
    filename db 
    resultFile db 
    mensaje1 db 
    error_msg db 
section .bss
    buffer resb 
    A resd 
    B resd 
    respuesta1 resb 
    D resd 
    N resd 
    text resb 
    resultado resb 
    resultadoRSA resd 
    valor_actual resd  
    endFlag resd 1        
    cantidadChars resd 
section .text
    global _start
```
