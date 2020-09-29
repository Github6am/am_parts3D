// Wandhalterung fuer Licht-Fernbedienung - wall mount
// 
// 
// Background:
//   - immer verlegt man die Fernbedienung. Und wenn es dunkel im Raum
//     ist, dann sollte die Fernbedienung genau an der Wand 
//     neben dem Lichtschalter sein,
//     sonst findet man sie nicht, weil es ja dunkel ist ;-)
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-07-29, v0.2 
// GPLv3 or later, see http://www.gnu.org/licenses



// Main dimensions
xin=39.5;      // inner width
yin=15;        // inner width
zin=40;        // inner height
wall=1.2;      // wall thickness of printed part
clr=0.4;       // clearance

//-------------------------------------------
// drill
//-------------------------------------------

// cone+cylinder

module ccyl(h1=wall, h2=wall, r1=2, ang=-45) {
    ss=(r1-h2*tan(ang))/r1;
    rotate([-90,0,0]) translate([0,0,-0.01])
    union() {
      linear_extrude(height=h1, scale=1)  circle(r=r1,$fn=24);
      translate([0,0,h1])
        linear_extrude(height=h2, scale=ss) circle(r=r1, $fn=24);
      translate([0,0,h1+h2])
        linear_extrude(height=yin-h1-h2+2*wall+1, scale=1) circle(r=r1*ss, $fn=24);
    }
}


//-------------------------------------------
// enclosure for Hallsensor board and wire
//-------------------------------------------
module Wandhalterung_2Dhalf() {
    r=2;             // chamfer inner radius
    w=wall;          // w: wall thickness
    x=xin/2;         // half rc width
    y=yin;           // inner y dimension
    t=(1-tan(45/2));
    // outer contour
    polygon( points=[
       // outer contour
       [0,0], [x+w, 0],
       [x+w, y+2*w-(r+w)*t], [x+w-(r+w)*t, y+2*w], [0, y+2*w],
       // inner contour
       [0, y+w], [x-r*t, y+w], [x, y+w-r*t], [x, 0+2*w], 
       [x-10, 0+2*w], [x-10, 0+2*w], [x-10, 0+w], [0, 0+w]
       ]);

}

module Wandhalterung_2D() {
  union() {
    Wandhalterung_2Dhalf();
    mirror([1,0,0]) 
    Wandhalterung_2Dhalf();
  }
}

module Wandhalterung_3D() {
  union() {
  linear_extrude(height = zin) Wandhalterung_2D();
  }
}

module Wandhalterung_A() {
  x=xin/2;         // half rc width
  difference() {
    union() {
      linear_extrude(height = zin) Wandhalterung_2D();
      linear_extrude(height = wall) hull() Wandhalterung_2D();
    }
    union() {
      translate([-(x-5),0,5+xin*1/2]) ccyl();
      translate([ (x-5),0,5+xin*1/2]) ccyl();
      // cut a hole in the bottom to prevent dirt accumulation
      translate([  0,yin/2+1,0]) cube([xin-10, yin-5, 3*wall], center=true);
    }
  }
}


//------------- Instances --------------------

Wandhalterung_A();
