// ssdframe.scad
// a handle to plug a SSD into a DELL Latitude E6430 Notebook
//
// Background:
//   - CAD manual: http://www.openscad.org/documentation.html
//
//   - see also:
//     https://www.thingiverse.com/am_things/designs
//     https://github.com/Github6am/am_parts3D
//
// Andreas Merz 2022-01-22, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses



module ssdframe1(
     a1=70.2,  // ssd width
     a2=72.6,  // frame width
     b1=10,    // depth
     b2=24.6,  // overall depth
     c=10.8    // height
     ) {
     w=(a2-a1)/2;
         union() {
           difference() {
             union() {
               // outer shape
               translate([0, -b2/2+b1, c/2]) cube([a2,b2,c], center=true);
             }
             union() {
               // SSD bay
               translate([0,-b2/2, c/2-0.1]) cube([a1,b2,c+0.4], center=true);
               // slope
               translate([0,  b1+3.5, c/2]) rotate([40,0,0]) cube([a2+5,b1,30], center=true);
               // handle
               translate([0,  (b1-3.5)/2+w, c/2+w]) cube([60, b1-3.5, c], center=true);
               translate([0,  b1/2+w, c/2+w+2]) cube([60, b1, c], center=true);
             }
           }
           // pins
           translate([   a2/2-1.5,  -10, c/2]) rotate([0,90,0]) cylinder(d=2.4, h=3, $fn=48, center=true);
           translate([ -(a2/2-1.5), -10, c/2]) rotate([0,90,0]) cylinder(d=2.4, h=3, $fn=48, center=true);
         }
     }


//---------------- Instances ---------------------

ssdframe1();

