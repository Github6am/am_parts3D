// single axis positioner using stepper motor
//
// 
// Background:
//   - assume that the cool gear library by Dr J. Janssen is here: 
//     ~/.local/share/OpenSCAD/libraries/gears/gears.scad
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//   - using simple axial bearing, source: Pollin electronic
//     https://www.pollin.de/p/drehteller-drehlager-70x70-mm-490467
//
// Andreas Merz 2021-06-20, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses

use <gears/gears.scad>

clr=0.6;     // default clearance
aa=150;      // plate length
bb=100;      // plate width


module bearingflange_contour_2D(aa=70, rr=10, c=0) {
      // aa  Kantenlaenge 
      // rr  Eckenradius
      minkowski() {        // outer contour, chamfered
        square(aa-2*rr, center=true);
        circle(r=rr);
      }
}

module bearingflange_holes_2D(d1=3.5, dcenter=45, db=56, nf=8) {
      // db    // borehole distance
      // nf    // number of faces for screwholes
      union() {
        circle(d=dcenter, $fn=36);
        translate([  db/2,  db/2]) circle(d=d1, $fn=nf);
        translate([ -db/2,  db/2]) circle(d=d1, $fn=nf);
        translate([  db/2, -db/2]) circle(d=d1, $fn=nf);
        translate([ -db/2, -db/2]) circle(d=d1, $fn=nf);
      }
}

module motorflange_holes_2D() {
      bearingflange_holes_2D(d1=3.5, dcenter=22, db=31, nf=12);
}


module turntable_topA() {
      gw=9;   // gearwidth
      difference() {
        herringbone_gear(modul=2, tooth_number=58, width=gw, bore=55, helix_angle=22.5, optimized=false);
        union() {
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D();
          translate([ 0, 0,gw/2]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_contour_2D(c=clr);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_holes_2D(d1=10, nf=24);
          translate([ 0, 0,gw/2]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_contour_2D(c=clr);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 22.5]) bearingflange_holes_2D(db=65, d1=3.5);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,-22.5]) bearingflange_holes_2D(db=65, d1=3.5);
        }
      }
}

module turntable_botB() {
      gw=9;   // gearwidth
      dd=2;   // plate thickness
      ww=2;   // width of reinforcement structures
      hh=5;   // height of reinforcement structures
      mm=42;  // motor width
      
