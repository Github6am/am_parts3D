// Haengemattengestell Ersatzfuesse
// 
// Background:
//   - feet to plug on the end of a tube construction
//
// Author: Andreas Merz, 2025-06-09
//  GPLv3 or later, see http://www.gnu.org/licenses 

fn=48;  // default face number for cylinders

// Standfuss - stand to be plugged on the end of a tube
module tubefootA(
    dd=37.6,      // tube design inner diameter (minus printer nozzle width)
    hc=24,        // height of cylindrical section
    hf=20,        // height of foot without rr radius excess
    xf=2,         // excess of quadratic section
    rr=5,         // edge radius
    aa=22.5,      // tilt angle in degrees
    c=0.6,        // clearance, make plug slightly conical
    flatbottom=0  // experimental warp protection
    ) {
    x2=dd+2*xf;
    x1=x2-2*hf*tan(aa);
    z3=x2*tan(aa);
    difference() {
      rotate([0,-aa,0])
      union() {
        // foot with rounded corners
        minkowski() {
          difference() {
            union() {
              // Fuss mit abgeschraegten Standflaechen
              linear_extrude(height=hf, scale=x2/x1) square([x1,x1], center=true);
            }
            // Grundflaeche abschraegen fuer erhoehte Stabilitaet,
            // damit der Filamentfaserverlauf nicht parallel zum Rohrquerschnitt ist
            translate([0, 0,  -z3/2+x1*tan(aa)/2]) rotate([0,aa,0]) cube([100,100,z3], center=true);
          }
          sphere(d=2*rr, $fn=fn);
        }
        // Zapfen, der ins Rohr gesteckt wird
        translate([0, 0, hf+rr-0.1]) cylinder(d1=dd, d2=dd-c, h=hc+0.1);
      }
      // experimental warping protection, make a pit in the bottom
      translate([-5, 0, -100*flatbottom]) sphere(d=24, $fn=fn);
    }
}



//---------------- Instances ---------------------

tubefootA();
