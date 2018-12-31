// Raspberry Pi fixture for 3D printing
//
// screw fixture is possible for Raspberry Pi 2
// 
// Andreas Merz 30.12.2018, v0.1, GPL


//-------------------------------
//       w2
//    ---------
//    \       /  h
//     ---+---
//       w1
//-------------------------------

module schwalbenschwanz(h=3, w1=6, w2=8) {
             //w1=(w2-h*tan(30));      // Flankenwinkel 30 deg
             c=0.1;   // clearance / spiel in mm
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}

/*
module rj45case(h=16, w=2.5) {
    union() {
      linear_extrude(height = h)    // case
        union() {
          polygon( points=[[0,0],[w+1.5,0],[w+1.5,w],[w,w],[w,21.5+w],[16+w,21.5+w],[16+w,w],[16+w-1.5,w],[16+w-1.5,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);
          translate([16+2*w,6,0]) rotate(-90) schwalbenschwanz();
          translate([16+2*w,14+6,0]) rotate(-90) schwalbenschwanz();
        }
      linear_extrude(height = 3)    // bottom plate
        polygon( points=[[0,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);     
    }
}
*/

module rj45case(h=16.5, w=2.5) {
    // h: overall height, including 3mm base plate
    // w: wall thickness
    // wb: bottom wall
    c=0.05;      // clearance - spiel in mm
    b=0.3;       // board edge excess, 2.8mm - w
    wb=2.5;      // bottom 
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[16+2*w+b,0],[16+2*w+b,21.5+2*w],[0,21.5+2*w]]);  // outer rectangle
              polygon( points=[[w-c,w-c],[16+w+c,w-c],[16+w+c,21.5+w+c],[w-c,21.5+w+c]]);          // inner rectangle
            }
            // Raspberry Pi 2 only: add Screw fixture
            translate([16+2*w-6.3,21.5+2*w,0]) square([6.3+b, 5]);
            
            // interface
            translate([16+2*w+b,6,0]) rotate(-90) schwalbenschwanz();
            translate([16+2*w+b,14+6,0]) rotate(-90) schwalbenschwanz();
          }
        linear_extrude(height = wb)    // bottom plate
          polygon( points=[[0,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);     
      }
      union() {
          translate([w+1.5,-1,2+3])
            linear_extrude(height = h)    // RJ45 breakout
              square( [13, 6]);
          translate([w+1.5,21.5-1+w,h-1])
            linear_extrude(height = h)    // breakout for SMD parts 
              square( [13, 4]);
          translate([14.8+w,21.5+w+4.3,0])
            linear_extrude(height = h+1)  // hole for mounting screw
              circle(1, $fn=4);
      }
    }
}

//------------- Instances --------------------

rj45case();

