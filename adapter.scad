// Adapters for various purposes
// 
// 
// Background:
//   - Adapter for Head Magnifying glasses
//     Rightwell Eyeglasses No.9892B2 from choiko@outlook.com
//     to combine two lenses
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2023-01-19, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses

// import dovetail and mounting plate definitions
use <am_dovetail.scad>


// Main dimensions
xos=15;        // snapper width of dual lens
yos=3.5;       // snapper thickness
zos=7;         // snapper height
dxs=3.6;       // snapper rim width
dys=1;         // snapper carve depth
wall=1.5;      // wall thickness of printed part
clr=0.2;       // clearance


//-------------------------------------------------------------------------
// Lens snap mount
//-------------------------------------------------------------------------

// basic shape

module lens_basicA(x=xos, y=yos, z=zos) {
    x1=(x-2*dxs);  // center region width
    y1=(y-2*dys);  // center thickness
    difference() {
      union() {
              translate([0,   -y1/2, 0])     cube( [x/2, y1,  z], center=false);
              translate([x1/2, -y/2, 0])     cube( [dxs, y,   z], center=false);
              //translate([0,    -y/2, z-y/2]) cube( [x/2, y, y/2], center=false);
              translate([0,       0, z-y/2]) 
                rotate([0, 90, 0]) 
                  cylinder(d=y, h=x/2, center=false, $fn=24);
      }
      // cut 0.4mm from top
      translate([-0.5,    -y, z-0.4]) cube( [x, 2*y, y/2], center=false);
    }
}

// symmetric shape with possible clearance

module lens_basicB(x=xos, y=yos, z=zos, c=0) {
    union() {
      mirror([0,0,0]) lens_basicA(x=x+c, y=y+c, z=z);
      mirror([1,0,0]) lens_basicA(x=x+c, y=y+c, z=z);
    }
}


module lens_dovetail() {
    c=-clr;
    union() {
      translate([0, 0, 0]) lens_basicB( c=c);
      translate([(xos+c)/2, 0, 0]) rotate([0, -90, 0]) rotate([0, 0, 90])
        am_dovetailAdd(h=xos+c);
    }
}     

//------------- Instances --------------------

//lens_basicB();

lens_dovetail();
