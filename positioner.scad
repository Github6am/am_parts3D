// single axis positioner using stepper motor
//
// Background:
//   - more axes can be othogonally mounted to create a simple antenna positioner
//   - the platform may be mounted with a tilt to make the axis parallel to the earth axis.
//   - assume that the cool gear library by Dr J. Janssen is here: 
//     ~/.local/share/OpenSCAD/libraries/gears/gears.scad
//     git clone https://github.com/chrisspen/gears.git
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//   - external parts:
//     - simple axial bearing, source: Pollin electronic
//       https://www.pollin.de/p/drehteller-drehlager-70x70-mm-490467
//       cheap, accuracy is limited
//     - Arduino Mega 2560 board, e.g
//       https://www.pollin.de/p/joy-it-mega2560r3-entwicklungsboard-810668
//     - RAMPS motor driver and display, e.g
//       https://www.pollin.de/p/joy-it-ramps-1-4-mit-display-5x-a4988-motortreiber-810875
//     - Stepper motor, e.g
//       https://www.pollin.de/p/schrittmotor-minebea-17pm-k077bp01cn-1-80-310689
//     - screws  M3.5 x 8,  3.5 x 8,  3.5 x 25, ...
//     - Marlin Firmware
//       https://github.com/MarlinFirmware/Marlin.git
//       with my adapted configuration, see Positioner_Marlin_Configuration.patch
//       this will allow to use G-codes for control. https://reprap.org/wiki/G-code
//     - arduino IDE, 1.8.15, https://www.arduino.cc/en/software
//   - TODO: Libelle d=15 einpressen?
//
// Andreas Merz 2021-10-31, v0.3 
// GPLv3 or later, see http://www.gnu.org/licenses

use <gears/gears.scad>

clr=0.6;     // default clearance
aa=150;      // plate length
bb=100;      // plate width

// ------------------- helper modules ----------------------

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


// ------------------- the main parts ---------------------------------

// the main herringbone gear which is also the top mounting platform
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

// the bottom mounting plate with siffening ribs
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

// the small gear
module drive_gear(nt=9) {
  herringbone_gear(modul=2, tooth_number=nt, width=8, bore=8.6, helix_angle=22.5);
}


// ----------------------------  mounting feet ---------------------------------

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



//---------------- Auxiliary parts ---------------------
use <am_dovetail.scad>

// a laserpointer fixture also providing electrical contact
module fixtureA() {
    w=1;       // wall thickness
    d0=3.2;    // center hole diameter
    d1=11.8;   // inner thread diameter
    d2=14.8;   // outer pipe diameter
    d3=17.4;   // outer pipe diameter with button pressed
    d4=0.6;    // difference between button released and pressed
    h1=7;      // inset height
    h2=15;     // height to button
    h3=22;     // overall height
    
    difference() {
      union() {
	// outer vessel
	difference() {
          union() {
            cylinder(d=d2+2*w, h=h3, $fn=48);
            translate([ 0,0, h2-3]  ) cylinder(d1=d2+2*w, d2=d3+2*w, h=3, $fn=48);
            translate([ 0,0, h2]) cylinder(d=d3+2*w, h=h3-h2, $fn=48);
          }
          union() {
	    translate([ 0,0, w])    cylinder(d=d2, h=h3, $fn=48);
            translate([ 0,0, h2+w]) cylinder(d=d3, h=h3-h2, $fn=48);
	    // button release notch
            translate([ d3/2-5/2+d4,0, h2+w]) cylinder(d=9, h=h3-h2, $fn=48);
          }
	}
	// inset
	cylinder(d=d1, h=h1+w, $fn=48);
      }
      union() {
        // center hole to contact -pole
        translate([ 0,0, -1])    cylinder(d=d0, h=h3, $fn=48);
        // offset hole to contact +pole/metal case
        translate([ d1/2-2/3,0, -1]) cylinder(d=2, h=h3, $fn=48);
      }
    }
}

// dito, with dovetails at circumference
module fixtureB() {
    w=1;       // wall thickness
    d2=14.8;   // outer pipe diameter
    h2=15;     // height to button
    union() {
      fixtureA();
      rotate([0,0,  0]) translate([0,  d2/2+w-0.3, 0]) am_dovetailAddN(n=1, h=h2);
      rotate([0,0, 90]) translate([0,  d2/2+w-0.3, 0]) am_dovetailAddN(n=1, h=h2);
      rotate([0,0,180]) translate([0,  d2/2+w-0.3, 0]) am_dovetailAddN(n=1, h=h2);
      rotate([0,0,-90]) translate([0,  d2/2+w-0.3, 0]) am_dovetailAddN(n=1, h=h2);
    }
}