      difference() {
        union() {
          translate([ 25, 0,  dd/2]) cube([aa, bb, dd], center=true);
	  // Versteifungsrippen
	  cylinder(d=45+2*ww, h=hh);
          translate([ 25, (42+clr)/2, hh/2]) cube([aa, ww, hh], center=true);
          translate([ 25,-(42+clr)/2, hh/2]) cube([aa, ww, hh], center=true);

          // reduce length of outer struct to reduce warping
	  translate([ 25,  (bb-ww)/2, hh/2]) cube([aa-bb+mm+ww, ww, hh], center=true);
	  translate([ 25, -(bb-ww)/2, hh/2]) cube([aa-bb+mm+ww, ww, hh], center=true);
	  translate([ 25 +(aa-ww)/2, 0, hh/2]) cube([ww, mm, hh], center=true);
	  translate([ 25 -(aa-ww)/2, 0, hh/2]) cube([ww, mm, hh], center=true);

	  // diagonal structures
	  dxy =(bb-mm-ww)/4;       // diag offset from corner
	  dlen=(bb-mm-ww)/sqrt(2);   // diag length
	  translate([ 25 +(aa-ww)/2-dxy, +(bb-ww)/2-dxy, hh/2]) rotate([0,0,-45]) cube([dlen, ww, hh], center=true);
	  translate([ 25 -(aa-ww)/2+dxy, +(bb-ww)/2-dxy, hh/2]) rotate([0,0, 45]) cube([dlen, ww, hh], center=true);
	  translate([ 25 +(aa-ww)/2-dxy, -(bb-ww)/2+dxy, hh/2]) rotate([0,0, 45]) cube([dlen, ww, hh], center=true);
	  translate([ 25 -(aa-ww)/2+dxy, -(bb-ww)/2+dxy, hh/2]) rotate([0,0,-45]) cube([dlen, ww, hh], center=true);
        }
	union() {   // all holes
          translate([    0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D();
          translate([    0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_holes_2D(d1=10, nf=24);
          // Langloch, um den Zahnradeingriff zu justieren
	  minkowski() {
	    cube([6,0.01,0.01], center=true);     
	    translate([ 57.5+9.5, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) motorflange_holes_2D();
	  }
        }
      }
}

// massive variant, if little infill is used, this may print faster and cheaper
module turntable_botC() {
      gw=9;   // gearwidth
      dd=5;   // plate thickness
      mw=2;   // wall thickness at motor
      mm=42;  // motor width
      
      difference() {
        union() {
          translate([ 25, 0,  dd/2]) cube([aa, bb, dd], center=true);
        }
	union() {   // all holes
          translate([    0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D();
          translate([    0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_holes_2D(d1=10, nf=24);
          // Langloch, um den Zahnradeingriff zu justieren
	  minkowski() {
	    cube([6,0.01,0.01], center=true);     
	    translate([ 57.5+9.5, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) motorflange_holes_2D();
	  }

          // motor compartment
	  translate([ 25 + mm-4, 0, mw+10/2]) cube([mm+16, mm+clr, 10], center=true);

	  // cut corners diagonally to prevent warping
	  translate([ 25 +(aa)/2, +(bb)/2, mw/2+10/2]) rotate([0,0,-45]) cube([40, 40, 10], center=true);
	  translate([ 25 -(aa)/2, +(bb)/2, mw/2+10/2]) rotate([0,0,-45]) cube([40, 40, 10], center=true);
	  translate([ 25 +(aa)/2, -(bb)/2, mw/2+10/2]) rotate([0,0,-45]) cube([40, 40, 10], center=true);
	  translate([ 25 -(aa)/2, -(bb)/2, mw/2+10/2]) rotate([0,0,-45]) cube([40, 40, 10], center=true);
        }
      }
}


// mounting part, allow to tilt the attached structure along horizontal axis
module mountA() {
      x=20;          // bottom length
      y=10;          // thickness
      z=10;          // height
      sx=0.5;        // ratio top/bottom length
      bore=4;        // nominal bore hole diameter
      translate([0,-y/2,0])
      difference() {
	union() {
          linear_extrude(height = z, scale=[sx,1]) square([x, y], center=false);
          translate([x*sx/2,0,z]) rotate([-90,0,0]) cylinder(d=x*sx, h=y, $fn=24);
	}
        translate([x*sx/2,-1,z]) rotate([-90,0,0]) cylinder(d=bore+clr, h=y+2, $fn=24);
      }
}

// attach tilting possibility
module turntable_botD() {
    dd=80;   // distance of mount points
    
    union() {
      turntable_botC();
      // 4 mounts
      translate([ 25 -dd/2, -bb/2, 0]) rotate([0,0,90]) mountA();
      translate([ 25 +dd/2, -bb/2, 0]) rotate([0,0,90]) mountA();
      translate([ 25 -dd/2, +bb/2, 0]) rotate([0,0,-90]) mountA();
      translate([ 25 +dd/2, +bb/2, 0]) rotate([0,0,-90]) mountA();
      
    }
}

module drive_gear(nt=9) {
  herringbone_gear(modul=2, tooth_number=nt, width=8, bore=8.6, helix_angle=22.5);
}


//---------------- Test ---------------------
// Zahnstange
//translate([-3,-21,0]) rack(2, 100, 8, 10, 20, -22.5);
//spur_gear(modul=2, tooth_number=20, width=8, bore=10, helix_angle=11.25);
//herringbone_gear(modul=2, tooth_number=9, width=8, bore=8.6, helix_angle=22.5);
//herringbone_ring_gear(modul, tooth_number, width, rim_width, pressure_angle=20, helix_angle=0)

//herringbone_gear(modul=2, tooth_number=47, width=9, bore=45, helix_angle=22.5, optimized=true);


//---------------- Instances ---------------------
//bearingflange_contour_2D();
//bearingflange_holes_2D();
//mountA();

//drive_gear();
//turntable_topA();

//turntable_botB();
//turntable_botC();
turntable_botD();
