def pbm_lines(filename):
    with open(filename, 'rb') as f:
        file_lines = f.readlines()

    width, height = file_lines[1].split()
    width, height = int(width), int(height)

    img_data = file_lines[2]

    img_lines = []
    x = 0
    width_in_bytes = width / 8
    if width % 8:
        width_in_bytes += 1

    for row in range(height):
        img_lines.append(img_data[x:x+width_in_bytes])
        x += width_in_bytes

    return img_lines
