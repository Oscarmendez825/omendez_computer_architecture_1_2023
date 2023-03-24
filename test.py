import PIL.Image as Image


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
    path = "./resultados.txt"
    ecryptedPic = fileReader(path)
    dencryptedPic = toList(ecryptedPic)
    pic = Image.new('L', (480, 640))
    pic.putdata(dencryptedPic)
    pic.save("test.png")
    pic.close()


if __name__ == "__main__":
    main()