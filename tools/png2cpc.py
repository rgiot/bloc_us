#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
png2cpc
(c) MML, 2009
"""


# Notas e Ideas:
# - Implementar la función --force (permitir más de 256 patrones)
# - ¿Añadir colores a la paleta hasta tener los 16?
# - Solo acepta los 16 primeros colores y no muestra errores
# - Si no das la opción -p convierte la imagen aunque no use la paleta cpc
# - Añadir el remapeado de la paleta externa a la interna.

# Parches para que funcione en python 2.5
from __future__ import with_statement

import sys
import os        # path.exists()
import glob        # glob() expande los patrones de los ficheros
import Image
from optparse import make_option, OptionParser
import hashlib    # para calcular el sha1 de los patrones

# Número máximo de colores del CPC
MAX_CPC_COLORS = 16

# Ancho en pixels de un byte según la resolución del CPC
pixels_por_byte = (2, 4, 8)

# Paleta del CPC
# Cadena RGB : Tinta + Color Hardware (lista para el Gate Array)
paleta2cpc = {
    '\x00\x00\x00' : 64 + 20,         # Negro               0x54 (84)
    '\x00\x00\x7F' : 64 + 4,          # Azul                0x44 (68)
    '\x00\x00\xFF' : 64 + 21,         # Azul Brillante      0x55 (85)
    '\x00\x7F\x00' : 64 + 22,         # Verde               0x56 (86)
    '\x00\x7F\x7F' : 64 + 6,          # Cian                0x46 (70)
    '\x00\x7F\xFF' : 64 + 23,         # Azul Cielo          0x57 (87)
    '\x00\xFF\x00' : 64 + 18,         # Verde Brillante     0x52 (82)
    '\x00\xFF\x7F' : 64 + 2,          # Verde Mar           0x42 (66)
    '\x00\xFF\xFF' : 64 + 19,         # Cian Brillante      0x53 (83)
    '\x7F\x00\x00' : 64 + 28,         # Rojo                0x5c (92)
    '\x7F\x00\x7F' : 64 + 24,         # Magenta             0x58 (88)
    '\x7F\x00\xFF' : 64 + 29,         # Malva               0x5d (93)
    '\x7F\x7F\x00' : 64 + 30,         # Amarillo            0x5e (94)
    '\x7F\x7F\x7F' : 64 + 0,          # Blanco              0x40 (64)
    '\x7F\x7F\xFF' : 64 + 31,         # Azul Pastel         0x5f (95)
    '\x7F\xFF\x00' : 64 + 26,         # Lima                0x5a (90)
    '\x7F\xFF\x7F' : 64 + 25,         # Verde Pastel        0x59 (89)
    '\x7F\xFF\xFF' : 64 + 27,         # Cian Pastel         0x5b (91)
    '\xFF\x00\x00' : 64 + 12,         # Rojo Brillante      0x4c (76)
    '\xFF\x00\x7F' : 64 + 5,          # Purpura             0x45 (69)
    '\xFF\x00\xFF' : 64 + 13,         # Magenta Brillante   0x4d (77)
    '\xFF\x7F\x00' : 64 + 14,         # Naranja             0x4e (78)
    '\xFF\x7F\x7F' : 64 + 7,          # Rosa                0x47 (71)
    '\xFF\x7F\xFF' : 64 + 15,         # Magenta Pastel      0x4f (79)
    '\xFF\xFF\x00' : 64 + 10,         # Amarillo Brillante  0x4a (74)
    '\xFF\xFF\x7F' : 64 + 3,          # Amarillo Pastel     0x43 (67)
    '\xFF\xFF\xFF' : 64 + 11          # Blanco Brillante    0x4b (75)
}

cpc2paleta = {
    64 + 20 : '\x00\x00\x00',         # Negro
    64 + 4  : '\x00\x00\x7F',         # Azul
    64 + 21 : '\x00\x00\xFF',         # Azul Brillante
    64 + 28 : '\x7F\x00\x00',         # Rojo
    64 + 24 : '\x7F\x00\x7F',         # Magenta
    64 + 29 : '\x7F\x00\xFF',         # Malva
    64 + 12 : '\xFF\x00\x00',         # Rojo Brillante
    64 + 5  : '\xFF\x00\x7F',         # Purpura
    64 + 13 : '\xFF\x00\xFF',         # Magenta Brillante
    64 + 22 : '\x00\x7F\x00',         # Verde
    64 + 6  : '\x00\x7F\x7F',         # Cian
    64 + 23 : '\x00\x7F\xFF',         # Azul Cielo
    64 + 30 : '\x7F\x7F\x00',         # Amarillo
    64 + 0  : '\x7F\x7F\x7F',         # Blanco
    64 + 31 : '\x7F\x7F\xFF',         # Azul Pastel
    64 + 14 : '\xFF\x7F\x00',         # Naranja
    64 + 7  : '\xFF\x7F\x7F',         # Rosa
    64 + 15 : '\xFF\x7F\xFF',         # Magenta Pastel
    64 + 18 : '\x00\xFF\x00',         # Verde Brillante
    64 + 2  : '\x00\xFF\x7F',         # Verde Mar
    64 + 19 : '\x00\xFF\xFF',         # Cian Brillante
    64 + 26 : '\x7F\xFF\x00',         # Lima
    64 + 25 : '\x7F\xFF\x7F',         # Verde Pastel
    64 + 27 : '\x7F\xFF\xFF',         # Cian Pastel
    64 + 10 : '\xFF\xFF\x00',         # Amarillo Brillante
    64 + 3  : '\xFF\xFF\x7F',         # Amarillo Pastel
    64 + 11 : '\xFF\xFF\xFF'         # Blanco Brillante
}

# Código ejecutable para visualizar imagenes en el cpc
exec_cpc = ['\xf3', '\xed', '\x56', '\x21', '\xfb', '\xc9', '\x22', '\x38',
    '\x00', '\x31', '\x80', '\x11', '\xfb', '\x06', '\xf5', '\xed',
    '\x78', '\x1f', '\x30', '\xfb', '\x06', '\x7f', '\x0e', '\x8c',
    '\xed', '\x49', '\x0e', '\x54', '\xaf', '\xed', '\x79', '\xed',
    '\x49', '\x3c', '\xfe', '\x11', '\x20', '\xf7', '\x06', '\xbc',
    '\x0e', '\x01', '\xed', '\x49', '\x04', '\x0e', '\x30', '\xed',
    '\x49', '\x05', '\x0e', '\x02', '\xed', '\x49', '\x04', '\x0e',
    '\x32', '\xed', '\x49', '\x05', '\x0e', '\x06', '\xed', '\x49',
    '\x04', '\x0e', '\x20', '\xed', '\x49', '\x05', '\x0e', '\x07',
    '\xed', '\x49', '\x04', '\x0e', '\x23', '\xed', '\x49', '\x05',
    '\x0e', '\x0c', '\xed', '\x49', '\x04', '\x0e', '\x2c', '\xed',
    '\x49', '\x05', '\x0e', '\x0d', '\xed', '\x49', '\x04', '\x0e',
    '\x10', '\xed', '\x49', '\xcd', '\x0d', '\x12', '\x06', '\xf5',
    '\xed', '\x78', '\x1f', '\x30', '\xfb', '\xcd', '\xf2', '\x11',
    '\x18', '\xfe', '\x21', '\x4c', '\x12', '\x06', '\x7f', '\x3e',
    '\xff', '\xed', '\x79', '\x4e', '\xed', '\x49', '\x2b', '\x3d',
    '\xfe', '\xff', '\x20', '\xf5', '\x3e', '\x10', '\xed', '\x79',
    '\x3e', '\x54', '\xed', '\x79', '\xc9', '\x11', '\x20', '\x80',
    '\x21', '\x4d', '\x12', '\x3e', '\xa8', '\xd5', '\x01', '\x60',
    '\x00', '\xed', '\xb0', '\xd1', '\xf5', '\xeb', '\x7c', '\xc6',
    '\x08', '\x67', '\xcb', '\x77', '\x28', '\x04', '\x01', '\x60',
    '\xc0', '\x09', '\xeb', '\xf1', '\x3d', '\x20', '\xe6', '\x11',
    '\x00', '\xc0', '\x3e', '\x58', '\xd5', '\x01', '\x60', '\x00',
    '\xed', '\xb0', '\xd1', '\xf5', '\xeb', '\x7c', '\xc6', '\x08',
    '\x67', '\x30', '\x04', '\x01', '\x60', '\xc0', '\x09', '\xeb',
    '\xf1', '\x3d', '\x20', '\xe8', '\xc9']

# Bytes a modificar del ejecutable
bytes_a_cambiar = (0x17, 0x2e, 0x38, 0x42, 0x4c, 0x8e, 0x60, 0x73,
    0x78, 0x91, 0x94, 0xb3, 0x97, 0xa7, 0xb6, 0xc4)
    
# Funciones de conversión de las imagenes
def extrae_paleta(fichero_imagen, modo_imagen):
    """
    Extrae la paleta de la imagen
    """
    paleta_final = {}
    paleta_cpc_valida = True
    if (modo_imagen == "P"):
        paleta_tmp = fichero_imagen.palette.getdata()
        paleta_tmp = paleta_tmp[1]
        cantidad_de_colores = len(paleta_tmp) // 3
        if (cantidad_de_colores > MAX_CPC_COLORS):  # Escogemos los 16 primeros colores
            # print u"La imagen tiene %d colores." % cantidad_de_colores
            cantidad_de_colores = MAX_CPC_COLORS
        for i in range(cantidad_de_colores):
            paleta_aux = paleta_tmp[i*3] + paleta_tmp[i*3+1] + paleta_tmp[i*3+2]
            if (paleta_aux in paleta2cpc):
                paleta_final[paleta_aux] = (i, paleta2cpc[paleta_aux])
            else:
                paleta_final[paleta_aux] = (i, i)
                paleta_cpc_valida = False
    elif (modo_imagen=="RGB") or (modo_imagen=="RGBA"):
        paleta_tmp = fichero_imagen.getcolors(MAX_CPC_COLORS)   # Escogemos los 16 primeros colores
        if (paleta_tmp != None):
            for i in range(len(paleta_tmp)):
                paleta_aux = chr(paleta_tmp[i][1][0]) + \
                    chr(paleta_tmp[i][1][1]) + chr(paleta_tmp[i][1][2])
                if (paleta_aux in paleta2cpc):
                    paleta_final[paleta_aux] = (i, paleta2cpc[paleta_aux])
                else:
                    paleta_final[paleta_aux] = (i, i)
                    paleta_cpc_valida = False
    else:
        print u"Modo no soportado."

    return paleta_final, paleta_cpc_valida

def convierte_paleta_externa(paleta):
    """
    Convierte una paleta externa a formato interno
    """
    paleta_final = {}
    paleta_cpc_valida = True

    for i in range(len(paleta)):
        paleta_final[cpc2paleta[ord(paleta[i])]] = (i, ord(paleta[i]))

    return paleta_final, paleta_cpc_valida
        
def extrae_imagen(fichero_imagen, modo_imagen, ancho_imagen, alto_imagen, paleta, ancho_inversion, ppb): #, indice_paleta):
    """
    Extrae la imagen cruda de la imagen
    """
    imagen_tmp = list(fichero_imagen.getdata())
    if (modo_imagen=="RGB") or (modo_imagen=="RGBA"):
        for i in range(alto_imagen * ancho_imagen):
            imagen_tmp[i] = paleta[chr(imagen_tmp[i][0]) + chr(imagen_tmp[i][1]) + chr(imagen_tmp[i][2])][0]
#        imagen_tmp = [paleta[chr(imagen_tmp[i][0]) + chr(imagen_tmp[i][1]) + chr(imagen_tmp[i][2])][0] 
#            for i in range(alto_imagen * ancho_imagen)]
    elif (modo_imagen != "P"):
        imagen_tmp = []
        print u"Modo no soportado."

#    if indice_paleta:
#        imagen_tmp = [indice_paleta + i for i in imagen_tmp]

    imagen_tmp = map(chr, imagen_tmp)

    # FIX: Hay un problema en la inversión, cuando indice_paleta > 0
    imagen_final = []
    if (ancho_inversion):
        ai_ppb = ancho_inversion * ppb
        for i in range(0, len(imagen_tmp), ancho_imagen):
            # Inversión de los graficos
#            for j in reversed(range(ancho_imagen)):
#                imagen_final += imagen_tmp[i + j]
            for j in reversed(range(ancho_imagen // ai_ppb)):
#                print len(imagen_tmp[i + j * ai_ppb: i + (j + 1) * ai_ppb]),
                imagen_final += imagen_tmp[i + j * ai_ppb: i + (j + 1) * ai_ppb]
    else:
        imagen_final = imagen_tmp

#    for i in range(len(imagen_final)):
#        print '%x' % ord(imagen_final[i]),

    return imagen_final

def extrae_mapa(imagen, ancho_patron, alto_patron, ancho_imagen, alto_imagen):
    """
    Extrae el mapa de la imagen
    """
    mapa_final = []
    mapa_tmp = ""
    fila_patrones = ancho_imagen * alto_patron
    for imagen_y in range(alto_imagen // alto_patron):
        for imagen_x in range(ancho_imagen // ancho_patron):
            for patron_y in range(alto_patron):
                for patron_x in range(ancho_patron):
                    mapa_tmp = mapa_tmp + imagen[imagen_y * fila_patrones + patron_y * ancho_imagen +
                                                 imagen_x * ancho_patron + patron_x]
            mapa_final.append(mapa_tmp)
            mapa_tmp = ""
    return mapa_final
    
def extrae_patrones(mapa):
    """
    Extrae los patrones del mapa
    """
    tiles_final = {}
    for i in range(len(mapa)):
        hash_tmp = hashlib.sha1(mapa[i]).digest()
        if not (tiles_final.has_key(hash_tmp)):
            tiles_final[hash_tmp] = (mapa[i], len(tiles_final), 1)
        else:    # Almacenamos el número de repeticiones
            tiles_final[hash_tmp] = (tiles_final[hash_tmp][0], tiles_final[hash_tmp][1], tiles_final[hash_tmp][2] + 1)
#    for i in tiles_final.keys():
#        print tiles_final[i][2]
    return tiles_final

def extrae_sprite(fichero_imagen):
    """
    Extrae los sprites de la imagen
    """
    sprites_final = []
    return sprites_final

# Funciones de optimización de los datos generados
def optimiza_paleta(paleta):
    """
    Optimiza la paleta
    """
    paleta_final = [""] * len(paleta)

    for i in paleta.keys():
        paleta_final[paleta[i][0]] = chr(paleta[i][1])
    return paleta_final
    
def optimiza_mapa(mapa, patrones):
    """
    Optimiza el mapa
    """
    mapa_final = []
    for i in range(len(mapa)):
        mapa_final.append(chr(patrones[hashlib.sha1(mapa[i]).digest()][1]))
    return mapa_final

def optimiza_patrones(patrones, ppb):
    """
    Optimiza los patrones
    """
    patrones_final = [""] * len(patrones)

    for i in patrones.keys():
        patrones_final[patrones[i][1]] = convierte_graficos(patrones[i][0], ppb)
    return patrones_final

def optimiza_casillas(casillas):
    """
    Optimiza las casillas
    """
    casillas_final = [""] * len(casillas)

    for i in casillas.keys():
        casillas_final[casillas[i][1]] = casillas[i][0]
    return casillas_final

def convierte_graficos(cadena, ppb):
    """
    Convierte una cadena de bytes a un modo del CPC
    """
    cadena_final = ""
    for i in range(len(cadena) // ppb):
        if ppb == 2:
            byte_tmp0 = cadena[i * ppb]
            byte_tmp1 = cadena[i * ppb + 1]
#            byte_tmp0 = ord(cadena[i * ppb]) # & 0x0F
#            byte_tmp1 = ord(cadena[i * ppb + 1]) #& 0x0F
            # p1b3->b0 p1b2->b4
            # p1b1->b2 p1b0->b6
            # p0b3->b1 p0b2->b5
            # p0b1->b3 p0b0->b7
            byte_tmp = chr(((ord(byte_tmp1) & 0x08) >> 3) | ((ord(byte_tmp1) & 0x04) << 2) | \
                        ((ord(byte_tmp1) & 0x02) << 1) | ((ord(byte_tmp1) & 0x01) << 6) | \
                        ((ord(byte_tmp0) & 0x08) >> 2) | ((ord(byte_tmp0) & 0x04) << 3) | \
                        ((ord(byte_tmp0) & 0x02) << 2) | ((ord(byte_tmp0) & 0x01) << 7))
#            byte_tmp = chr(((byte_tmp1 & 0x08) >> 3) | ((byte_tmp1 & 0x04) << 2) | \
#                        ((byte_tmp1 & 0x02) << 1) | ((byte_tmp1 & 0x01) << 6) | \
#                        ((byte_tmp0 & 0x08) >> 2) | ((byte_tmp0 & 0x04) << 3) | \
#                        ((byte_tmp0 & 0x02) << 2) | ((byte_tmp0 & 0x01) << 7))
        elif ppb == 4:
            byte_tmp0 = cadena[i * ppb]
            byte_tmp1 = cadena[i * ppb + 1]
            byte_tmp2 = cadena[i * ppb + 2]
            byte_tmp3 = cadena[i * ppb + 3]
            # p3b1->b0 p3b0->b4
            # p2b1->b1 p2b0->b5
            # p1b1->b2 p1b0->b6
            # p0b1->b3 p0b0->b7
            byte_tmp = chr(((ord(byte_tmp3) & 0x02) >> 1) | ((ord(byte_tmp3) & 0x01) << 4) | \
                        ((ord(byte_tmp2) & 0x02)) | ((ord(byte_tmp2) & 0x01) << 5) | \
                        ((ord(byte_tmp1) & 0x02) << 1) | ((ord(byte_tmp1) & 0x01) << 6) | \
                        ((ord(byte_tmp0) & 0x02) << 2) | ((ord(byte_tmp0) & 0x01) << 7))
        elif ppb == 8:
            byte_tmp0 = cadena[i * ppb]
            byte_tmp1 = cadena[i * ppb + 1]
            byte_tmp2 = cadena[i * ppb + 2]
            byte_tmp3 = cadena[i * ppb + 3]
            byte_tmp4 = cadena[i * ppb + 4]
            byte_tmp5 = cadena[i * ppb + 5]
            byte_tmp6 = cadena[i * ppb + 6]
            byte_tmp7 = cadena[i * ppb + 7]
            # p7b0->b0 p6b0->b1
            # p5b0->b2 p4b0->b3
            # p3b0->b4 p2b0->b5
            # p1b0->b6 p0b0->b7
            byte_tmp = chr(((ord(byte_tmp7) & 0x01)) | ((ord(byte_tmp6) & 0x01) << 1) | \
                        ((ord(byte_tmp5) & 0x01) << 2) | ((ord(byte_tmp4) & 0x01) << 3) | \
                        ((ord(byte_tmp3) & 0x01) << 4) | ((ord(byte_tmp2) & 0x01) << 5) | \
                        ((ord(byte_tmp1) & 0x01) << 6) | ((ord(byte_tmp0) & 0x01) << 7))
        cadena_final = cadena_final + byte_tmp
    return cadena_final

# Generamos el ejecutable    
def construye_ejecutable(imagen, paleta, ancho_imagen, alto_imagen, modo):
    """
    Genera un ejecutable con la palete y la imagen
    """
    contador = 0
    copia_exec = exec_cpc
    
    # Cambiamos el modo de pantalla
    copia_exec[bytes_a_cambiar[contador]] = chr(0x8C + modo)
    contador = contador + 1
    
    # Ancho de pantalla
    ancho_en_bytes = ancho_imagen // pixels_por_byte[modo]
    copia_exec[bytes_a_cambiar[contador]] = chr(ancho_en_bytes // 2)
    contador = contador + 1

    # Desplazamiento horizontal
    copia_exec[bytes_a_cambiar[contador]] = chr(26 + (ancho_imagen // (8 * (pixels_por_byte[modo] // 2))))
    contador = contador + 1

    # Alto de pantalla
    copia_exec[bytes_a_cambiar[contador]] = chr(alto_imagen // 8)
    contador = contador + 1

    # Desplazamiento vertical
    copia_exec[bytes_a_cambiar[contador]] = chr(16 + (alto_imagen // 14))
    contador = contador + 1

    # Inicio de la vram con scroll (máximo 1 byte)
    inicio_vram = 2048 % ancho_en_bytes
    copia_exec[bytes_a_cambiar[contador]] = chr(inicio_vram)
    contador = contador + 1
    
    # Scroll_horizontal
    copia_exec[bytes_a_cambiar[contador]] = chr(inicio_vram // 2)
    contador = contador + 1

    # Dirección del final de la paleta - 1 (son dos bytes)
    dir_final_paleta = 0x124d + len(paleta) - 1
    copia_exec[bytes_a_cambiar[contador]] = chr(dir_final_paleta & 0x00FF)
    copia_exec[bytes_a_cambiar[contador] + 1] = chr((dir_final_paleta & 0xFF00) >> 8)
    contador = contador + 1
    
    # Número de colores - 1
    copia_exec[bytes_a_cambiar[contador]] = chr(len(paleta) - 1)
    contador = contador + 1

    # Dirección de la pantalla (son dos bytes)
    dir_pantalla = dir_final_paleta + 1
    copia_exec[bytes_a_cambiar[contador]] = chr(dir_pantalla & 0x00FF)
    copia_exec[bytes_a_cambiar[contador] + 1] = chr((dir_pantalla & 0xFF00) >> 8)
    contador = contador + 1

    # Número de scanlines de la primera mitad de la imagen
    scanlines_primera_mitad = (2048 // ancho_en_bytes) * 8
    if (scanlines_primera_mitad > alto_imagen):
        scanlines_primera_mitad = alto_imagen
    copia_exec[bytes_a_cambiar[contador]] = chr(scanlines_primera_mitad)
    contador = contador + 1

    # Número de scanlines de la segunda mitad de la imagen
    copia_exec[bytes_a_cambiar[contador]] = chr(alto_imagen - scanlines_primera_mitad)
    contador = contador + 1

    # Ancho de la imagen en bytes (4 veces)
    copia_exec[bytes_a_cambiar[contador]] = chr(ancho_en_bytes)
    contador = contador + 1
    copia_exec[bytes_a_cambiar[contador]] = chr(ancho_en_bytes)
    contador = contador + 1
    copia_exec[bytes_a_cambiar[contador]] = chr(ancho_en_bytes)
    contador = contador + 1
    copia_exec[bytes_a_cambiar[contador]] = chr(ancho_en_bytes)
    contador = contador + 1

    # Se le añade la paleta
    copia_exec = copia_exec + paleta

    # Se le añade la imagen
    imagen = "".join(copia_exec) + imagen
    
    return imagen

# Funciones para guardar en disco los datos convertidos
def guarda_archivo(nombre, contenido):
    """
    Guarda un archivo en en disco
    """
    with open(nombre,"wb") as fichero:
        fichero.write(contenido)

# Procesa la línea de comandos    
def procesar_linea_comandos(linea_de_comandos):
    """
    Devuelve una tupla de dos elementos: (opciones, lista_de_ficheros).
    `linea_de_comandos` es una lista de argumentos, o `None` para ``sys.argv[1:]``.
    """
    if linea_de_comandos is None:
        linea_de_comandos = sys.argv[1:]

    version_programa = "%prog v0.5"
    uso_programa = "usage: %prog [options] img1.png img2.png ... imgX.png"
    descripcion_programa = "%prog convert images in png format to binary data for Amstrad CPC."

    # definimos las opciones que soportaremos desde la lnea de comandos
    lista_de_opciones = [
        make_option("-e", "--exec", action="store_true", dest="executable", default=False, help="Generate executable"),
        make_option("-i", "--inverse", action="store", type="int", dest="inverse_width", default=0, help="Select inverse mode width (12, 16, ...)"),
#        make_option("-l", "--loadpal", action="store", dest="load_palette", default="", help="Load external palette"),
        make_option("-m", "--map", action="store_true", dest="map", default=False, help="Generate map"),
#        make_option("-n", "--index", action="store", type="int", dest="index", default=0, help="Select index begin palette (0-15)"),
        make_option("-p", "--palette", action="store_true", dest="palette", default=False, help="Generate palettes"),
        make_option("-r", "--mode", action="store", type="int", dest="mode", default=0, help="Select screen mode (0, 1, 2)"),
        make_option("-s", "--sprite", action="store_true", dest="sprite", default=False, help="Generate sprites"),
        make_option("-t", "--tile", action="store_true", dest="tile", default=False, help="Generate tiles"),
        make_option("-X", "--map_width", action="store", type="int", dest="ancho_casilla", default=1, help="Tilemap width"),
        make_option("-Y", "--map_height", action="store", type="int", dest="alto_casilla", default=1, help="Tilemap height"),
        make_option("-x", "--tile_width", action="store", type="int", dest="ancho_patron", default=8, help="Tile width"),
        make_option("-y", "--tile_height", action="store", type="int", dest="alto_patron", default=8, help="Tile height")
    ]
        
    parser = OptionParser(usage=uso_programa, description=descripcion_programa,
        version=version_programa, option_list=lista_de_opciones)
    
    # obtenemos las opciones y la lista de ficheros suministradas al programa
    (opciones, lista_ficheros_tmp) = parser.parse_args(linea_de_comandos)

    # comprobamos el número de argumentos y verificamos los valores
    if (not lista_ficheros_tmp):
        parser.error("No files to process.")
    else:
        lista_ficheros = []
        for i in lista_ficheros_tmp:
            lista_ficheros = lista_ficheros + glob.glob(i)
    if (opciones.mode < 0) or (opciones.mode > 2):
        parser.error("Screen mode is out of range.")
    if (opciones.ancho_patron < 1):
        parser.error("Tile width invalid.")
    if (opciones.alto_patron < 1):
        parser.error("Tile height invalid.")

    return opciones, lista_ficheros

# Función principal
def main(linea_de_comandos=None):
    """
    Función principal
    """
    # obtenemos las opciones y argumentos suministrados al programa
    opciones, lista_ficheros = procesar_linea_comandos(linea_de_comandos)

    #print opciones, lista_ficheros        # DEBUG
    for nombre_imagen in lista_ficheros:
        
        if not(os.path.exists(nombre_imagen)):
            print u"El fichero %s no existe." % nombre_imagen
            continue
            
        print u"Abriendo el fichero de imagen: " + nombre_imagen
        fichero_imagen = Image.open(nombre_imagen)
        
        # Dimensiones de la imagen
        ancho_imagen, alto_imagen = fichero_imagen.size
        print u"Tamaño en pixels de la imagen: %d x %d" % (ancho_imagen, alto_imagen)
        ancho, alto = ancho_imagen // opciones.ancho_patron, alto_imagen // opciones.alto_patron
        print u"Tamaño en patrones de la imagen: %d x %d" % (ancho, alto)

        # Características de la imagen
        modo_imagen = fichero_imagen.mode
        #print u"Modo de la imagen:", modo_imagen

        # Generamos la paleta
        paleta, paleta_cpc_valida = extrae_paleta(fichero_imagen, modo_imagen)

#        if (opciones.load_palette == ""):
#            paleta, paleta_cpc_valida = extrae_paleta(fichero_imagen, modo_imagen)
#        else:
#            if not(os.path.exists(opciones.load_palette)):
#                print u"El fichero %s no existe." % opciones.load_palette
#                opciones.load_palette = ""
#                continue
#            else:
#                with open(opciones.load_palette,'r') as f:
#                    paleta = f.read()
#                    paleta, paleta_cpc_valida = convierte_paleta_externa(paleta)
        
        print u"Número de colores: %d" % len(paleta)

        if (opciones.palette and (not opciones.executable)):
            if (paleta_cpc_valida):
                guarda_archivo((nombre_imagen.lower()).replace(".png",".pal"), "".join(optimiza_paleta(paleta)))
            else:
                print u"El fichero %s no tiene una paleta de cpc válida." % nombre_imagen

        if not opciones.sprite:
            fichero_imagen.load()    # Cargamos el fichero en memoria
            imagen = extrae_imagen(fichero_imagen, modo_imagen, ancho_imagen, alto_imagen, paleta, opciones.inverse_width, pixels_por_byte[opciones.mode]) #, opciones.index)
            if not (opciones.map or opciones.tile):
                imagen = convierte_graficos(imagen, pixels_por_byte[opciones.mode])        # Se convierten los bytes a formato cpc
                if (opciones.executable):
                    if (paleta_cpc_valida):
                        executable = construye_ejecutable(imagen, optimiza_paleta(paleta), ancho_imagen, alto_imagen, opciones.mode)
                        guarda_archivo((nombre_imagen.lower()).replace(".png",".bin"), "".join(executable)) 
                    else:
                        print u"El fichero %s no tiene una paleta de cpc válida." % nombre_imagen
                else:
                    guarda_archivo((nombre_imagen.lower()).replace(".png",".scr"), imagen) 
            else:
                mapa = extrae_mapa(imagen, opciones.ancho_patron, opciones.alto_patron, ancho_imagen, alto_imagen)

                print u"Tamaño del mapa: %d bytes" % len(mapa)
                
                patrones = extrae_patrones(mapa)
                print u"Número de patrones: %d" % len(patrones)
                print u"Tamaño del patrón: %d bytes" % (opciones.alto_patron * opciones.ancho_patron // \
                    pixels_por_byte[opciones.mode])
                
                if (len(patrones) > 256):
                    print u"Hay más de 256 patrones, usa --force si es lo que deseas. (FORCE no está implementado aún)"
                    continue
                if opciones.map:
                    mapa = optimiza_mapa(mapa, patrones)
                    if (opciones.alto_casilla == opciones.ancho_casilla == 1):
                        guarda_archivo((nombre_imagen.lower()).replace(".png",".map"), "".join(mapa)) 
                    else:
                        mapa = extrae_mapa(mapa, opciones.ancho_casilla, opciones.alto_casilla, ancho, alto)
                        print u"Tamaño del mapa con casillas: %d bytes" % len(mapa)
                        casillas = extrae_patrones(mapa)
                        print u"Número de casillas: %d" % len(casillas)
                        print u"Tamaño de la casilla: %d bytes" % (opciones.alto_casilla * opciones.ancho_casilla)
                        guarda_archivo((nombre_imagen.lower()).replace(".png",".map"), "".join(optimiza_mapa(mapa, casillas)))
                        guarda_archivo((nombre_imagen.lower()).replace(".png",".lst"), "".join(optimiza_casillas(casillas)))  
                if opciones.tile: 
                    guarda_archivo((nombre_imagen.lower()).replace(".png",".pat"), "".join(optimiza_patrones(patrones, \
                        pixels_por_byte[opciones.mode]))) 
        else:
            sprites = extrae_sprite(fichero_imagen)
            #guarda_archivo((nombre_imagen.lower()).replace(".png",".spr"), "".join(optimiza_sprites(sprites, \
            #   pixels_por_byte[opciones.mode])))

    return 0    # EXIT_SUCCESS

if __name__ == "__main__":
    estado = main()
    sys.exit(estado)

# Estructura de un módulo en python
#"""Cadena de documentacion del modulo"""
#
# imports
# constantes
# clases de tipo excepcion
# funciones para uso publico
# clases
# funciones y clases internas 
#
#def main(...):
#
#
#if __name__ == '__main__':
#    estado = main()
#    sys.exit(estado)
