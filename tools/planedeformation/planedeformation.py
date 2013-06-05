#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
AUTHOR Krusty/Benediction

Build display routines for plane deformation.




cos(a)/r
sin(a)/r


.5*a/pi
sin(7*r) 


(-0.4/r)+.1*sin(8*a)
.5 + .5*a/pi


.2/abs(y)
.2*x/abs(y)


"""

import numpy as np

def compute_deformation(width=96/2, height=20*2):
    """Compute the deformation to apply to the texture."""
    deformationx = []
    deformationy = []

    for i in range(height):
        for j in range(width):
            deformationy.append([j] * width)
            deformationx.append(range(width))

    return np.array(deformationx), np.array(deformationy)

def build_code(deformation):
    """Build the code for each line"""

    def emit_code(code):
        return "\t" + code + "\n"

    asm = []
    i=0
    for linex, liney in zip(deformation[0], deformation[1]):
        i = i +1
        startx, starty = linex[0], liney[0]
        linex_delta = linex[1:] - linex[:-1]
        liney_delta = liney[1:] - liney[:-1]

        asm_line = "; Line %d" % i
        asm_line = emit_code(';Compute texture line start')
        asm_line = emit_code('ld hl, TEXTURE')
        asm_line = emit_code('ld de, 256*%d + %d' % (starty, startx))
        asm_line = emit_code('ld a, h: add d: ld h, a')
        asm_line = emit_code('ld a, l: add e: ld l, a')

        asm_line = emit_code(';Compute screen adresses')
        asm_line = emit_code('\tSELECT_SCREEN_TO_WORK %d' % (i%2))

        asm_line = emit_code(';Compute delta over line')
        nb_x = 0
        for deltax, deltay in zip(linex_delta, liney_delta):
            nb_x = nb_x + 1
            assert nb_x <= 96/2
            asm_line += emit_code('ld e, (hl)')
            asm_line += emit_code('ld d, e')
            asm_line += emit_code('push de')

            if deltax == 0:
                asm_line += emit_code('nop')
            elif deltax > 0:
                asm_line += emit_code('inc l')
            else:
                asm_line += emit_code('dec l')

            if deltay == 0:
                asm_line += emit_code('nop')
            elif deltay > 0:
                asm_line += emit_code('inc l')
            else:
                asm_line += emit_code('dec l')

        asm.append(asm_line)

    return asm

deformation = compute_deformation()
code = build_code(deformation)
print "".join(code)
