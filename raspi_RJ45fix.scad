// Raspberry Pi fixture for 3D printing
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
             c=0.075;   // clearance / toleranz in mm
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}


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

//------------- Instances --------------------

rj45case();

