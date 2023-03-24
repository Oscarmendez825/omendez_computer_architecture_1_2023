all: deco.asm
	nasm -felf64 -o deco.o deco.asm -g
	ld -o deco deco.o
	./deco
	python3 main.py