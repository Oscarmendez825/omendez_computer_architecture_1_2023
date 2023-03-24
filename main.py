from PIL import Image

def mostrarImagenes(encriptada, desencriptada):

    ancho1 = 640
    alto1 = 480

    ancho2 = 320
    alto2 = 320

    # Cargar los datos de imagen desde las listas de píxeles
    imagen1 = Image.new("L", (ancho1, alto1))
    imagen1.putdata(encriptada)

    imagen2 = Image.new("L", (ancho2, alto2))
    imagen2.putdata(desencriptada)

    # Crear una nueva imagen que contenga ambas imágenes lado a lado
    ancho_total = ancho1 + ancho2
    alto_total = max(alto1, alto2)
    imagen_combinada = Image.new("LA", (ancho_total, alto_total))
    imagen_combinada.paste(imagen1, (0, 0))
    imagen_combinada.paste(imagen2, (ancho1, 0))

    # Mostrar la imagen combinada
    imagen_combinada.show()

def fileReader(path):
    file = open(path, 'r')
    data = file.read()
    file.close()
    return data


def toList(data):
    listedData = []
    temp = ''
    for i in data:
        if i != ' ':
            temp += i
        else:
            listedData.append(int(temp))
            temp = ''
    listedData.append(int(temp))
    return listedData


def main():
    path1 = "./resultados.txt"
    path2 = "./5.txt"
    pxencriptados = fileReader(path2)
    pxdesencriptados = fileReader(path1)
    pxdesencriptados = pxdesencriptados[:-1]
    pxEn = toList(pxencriptados)
    pxDec = toList(pxdesencriptados)
    pxDec[-1] = 0
    mostrarImagenes(pxEn, pxDec)

if __name__ == "__main__":
    main()