// a fixture to hold the Robotale RepRapDiscount Display board in a tilted position
module fixtureD() {
    w=4;         // wall thickness
    x0=88;       // PCB board width
    w0=2.5;      // PCB thickness / slot width
    x1=x0+2*w;   // hypothenuse
    y1=12;       // base height
    z1=w+w;      // foot width
    mt=8;        // mount foot height, depends max screw length
    dbore=4;     // screw bore hole diameter
    y2=20;       // wedge shape
    x2=sqrt( x1*x1 - y2*y2);     // kathete
    ang=atan(y2/x2);             // slope angle
    
    difference() {
      union() {
	cube([x2, y2+y1, w]);   // main contour
	translate([ x2/2, w/2, w]) linear_extrude(height=z1-w, scale=[0.82,1]) square([x2, w], center=true);      // foot, reduce warping
	//translate([ x2/2, w/2, w]) linear_extrude(height=z1-w, scale=[(x2-2*w)/x2,1]) square([x2, w], center=true);      // foot
	// screw mount outer contour
	translate([   30, 0, w+4.5]) rotate([-90,0,0]) cylinder(d=12, h=mt, $fn=32);
	translate([   80, 0, w+4.5]) rotate([-90,0,0]) cylinder(d=12, h=mt, $fn=32);
      }
      union() {
        // cut the top
	rotate([0,0,ang]) translate([    0,  y1, -0.1]) cube([x1+10, y2+y1, w+1]);
	// SD card slot
	rotate([0,0,ang]) translate([   38,  y1-12, -0.1]) cube([32, 12+1, w+1]);
	// grooves on front
	rotate([0,0,ang]) translate([    w,  y1-w0*1.5,     w-1]) cube([x0, w0, 2]);
	rotate([0,0,ang]) translate([    w,  y1-w0*1.5-4.6, w-1]) cube([x0, w0, 2]);
	// grooves on back - make them 1mm deeper than on front
	rotate([0,0,ang]) translate([    w,  y1-w0*1.5,     1-1]) cube([x0, w0, 2]);
	rotate([0,0,ang]) translate([    w,  y1-w0*1.5-5,   1-1]) cube([x0, w0, 2]);
	// countersunk screw holes
	translate([   30, -0.1, w+4.5]) rotate([-90,0,0]) ccyl(h1=mt-3+1, h2=2, r1=dbore/2 );
	translate([   80, -0.1, w+4.5]) rotate([-90,0,0]) ccyl(h1=mt-3+1, h2=2, r1=dbore/2 );
	// anti-warping slot
	translate([    x2-2*w,  w,     w-3]) cube([5, y1+w, w]);
      } 
    }
}

// dovetail mounting plate to attach on gear.  See also connectionH in raspi_RJ45fix.scad
module fixtureH() {
    w=2;      // bottom wall thickness
    x1=55;    // part width
    y1=20;    // part length
    x2=35.2;  // mounting hole distance on gear
    y2=3;     // mounting hole offset from centerline
    difference() {
      union() {
	translate([0, 0,  w/2]) cube([x1, y1, w], center=true);
	translate([0, y1/2, w]) rotate([90, 0,  0])  am_dovetailAddN(n=6, h=y1);
      }
      union() {
        translate([    0,  0, -0.1]) cylinder(d=3,   h=10, $fn=16);  // center hole
        translate([ x2/2, y2, -0.1]) cylinder(d=3.5, h=10, $fn=16);
        translate([ x2/2, y2,  w])   cylinder(d=8,   h=10, $fn=16);
        translate([-x2/2, y2, -0.1]) cylinder(d=3.5, h=10, $fn=16);
        translate([-x2/2, y2,  w])   cylinder(d=8,   h=10, $fn=16);
      } 
    }
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
//mountC();
//rotate([-90,0,0]) mountC();
//mirror([1,0,0]) mountC();

//drive_gear();
turntable_topA();

//turntable_botB();
//turntable_botC();
//turntable_botD();

//fixtureB();
//fixtureD();
//fixtureH();
