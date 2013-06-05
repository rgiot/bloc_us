#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
AUTHOR Krusty/Benediction
Afficheur de courbe
"""

from math import cos, sin, pi
import numpy as np
from scipy.interpolate import interp1d, UnivariateSpline

import pylab as plt

# Calcule la courbe
values = []

for index in np.linspace(0, 2*pi, 256):
    val = cos(index)*100 + sin(index*3)*50 + cos(index*4)*25
    values.append(val)

mul = 32#5

X = range(len(values))
values = np.asarray(values)
values = values/float(max(values)) * mul  #+ mul
values = [int(val) for val in values]
plt.figure()
plt.plot(X, values)
plt.show()

for val in values :
    print "\tdb %d" %min(255,val)




values = []

for index in np.linspace(0, 2*pi, 256):
    val = cos(index)*100 
    values.append(val)

mul = 64#5

X = range(len(values))
values = np.asarray(values)
values = values/float(max(values)) * mul  #+ mul
values = [int(val) for val in values]
plt.figure()
plt.plot(X, values)
plt.show()

for val in values :
    print "\tdb %d" %min(255,val)



values = []

for index in np.linspace(0, 2*pi, 256):
    val = cos(index)*100 
    values.append(val)

mul = 32#5

X = range(len(values))
values = np.asarray(values)
values = values/float(max(values)) * mul  #+ mul
values = [abs(int(val)) for val in values]
plt.figure()
plt.plot(X, values)
plt.show()

for val in values :
    print "\tdb %d" %min(255,val)



values = []

for index in np.linspace(0, 2*pi, 256):
    val = cos(2*index)*100  + sin(index)*5
    values.append(val)

mul = 50#5

X = range(len(values))
values = np.asarray(values)
values = values/float(max(values)) * mul  #+ mul
values = [int(val) for val in values]
plt.figure()
plt.plot(X, values)
plt.show()

for val in values :
    print "\tdb %d" %min(255,val)


