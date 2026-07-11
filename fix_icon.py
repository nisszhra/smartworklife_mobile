from PIL import Image

def create_notification_icon(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    for item in datas:
        # If the pixel is mostly transparent, keep it transparent
        if item[3] < 128:
            new_data.append((255, 255, 255, 0))
        # If the pixel is mostly white, make it transparent
        elif item[0] > 200 and item[1] > 200 and item[2] > 200:
            new_data.append((255, 255, 255, 0))
        # Otherwise (the actual logo content), make it solid white
        else:
            new_data.append((255, 255, 255, 255))

    img.putdata(new_data)
    img.save(output_path, "PNG")
    print(f"Icon successfully generated at {output_path}")

create_notification_icon(
    "assets/images/logo_polos_smartworklife.png",
    "android/app/src/main/res/drawable/ic_notification.png"
)
