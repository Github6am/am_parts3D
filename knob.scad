// Knobs to put at the end of a stick
// 
// 
// Background:
//   - DE: Knauf
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2025-01-07, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses


//-------------------------------------------
// optional: thread
//-------------------------------------------
// http://dkprojects.net/openscad-threads/
// use <threads.scad>


// ------------- Spherical knob ---------------------

module kugel(
    d=12,    // diameter of sphere
    b=4.5,  // borehole
    w=1.6,  // wall thickness, determines adhesion surface on plate
    fn=90,  // face number
    c=0.0   // radial clearance
    ) {
    hcyl = sqrt(d*d-b*b)/2;            // height of cylindrical rim above horizon
    depth = sqrt( (d/2-w)^2 - b*b/4);  // how deep to drill below horizon
    mirror([0,0,1])
    difference() {
      union() {
        sphere(d=d, $fn=fn);
        cylinder(d=b+2*w, h=hcyl, $fn=fn);
      }
      // blind boring
      translate([0,0,-depth]) cylinder(d=b, h=2*d, $fn=fn);
    }
}



//------------- Instances --------------------

// test: cross-section view
// difference(){ kugel(); translate([0,0,-40]) cube([20,20,80]); }

kugel(d=9, b=4.0, w=0.8);  // kugelW

