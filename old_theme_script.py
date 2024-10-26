import colorsys

import requests

import math


def calculate_luminace(normalized_value):
    index = normalized_value

    if index < 0.03928:
        return index / 12.92
    else:
        return ((index + 0.055) / 1.055) ** 2.4


def calculate_relative_luminance(r, g, b):
    return 0.2126 * calculate_luminace(r) + 0.7152 * calculate_luminace(g) + 0.0722 * calculate_luminace(b)


def calculate_contrast_ratio(color: tuple[float, float, float], otherColor: tuple[float, float, float]):
    l1 = calculate_relative_luminance(*color)
    l2 = calculate_relative_luminance(*otherColor)
    return (l1 + 0.05) / (l2 + 0.05) if l1 > l2 else (l2 + 0.05) / (l1 + 0.05)


def rad(degrees: float):
    return degrees / 180 * math.pi


def rgbToHex(r: float, g: float, b: float):
    rs = hex(math.floor(r * 255))[2:].zfill(2)
    gs = hex(math.floor(g * 255))[2:].zfill(2)
    bs = hex(math.floor(b * 255))[2:].zfill(2)

    return rs + gs + bs


type RGBColor = tuple[float, float, float]


class FlowColorScheme:
    def __init__(self, surfaceColor: RGBColor, onSurfaceColor: RGBColor, primaryColor: RGBColor, onPrimaryColor: RGBColor, accentColor: RGBColor, onAccentColor: RGBColor, contrast: float, name="undefined"):
        self.name = name
        self.surfaceColor = surfaceColor
        self.onSurfaceColor = onSurfaceColor
        self.primaryColor = primaryColor
        self.onPrimaryColor = onPrimaryColor
        self.accentColor = accentColor
        self.onAccentColor = onAccentColor
        self.contrast = contrast

    def setName(self, name):
        self.name = name

    def toDict(self):
        return {
            "surfaceColor": self.surfaceColor,
            "onSurfaceColor": self.onSurfaceColor,
            "accentColor": self.accentColor,
            "onAccentColor": self.onAccentColor,
            "primaryColor": self.primaryColor,
            "onPrimaryColor": self.onPrimaryColor,
            "contrast": self.contrast,
        }

    def toDart(self):
        return f"""final {self.name} = FlowColorScheme(
    isDark: false,
    surface: const Color(0xff{rgbToHex(*self.surfaceColor)}),
    onSurface: const Color(0xff{rgbToHex(*self.onSurfaceColor)}),
    primary: const Color(0xff{rgbToHex(*self.primaryColor)}),
    onPrimary: const Color(0xff{rgbToHex(*self.onPrimaryColor)}),
    secondary: const Color(0xff{rgbToHex(*self.accentColor)}),
    onSecondary: const Color(0xff{rgbToHex(*self.onAccentColor)}),
    customColors: FlowCustomColors(
      income: Color(0xFF32CC70),
      expense: Color(0xFFFF4040),
      semi: Color(0xFF6A666D),
    ),
); // contrast: {self.contrast}\n"""


def to_camel_case(value):
    content = "".join(value.title().split())
    return content[0].lower() + content[1:]


def generateColors(backgroundColor: tuple[float, float, float], targetContrast: float, hueOffset=0, numberOfColors=16, saturation=0.2, initialBrightness=1.0, brightnessStep=-.05, totalTrials=5):
    colorContrastList: list[tuple[tuple[float, float, float], float]] = list()

    unitHue = 1 / numberOfColors

    for i in range(numberOfColors):
        hue = (hueOffset + unitHue * i) % 1.0

        r, g, b = colorsys.hsv_to_rgb(hue, saturation, initialBrightness)

        trials = totalTrials
        contrast = calculate_contrast_ratio(backgroundColor, (r, g, b))

        while contrast < targetContrast and trials > 0:
            trials -= 1
            r, g, b = colorsys.hsv_to_rgb(
                hue, saturation, initialBrightness + (brightnessStep * (totalTrials - trials)))
            contrast = calculate_contrast_ratio(backgroundColor, (r, g, b))

        colorContrastList.append(((r, g, b), contrast))

    return colorContrastList


def generateDefaultColors(light=True):
    light_bg = 0xf5 / 255.0, 0xf6 / 255.0, 0xfa / 255.0
    dark_bg = 0x11 / 255.0, 0x11 / 255.0, 0x11 / 255.0

    bg = light_bg if light else dark_bg

    generated = list()

    for [color, contrast] in generateColors(bg, 0.0, saturation=1.0, initialBrightness=0.31, totalTrials=0, brightnessStep=0.033, hueOffset=0.776):
        generated.append(color)

    return generated


default_darks = generateDefaultColors(light=False)

for d in default_darks:
    print(f"${rgbToHex(*d)}")
