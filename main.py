from PIL import Image

def mostrarImagenes(encriptada, desencriptada):
    """
    Genera una ventana con las dos imagenes, la encriptada y la desencriptada
    @param: lista con los pixeles encriptados
    @param: lista con los pixeles desencriptados
    """
    #dimensiones imagen 1
    ancho1 = 640
    largo1 = 480
    #dimensiones imagen 2
    ancho2 = 480
    largo2 = 640

    #se define la imagen 1 encriptada
    imagen1 = Image.new("L", (ancho1, largo1))
    imagen1.putdata(encriptada)

    #se define la imagen 2 desencriptada
    imagen2 = Image.new("L", (ancho2, largo2))
    imagen2.putdata(desencriptada)

    # unir ambas imagenes en una misma ventana
    ancho_total = ancho1 + ancho2
    alto_total = max(largo1, largo2)
    imagenUnida = Image.new("LA", (ancho_total, alto_total))
    imagenUnida.paste(imagen1, (0, 0))
    imagenUnida.paste(imagen2, (ancho1, 0))

    #mostrar las dos imagenes juntas
    imagenUnida.show()


def fileReader(path):
    """
    Se utiliza para leer los archivos
    @param: la ruta de donde esta guardado el archivo
    @return: el valor de la lectura en un string
    """
    file = open(path, 'r')
    data = file.read()
    file.close()
    return data


def toList(data):
    """
    convierte la lectura de los archivos que son strings a listas de numeros
    @param: string con la cadena leida
    @return: lista con los valores numericos de los pixeles
    """
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