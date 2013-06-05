#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
AUTHOR Romain Giot <romain.giot@ensicaen.fr>
"""

import pylab
import numpy as np

DURATION = 256
AMPLITUDE = 16*8

def get_values_cos(frequency, amplitude):
    return amplitude*np.cos(frequency*np.linspace(0, 2*np.pi, DURATION))

def get_values_sin(frequency, amplitude):
    return amplitude*np.sin(frequency*np.linspace(0, 2*np.pi, DURATION))

def get_values(curve):
    amplitude = curve[2]
    frequency = curve[1]
    method = curve[0]

    func_dict = {'cos': get_values_cos, 'sin': get_values_sin}

    return func_dict[method](frequency, amplitude)

def build_curve(curves):
    values = get_values(curves[0])

    for curve in curves[1:]:
        values = values + get_values(curve)

    return values

def normalize(curve, maxval, minval=0):
    return [int(val) for val in maxval/2.0*(1+curve/np.max(curve))]

def print_curve(curve):
    print "\n".join("\tdb %d" % (val%8) for val in curve)

curves = (
        ('sin', 1, 1000),
        )


values = normalize(build_curve(curves), AMPLITUDE)
print_curve(values)

pylab.figure()
pylab.plot(values)
pylab.show()
