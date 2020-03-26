// some simple but versatile thin-walled storage boxes
//
//
// Background:
//   - CAD manual: http://www.openscad.org/documentation.html
//   - possibility to attach to parts from raspi_RJ45fix.scad
//
// Andreas Merz 2020-01-04, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses





//-------------------------------
// dovetail
//
//       w2
//    ---------
//    \       /  h
//     ---+---
//       w1
//-------------------------------

// Main dimensions
dt_w1=4;              // nominal size
dt_w2=6;
dt_h=2; 
dt_grid=dt_w1+dt_w2;  // 10 mm
dt_c=0.16;            // clearance / spiel in mm

dt_angle_deg=atan((dt_w2-dt_w1)/dt_w1);

// -------------------------------------------------------
// 2D shapes
// -------------------------------------------------------

module dt_shapeNominal(h=dt_h, w1=dt_w1, w2=dt_w2, c=0) {
             hh=h-c;
	     y1=w1/2-c;
	     y2=y1+(w2-w1)/2*hh/h;   // keep slope angle, even if c is not 0;
             polygon(points=[[-y1,0],[y1,0],[y2,hh],[-y2,hh]]);
}

module dt_shapeMajor() {
  dt_shapeNominal(c=-dt_c);
}

module dt_shapeMinor() {
  dt_shapeNominal(c=dt_c);
}


// -------------------------------------------------------
// 3D shapes
// -------------------------------------------------------

// legacy module

module dovetail3D(h=20, s=45, t=0.8) {
         c=0.3;   // clearance / spiel in mm
         difference() { 
           linear_extrude(height=h)
              union() {
                dt_shapeMinor();
                translate([-dt_h+c,-t]) square([dt_w1-2*c,t]);

              }
           rotate([s,0,0]) translate([-4,0,-4]) cube([8, 4, 4]);
         }
 }


// And cap - may be used to handle broadening at the printer bed

module am_dovetailCap(t=1.0, c=dt_c) {
      scl = (c < 0) ? 2 : 0;               // for negative clearances we create the dovetailSub case
      translate([0,0,0]) mirror([0,0,1])
      difference() {
	linear_extrude(height=dt_h/cos(30), scale=scl)
	  dt_shapeNominal(c=c);
	translate([-3*dt_w1,-3*dt_w2,t]) 
	  cube([6*dt_w1,6*dt_w2, dt_h/cos(30)+1]);
      }
}



// Dovetail to be attached to another body

module am_dovetailAdd(h=10, t=1.2, sgn=1) {
    //h:    overall height
    //t:    transition region
    //sub:  flag to handle the subtract case
    c = sgn*dt_c;
    union () {
      translate([0,0,t])
        am_dovetailCap(t=t, c=c);
      translate([0,0,t])
	linear_extrude(height=h-2*t, scale=1)
	  dt_shapeNominal(c=c);
      translate([0,0,h-t]) mirror([0,0,1])
        am_dovetailCap(t=t, c=c);
    }
}


// Dovetail to be carved out of another body

module am_dovetailSub(h=10, t=1.0) {
    //h:    overall height
    //t:    transition region
    //sub:  flag to handle the subtract case
    am_dovetailAdd(h=h, t=t, sgn=-1);
}


// negative dovetail to sculpt on another

module am_dovetailNeg(h=100, xo=dt_grid, yo=2*dt_h) {
    //h:    overall height
    //xo:   outer x
    //yo:   outer y
    difference() {
      translate([0, dt_h+0.01, h/2]) cube([xo, yo, h-0.02], center=true);
      linear_extrude(height=h, scale=1)	dt_shapeNominal(c=dt_c);
    }
}


// Multiple dovetails

module am_dovetailAddN(h=10, t=1.0, n=6, sgn=1) {
  m=n/2+0.5;
  for (i=[1:n]) {
    translate([dt_grid*(i-m),0,0]) am_dovetailAdd(h=h, t=t, sgn=sgn); 
  }
}

module am_dovetailPlateA(h=10, n=6, d=3) {
  y=(d-dt_c)/2;
  dw=(dt_w2-dt_w1)/2;
  union() {
    translate([0, y, 0])  am_dovetailAddN(h=h,n=n);
    translate([0,0,h/2]) cube([(n-0.5)*dt_grid-dw-dt_c, 2*y, h], center=true);
    translate([0,-y, 0])  mirror([0,1,0]) am_dovetailAddN(h=h,n=(n-1));
  }
}

module am_dovetailPlateB(h=10, n=6, d=3) {
  y=(d-dt_c)/2;
  dw=(dt_w2-dt_w1)/2;
  difference() {
    union() {
      translate([0,y,0]) am_dovetailAddN(h=h,n=n);
      translate([0,0,h/2]) cube([(n-0.5)*dt_grid+dw-dt_c, 2*y, h], center=true);
      translate([0,-y,0]) mirror([0,1,0]) am_dovetailAddN(h=h,n=(n-1));
    }
    union() {
      translate([-(n-1)*dt_grid/2-dw, d/2+dt_h+dt_c-dt_w2/2, -0.1]) rotate([0, 0, 90]) am_dovetailNeg(h=h+0.2);
      translate([+(n-1)*dt_grid/2+dw, d/2+dt_h+dt_c-dt_w2/2, -0.1]) rotate([0, 0,-90]) am_dovetailNeg(h=h+0.2);
    }
  }
}

//------------- Instances --------------------

// module testing

// test 2D shapes
//translate([dt_grid/2+0.2, dt_h, 0]) mirror([0,1,0]) dt_shapeNominal(c=-dt_c);   dt_shapeNominal(c=dt_c);
//translate([0, 0, 1.1]) mirror([0,0,0]) dt_shapeNominal(c=-dt_c);  color("red") dt_shapeNominal(c=dt_c);

// test 3D shapes
//mirror([0,0,1]) am_dovetailCap(c=+0.01);  translate([0,0,0])  am_dovetailCap(c=-0.01);
//am_dovetailAdd(h=5,t=0.1);  translate([dt_grid/2+0.2, dt_h+dt_c, 0]) mirror([0,1,0]) am_dovetailSub(h=5,t=0.1);

//dovetail3D();

//am_dovetailAdd();

//am_dovetailAddN();

//am_dovetailPlateA();

//am_dovetailNeg(h=10);


am_dovetailPlateB(n=4);
