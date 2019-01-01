// Raspberry Pi fixture for 3D printing
// 
// Attach to the RJ45 case, if using the mounting holes is not an option.
// one screw fixture is possible for Raspberry Pi 2
// 
// Andreas Merz 30.12.2018, v0.2, GPL

// 
function ellipse(r1, r2, num=32) = 
  [for (i=[0:num-1], a=i*360/num) [ r1*cos(a), r2*sin(a) ]];

//-------------------------------
//       w2
//    ---------
//    \       /  h
//     ---+---
//       w1
//-------------------------------

module schwalbenschwanz(h=2, w1=4, w2=6) {
             //w1=(w2-h*tan(30));      // Flankenwinkel 30 deg
             c=0.12;   // clearance / spiel in mm
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}

/*
// old approach using complex polygon
module rj45case(h=16.5, w=2.5) {
    union() {
      linear_extrude(height = h)    // case
        union() {
          polygon( points=[[0,0],[w+1.5,0],[w+1.5,w],[w,w],[w,21.5+w],[16+w,21.5+w],[16+w,w],[16+w-1.5,w],[16+w-1.5,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);
          translate([16+2*w,6,0])    rotate(-90) schwalbenschwanz();
          translate([16+2*w,14+6,0]) rotate(-90) schwalbenschwanz();
        }
      linear_extrude(height = 3)    // bottom plate
        polygon( points=[[0,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);     
    }
}
*/

module rj45case(h=16.5, w=2.5, PiVersion=1) {
    // h: overall height, including bottom wall
    // w: wall thickness
    // wb: bottom wall
    // PiVersion:  Raspberry Pi version
    c=0.05;      // clearance - spiel in mm im Gehaeuse
    b=2.8-w;     // board edge excess, Pi2 has 3mm from RJ45 to board edge
    wb=2.5;      // bottom 
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[16+2*w+b,0],[16+2*w+b,21.5+2*w],[0,21.5+2*w]]);  // outer rectangle
              polygon( points=[[w-c,w-c],[16+w+c,w-c],[16+w+c,21.5+w+c],[w-c,21.5+w+c]]);          // inner rectangle
            }
            if (PiVersion == 2) {
              // Raspberry Pi 2 only: add Screw fixture
              translate([16+2*w-6.5,21.5+2*w,0]) square([6.5+b, 5]);
            }
            // right interface
            translate([16+2*w+b,8,0])    rotate(-90) schwalbenschwanz();
            translate([16+2*w+b,10+8,0]) rotate(-90) schwalbenschwanz();
            // left interface
            if (PiVersion == 1) {
              translate([0,0*10+3,0]) rotate(90) schwalbenschwanz(); // no space for Pi2
              translate([0,1*10+3,0]) rotate(90) schwalbenschwanz();
            }
            translate([0,1*20+3,0]) rotate(90) schwalbenschwanz();
          }
        linear_extrude(height = wb)    // bottom plate
          polygon( points=[[0,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);     
      }
      union() {
          translate([w+1.5,-1,2+wb])
            linear_extrude(height = h)    // RJ45 breakout
              square( [13, 6]);
          translate([w+1.5,21.5-1+w,h-2.5])
            linear_extrude(height = h)    // breakout for SMD parts 
              square( [13, 4]);
          translate([-3,-1, h-2.5])
            linear_extrude(height = h)    // breakout for SMD capacitor in Pi2 
              square( [3+w-2, 28]);
          translate([14.8+w,21.5+w+4.3,0])
            linear_extrude(height = h+1)  // hole for mounting screw
              circle(1.2, $fn=4);
          translate([w+16/2,w+21.5/2,-1])
            linear_extrude(height = h+1)  // save material in bottom
              square([2*(w+16/2-5),2*(w+21.5/2-6)],center=true);
      }
    }
}


// wall fixture
module rj45fixture(h=16.5, w=2.5, l=50) {
    // h: overall height, including bottom wall
    // w: wall thickness
    // l: length to mount point
    // wb: bottom wall
    wb=2.5;      // bottom 
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[l,0],[l,30],[0,30]]);  // outer rectangle
              polygon( points=[[w,w],[l-w,w],[l-w,30-w],[w,30-w]]);  // inner rectangle
            }
            // left interface
            translate([0,0*10+3,0]) rotate(90) schwalbenschwanz();
            translate([0,1*10+3,0]) rotate(90) schwalbenschwanz();
            translate([0,1*20+3,0]) rotate(90) schwalbenschwanz();
          }
          linear_extrude(height = wb)    // bottom plate
            polygon( points=[[0,0],[l,0],[l,30],[0,30]]);  // outer rectangle
      }
      union() {
          translate([l/2,-1,2*wb])
            linear_extrude(height = h-2*wb+1, scale=1.5)    // save material in wall
              square( [(l-2*w)/1.5, 2*30+2*w], center=true);
          translate([l/2,30/2,-1])
            linear_extrude(height = h+1)  // save material in bottom
              //polygon(ellipse(l*0.4,30*1/3));
              square([2*(l/2-7), 2*(30/2-6)], center=true);
              square([2*(w+16/2-5),2*(w+21.5/2-6)],center=true);
          translate([l-10,30*3/4,h/2])       // mounting hole 4mm
            rotate([0,90,0])
              linear_extrude(height = 20)
                circle(4/2,$fn=32);
          translate([l-10,30*1/4,h/2])       // mounting hole 4mm
            rotate([0,90,0])
              linear_extrude(height = 20)
                circle(4/2,$fn=32);
      }
    }
  }


//------------- Instances --------------------

translate([-26,0,0])
rj45case();

//rj45case(PiVersion=2);

//rj45fixture();

