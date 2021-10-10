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
//   - TODO: Libelle d=15 einpressen?
//
// Andreas Merz 2021-06-20, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses

use <gears/gears.scad>

clr=0.6;     // default clearance
aa=150;      // plate length
bb=100;      // plate width


// cone+cylinder, useful for countersunk screws

module ccyl(h1=10*2/3, h2=10*1/3, r1=2, ang=-45) {
    ss=(r1-h2*tan(ang))/r1;
    union() {
      linear_extrude(height=h1, scale=1)  circle(r=r1,$fn=24);
      translate([0,0,h1-0.01])
        linear_extrude(height=h2, scale=ss) circle(r=r1, $fn=24);
      translate([0,0,h1+h2-0.02])
        linear_extrude(height=h1, scale=1) circle(r=r1*ss, $fn=24);
    }
}


module bearingflange_contour_2D(aa=70, rr=9, c=0) {
      // aa  Kantenlaenge 
      // rr  Eckenradius
      minkowski() {        // outer contour, chamfered
        square(aa-2*rr, center=true);
        circle(r=rr);
      }
}

module bearingflange_holes_2D(d1=3.5, dcenter=45, db=56, nf=8, centerhole=true) {
      // db    // borehole distance
      // nf    // number of faces for screwholes
      union() {
        if(centerhole) circle(d=dcenter, $fn=36);
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
      dm=65;  // distance of square-aligned mounting holes
      dm1=dm*sqrt(1-1/sqrt(2));  // 35.2mm distance of octagon-aligned mounting holes
      dm3=dm*sqrt(1+1/sqrt(2));  // 84.9mm distance of octagon-aligned mounting holes
      difference() {
        herringbone_gear(modul=2, tooth_number=58, width=gw, bore=55, helix_angle=22.5, optimized=false);
        union() {
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D();
          translate([ 0, 0,gw/2]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_contour_2D(c=clr);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_holes_2D(d1=10, nf=24);
          translate([ 0, 0,gw/2]) linear_extrude(height = 12) rotate([0,0,45]) bearingflange_contour_2D(c=clr);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 22.5]) bearingflange_holes_2D(db=dm, d1=3.5);
          translate([ 0, 0,  -1]) linear_extrude(height = 12) rotate([0,0,-22.5]) bearingflange_holes_2D(db=dm, d1=3.5);
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
          // additional mounting holes
	  translate([1/2*56+100-30, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D(centerhole=false);
	  translate([1/2*56+100-15, 0,  -1]) linear_extrude(height = 12) rotate([0,0, 0]) bearingflange_holes_2D(centerhole=false);
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
module mountA(x=20, y=10, z=10, sx=0.5, bore=4) {
      //x=20;          // bottom length
      //y=10;          // thickness
      //z=10;          // height
      //sx=0.5;        // ratio top/bottom length
      //bore=4;        // nominal bore hole diameter
      translate([0,-y/2,0])
      difference() {
	union() {
          linear_extrude(height = z, scale=[sx,1]) square([x, y], center=false);
          translate([x*sx/2,0,z]) rotate([-90,0,0]) cylinder(d=x*sx, h=y, $fn=24);
	}
        translate([x*sx/2,-1,z]) rotate([-90,0,0]) cylinder(d=bore+clr, h=y+2, $fn=24);
      }
}

module mountB(dbore1=2.2, dbore2=4) {
      x1=10;       // top length
      x2=20;       // bottom length
      x3=12;       // foot length
      z3=7;        // foot height
      y2=15;       // thickness

      sx12=x1/x2;
      
      h2=3;        // 45deg transition socket height
      xh2=x2+h2*2;
      yh2=y2+h2;
      shx=x2/xh2;
      shy=y2/yh2;
      
      rotate([90,0,0])
      difference() {
	union() {
	  translate([0,y2/2,z3+h2]) mountA(x=x2, y=y2, z=25, sx=sx12, bore=dbore1);
	  // transition avoiding sharp edges
	  translate([x2/2,0,z3]) linear_extrude(height=h2, scale=[shx, shy]) translate([-xh2/2,0,0]) square([xh2,yh2]);
	  // mounting foot
	  translate([-x3,0,0])  cube([x2+2*x3,y2+x3,10-h2]);
	}
	union() {
	  // spare hole
          translate([x1/2,y2-5,20]) rotate([-90,0,0]) cylinder(d=dbore1+clr, h=100, $fn=24);
          // countersunk screw holes
          translate([  -x3/2,    y2/2,-1]) ccyl(h1=z3-3+1, h2=3, r1=dbore2/2 );
          translate([x2+x3/2,    y2/2,-1]) ccyl(h1=z3-3+1, h2=3, r1=dbore2/2 );
          translate([   x2/2, y2+x3/2,-1]) ccyl(h1=z3-3+1, h2=3, r1=dbore2/2 );
        }
      }
}

module mountC(dbore1=2.2, dbore2=4) {
      ao=14.8;        // axis offset between screw holes on vertical an horizontal branch
      x1=10;       // top length
      x2=30;       // bottom length
      x3=ao;       // foot width
      x4=60;       // foot length
      z3=8;        // foot height
      y2=10;       // thickness of vertical part

      sx12=x1/x2;
      
      h2=3;        // 45deg transition socket height
      xh2=x2+h2*1.4;
      yh2=y2+h2;
      shx=x2/xh2;
      shy=y2/yh2;
      
      rotate([90,0,0])
      difference() {
	union() {
	  translate([0,y2/2,z3+h2]) mountA(x=x2, y=y2, z=30, sx=sx12, bore=dbore1);
	  // transition avoiding sharp edges
	  translate([0,0,z3]) linear_extrude(height=h2, scale=[shx, shy]) translate([0,0,0]) square([xh2,yh2]);
	  // mounting foot
	  translate([0,0,0])  cube([x4,y2+x3,z3]);
	}
	union() {
	  // spare hole
          translate([x1/2,-1,25]) rotate([-90,0,0]) cylinder(d=dbore1+clr, h=100, $fn=24);
          //  screw holes
          translate([x1+20,y2/2,20]) rotate([-90,0,90]) cylinder(d=dbore1+clr, h=100, $fn=24);
          translate([x1+20,y2/2,35]) rotate([-90,0,90]) cylinder(d=dbore1+clr, h=100, $fn=24);
          // Langloch, um die Elevationsachse zu justieren
	  minkowski() {
	    cube([15,0.01,0.01], center=true);     
            union() {
	      for( i=[0:2] ) {
        	translate([12.5+i*35, y2/2+ao, -1]) cylinder(d=3.3+clr,h=z3+2, $fn=24 );
        	translate([12.5+i*35, y2/2+ao,  4]) cylinder(d=8.0,h=z3, $fn=24 );
	      }
	    }
	  }
          // countersunk screw hole
          translate([  x2+5,   y2/2,-1]) ccyl(h1=z3-3+1, h2=2, r1=dbore2/2 );
          translate([  x2+20,   y2/2,-1]) ccyl(h1=z3-3+1, h2=2, r1=dbore2/2 );
        }
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
//mountB();
//mirror([1,0,0]) mountB();
mountC();
//rotate([-90,0,0]) mountC();
//mirror([1,0,0]) mountC();

//drive_gear();
//turntable_topA();

//turntable_botB();
//turntable_botC();
//turntable_botD();
