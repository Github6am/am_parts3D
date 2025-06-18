// Battery and accumulator related stuff, charging and storage.
// 
// 
// Background:
//   - nomenclature for batteries IEC 61951, IEC 61960
//     https://dh2mic.darc.de/files/batterien.pdf
//     https://en.wikipedia.org/wiki/Battery_nomenclature
//   - related designs, see also:
//     - battery_holder.scad
//       for 610mAh flat LiPo accumulators
//   - other designs I found on thingiverse
//       https://www.thingiverse.com/thing:456900
//       https://www.thingiverse.com/thing:331394
//       https://www.thingiverse.com/thing:2339441
//     - galeb_M8cover.scad
//       cover to be printed in red(+) and black(-) covering M8 
//       high-current battery connections.
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2025-01-24, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
//use <am_dovetail.scad>


//-------------------------------------------------
// Battery holder for cylindrical LiPo accumulators
//-------------------------------------------------
// scalable and cascadable

// a single instance, default type: LG INR18650-M29
module holderA(
  xi=70,   // inner length, including space for spring
  yi=19,   // inner width, including clearance
  xw=4,    // wall in x-direction
  yw=2,    // wall in y-direction
  zw=1,    // bottom wall
  ) {
  r=yi/2;                 // radius of cylindrical accumulator cell
  hr=(r-sqrt((2*r-yw)*yw))*0.9; // ridge height * tolerance
  echo (str ("hr: ", hr));
  difference() {
    // outer shape
    translate([0, 0, 0])  cube([xi+2*xw, yi, yi]);
    union() {
      // inner contour
      translate([xw, yw, zw+0.1]) cube([xi, yi-2*yw, 2*yi]);
      // just leave ridges in between the cells
      translate([xw, -yw, zw+hr]) cube([xi, 2*yi, 2*yi]);
      // cut a bottom hole to save material
      translate([2*xw, yi/4 , -1]) cube([xi-2*xw, yi/2, 2*yi]);
      // axial 4mm hole for measurements or screws
      translate([-1, yi/2, zw+yi/2]) rotate([0,90,0]) cylinder(d=4.4, h=xi+2*xw+2, $fn=24);
    }
  }
}

// modified version with cylindrical inner contour
module holderB(
  xi=70,   // inner length, including space for spring
  yi=19,   // inner width, including clearance
  xw=4,    // wall in x-direction
  yw=0.6,  // wall in y-direction
  zw=0.4,  // bottom wall
  ) {
  c=0.4;   // additional clearance, should not exceed 2*zw.
  r=yi/2;                 // radius of cylindrical accumulator cell
  hr=(r-sqrt((2*r-yw)*yw))*0.9; // ridge height * tolerance
  echo (str ("hr: ", hr));
  difference() {
    // outer shape
    translate([0, 0, 0])  cube([xi+2*xw, yi, yi]);
    union() {
      // inner contour
      translate([xw, yw, zw+yi/2]) cube([xi, yi-2*yw, 2*yi]);
      // just leave ridges in between the cells
      translate([xw, yi/2, zw+yi/2]) rotate([0,90,0]) cylinder(d=yi+c, h=xi, $fn=96);
      translate([xw, -yw, zw+hr]) cube([xi, 2*yi, 2*yi]);
      // cut a bottom hole to save material
      translate([2*xw, yi/4 , -1]) cube([xi-2*xw, yi/2, 2*yi]);
      // axial 4mm hole for measurements or screws
      translate([-1, yi/2, zw+yi/2]) rotate([0,90,0]) cylinder(d=4.4, h=xi+2*xw+2, $fn=48);
    }
  }
}

// Kontaktfederausschnitt, fuer z.B. Keystone 290
module contact_cut(
  x=2,
  y=21.6,
  z=12
  ) {
  b=7;   // Zungenbreite
  difference() {
     translate([0,   -y/2,  0   ]) cube([x+1, y, z]); 
     translate([0.8, -b/2, -0.01]) cube([x+1, b, 8]);
  }
}  

// multiple holders
module holderN(
  xi=70,      // inner length, including space for spring
  yi=19,      // inner width, including clearance
  xw=4,       // wall in x-direction
  yw=0.6,     // wall in y-direction
  zw=0.4,     // bottom wall
  n=4,        // number of batteries to store
  springs=1,  // type of contact springs to use
  ) {
  zoff=(springs-1)*2*yi;  // trick: disable cutting by just moving away
  difference() {
    for (i = [0 : n-1]) {
      translate([0, yi*i, 0])
        holderB( xi=xi, yi=yi, xw=xw, yw=yw, zw=zw);
    }
    // cut patterns to insert contacts
    union() {
      for (i = [1 : 2 : n-1]) {
        translate([xw-2, i*yi,  yi-12+0.1+zoff ]) contact_cut();
      }
      for (i = [2 : 2 : n-1 ]) {
        translate([xi+xw+2, i*yi,  yi-12+0.1+zoff ]) mirror([1,0,0]) contact_cut();
      }
    }
  }
}  


//------------- Instances --------------------

holderN();
