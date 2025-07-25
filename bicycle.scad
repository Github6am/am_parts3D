// Spare parts for bicyles
// 
// 
// Background:
//   - currently two parts
//     1. replace a nut to cover a worn-out thread at the steering shaft. (Fahrradlenker)
//     2. adapter for a Brushless DC motor
//        https://www.pollin.de/p/bosch-bldc-motor-f016l68035-36-v-16-11-a-310892
//        https://mago-shop.de/Elektro/Electronic/BLDC-Motor-600W-Bosch-F016L68035-36V-16A-brushless::412.html
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2023-07-28, v1.1 
// GPLv3 or later, see http://www.gnu.org/licenses


//-------------------------------------------
// Werkzeuge
//-------------------------------------------

// use <galeb.scad>

// sequence of n conical sections
module conesN(n=3, hh=[0, 1, 8, 10], dd=[5.5, 5.8, 6.2, 5.0], fn=30) {
    for (i = [0 : n-1]) {
      translate([0,0, hh[i]])
        cylinder(d1=dd[i], d2=dd[i+1], h = hh[i+1]-hh[i], $fn=fn);
    }
}

//-----------------------------------------------
// Kontermutter/Ueberwurfmutter fuer Lenkerschaft
//-----------------------------------------------

// thread length 10mm
module lnut() {
  difference() {
    conesN(n=2, hh=[0, 12, 18], dd=[36,   36, 26], fn=12);
    conesN(n=3, hh=[-0.1, 10, 15, 19], dd=[25.8, 25.0, 23, 23], fn=96);
  }
}

// Weil noch ein Einkaufskorb geklemmt wird, kann das Gewinde kuerzer sein:
// thread length 8mm
module lnutA() {
  difference() {
    conesN(n=2, hh=[0, 10, 16], dd=[36,   36, 26], fn=12);
    conesN(n=3, hh=[-0.1, 8, 12, 17], dd=[25.6, 25.0, 23, 23], fn=96);
  }
}


//-----------------------------------------------
// BLDC - 500W Brushless DC-Motor von Bosch
//-----------------------------------------------

// the contour of the motor drive shaft
module bldc_drive_shaftB(
  // c and ex should be negative, if bldc_drive_shaftB is used as "negative"
  c=-0.2, // diameter clearance
  ex=-3,  // excess cutaway
  ) {
  difference() {
    conesN(n=4, hh=[0, 16, 32, 51, 52], dd=[17-c, 17-c, 15-c, 15-c, 14-c], fn=192);
    translate([-36/2, 6-c/2, 52-15-ex]) cube([36,36,30]);   // excess cutaway: 3mm
  }
}

// Seilrolle - winch, pulley to be mounted on the motor shaft
module bldc_wheelA(
  do=50
  ) {
  c=-0.3; // diameter clearance
  ex=-3;  // excess cutaway
  h=20;
  difference() {
    conesN(n=3, hh=[0, h+4, 32, 42], dd=[do, do, 22, 22], fn=192);
    union() {
      translate([0,0,52+2]) rotate([0,180,0]) bldc_drive_shaftB(c=c, ex=ex);
      // M8 centerhole
      translate([0,0,-1])   cylinder(d=8+0.4, h=10, $fn=48);
      // Seil-Nut
      rotate_extrude($fn = 80) translate([do/2+2,h/2+2,0]) circle(r=h/2);
    }
  }
}

//-----------------------------------------------------------
// BLDC - 36V 600W Brushless DC-Motor von Bosch 2607022335
//-----------------------------------------------------------
// Pollin 002-034-04

// the contour of the motor drive shaft, a slightly "concave" hexagon...
module bldc_drive_shaft6_2D(
  a=5,   // min radius 
  r=6,   // max radius
  ) {
  k= r*sqrt(3)/2 - a;   // concaveness
  R= r*r/(8*k) + k/2;   // the concave radius
  echo (str ("R: ", R));
  difference() {
    circle(R+1);
    union() {
      for ( i =[0 : 1 : 5] )
        rotate([0,0,60*i+30]) translate([a+R,0,0]) circle(R, $fn=1808);
    }
  }
    
}

// test part, hexagonal outer contour
module bldc_hexwheelA(
  a=5,    // min radius 
  r=6.3,  // max radius
  c=0.1,  // clearance
  h=4,    // heigth
  ) {
  difference() {
    cylinder(d=20.0, h=h, $fn=6);
    translate([0,0,-1])linear_extrude(height=h+2)
      bldc_drive_shaft6_2D(a=a+c, r=r+c);
  }
}

use <gears/gears.scad>

// test part as drive gear
module bldc_hexwheelB(
  a=5,    // min radius 
  r=6.3,  // max radius
  c=0.1,  // clearance
  h=4,    // heigth
  nt=10    // number of teeth, needs to be >9
  ) {
  di = (nt <= 10)? 14 : 15;
  difference() {
    union() {
    herringbone_gear(modul=2, tooth_number=nt, width=h, bore=12.5, helix_angle=22.5);
    cylinder(d=di, h=h+0.2, $fn=180);
    echo (str ("di: ", di));
    }
    translate([0,0,-2])linear_extrude(height=h+4)
      bldc_drive_shaft6_2D(a=a+c, r=r+c);
  }
}

// test part with winch pulley, for coupling motor + generator BLDCs face to face
module bldc_hexwheelC(
  a=5,    // min radius 
  r=6.3,  // max radius
  c=0.1,  // clearance
  h1=12,   // heigth pulley
  h=40,    // heigth overall
  nt=10    // number of teeth, needs to be >9
  ) {
  r1=(h1-2)/2; // Seilrollen-Nut
  di = 15;
  difference() {
    union() {
    cylinder(d=di, h=h, $fn=180);
    cylinder(d=2*r+h1/2+5, h=h1+0.2, $fn=180);
    }
    union() {
    translate([0,0,-2])linear_extrude(height=h+4)
      bldc_drive_shaft6_2D(a=a+c, r=r+c);
    // Seil-Nut
    rotate_extrude($fn = 80) translate([r+r1+1.5,r1+1,0]) circle(r=r1);
    }
  }
}


//------------- Instances --------------------

//lnut();
//bldc_hexwheelA();
//bldc_hexwheelB();
bldc_hexwheelC();

//bldc_drive_shaftB();
//bldc_wheelA();
