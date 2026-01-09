# triangle.py
#   create a triangle with inscribed triangle to fold a tetraeder.
#
# run:
#   python triangle.py 
#
# Background:
#   - simple test to try to cut triangles with a Laser cutter
#   - pretty-print:
#     xmllint --format triangle.svg > triangle.svg.example
#   - repo: 
#     git@github.com:Github6am/am_parts3D.git
#   - Prerequisites:
#     sudo apt install python3-svg.path python3-svgwrite
#   - docs: 
#     https://pypi.org/project/svgwrite/
#     https://pypi.org/project/svg.path
#     https://svgwrite.readthedocs.io/en/latest/classes/drawing.html

import svgwrite

#from svg.path import Path, Move, Line, Arc, CubicBezier, QuadraticBezier, Close
#from svg.path import parse_path

# the drawing output file
dwg = svgwrite.Drawing('triangle.svg', profile='tiny')

tri0='M 100,100 L 300,100 L 200,300 Z'  # test

h=0.866025403784439  # sqrt(3)/2

# first, outer Triangle
scale=100          # the length of a triangle side
x0=2  # offset x
y0=2  # offset y

x1=(0   *scale + x0);   y1=(0 *scale + y0)
x2=(1   *scale + x0);   y2=(0 *scale + y0)
x3=(1/2 *scale + x0);   y3=(h *scale + y0)
tri1=f'M {x1:>7.3f} {y1:>7.3f} L {x2:>7.3f} {y2:>7.3f} L {x3:>7.3f} {y3:>7.3f} Z'

# second, inner Triangle, half length, quarter area
X0=x0
Y0=y0 + h/2*scale
x1=(1/2 *scale + X0);   y1=(-h/2 *scale + Y0)
x2=(1/4 *scale + X0);   y2=(0 *scale + Y0)
x3=(3/4 *scale + X0);   y3=(0 *scale + Y0)
tri2=f'M {x1:>7.3f} {y1:>7.3f} L {x2:>7.3f} {y2:>7.3f} L {x3:>7.3f} {y3:>7.3f} Z'


print(tri1)
print(tri2)

dwg.add(dwg.path(d=tri1, stroke='red', stroke_width='1', fill='yellow'))
dwg.add(dwg.path(d=tri2, stroke='blue', stroke_width='1', fill='none'))

dwg.save()



