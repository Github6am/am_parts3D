// wasserhahnreparatur
// 
// Background:
//   - fix a stylish but poor quality broken water tap with rectangular cross-section
//
// Author: Andreas Merz, 2025-03-21
//  GPLv3 or later, see http://www.gnu.org/licenses 

fn=96;  // default face number for cylinders

// water outlet part, combines with sliderA
module nozzleA(
    dd=27,       // design inner diameter
    hh=20,       // overall height of cylindrical section
    hr=10,       // height of overlapping region, distance to ridge of nozzleA
    xx=28,       // square section width
    yy=10,       // distance to end
    zz=9.4,      // square section height
    w=1.6,       // wall thickness
    c=0.6        // clearance
    ) {
      difference() {
        union() {
          // ground plate, we make it asymetrical by 1*w
          translate([0, w/2, w/2]) cube([ xx+2*w, 2*yy+dd+w, w], center=true);
          // outer cylinder
          translate([0, 0,   0]) cylinder(h=hh, d=dd+2*w, $fn=fn);
        }
        union() {
          // inner cylinder
          translate([0, 0,  -0.5])  cylinder(h=3, d=dd+c, $fn=fn);
          translate([0, 0,  -0.5])  cylinder(h=hh+1, d=dd,   $fn=fn);
          // O-Ring-Nut
          // rotate_extrude($fn=fn) translate([(dd)/2,1]) circle(d=1);
          // ridge, Einrast-Nut
          rotate_extrude($fn=fn) translate([dd/2+w,hr]) circle(d=1.2);
        }
      } 
}

// water outlet part, plug on nozzleA
module nozzleB(
    dd=27,       // design inner diameter
    hh=20,       // height of cylindrical section
    hr=10,       // height of overlapping region, distance to ridge of nozzleA
    xx=28,       // square section width
    yy=10,       // distance to end
    zz=9.4,      // square section height
    w=1.6,       // wall thickness
    c=0.6,       // clearance
    ang=15
    ) {
      do=(dd+4*w);       // outer diameter of nozzle
      h1=tan(ang)*do/2;  // required height excess according to tilt angle
      difference() {
        union() {
          // outer cylinder
          translate([0, 0,   0]) cylinder(h=hh+2*h1, d=dd+4*w, $fn=fn);
        }
        union() {
          // Innendurchmesser
          translate([0, 0,   -0.01+hr]) cylinder(h=hh+2*h1-hr, d=dd+2*w, $fn=fn);
          // Stufe
          translate([0, 0,   -0.1]) cylinder(h=hr+0.1, d=dd+2*w+c, $fn=fn);
          //cube([20,20,30]);  // debug: cross section
          translate([0, 0,   hh+h1]) rotate([-ang,0,0]) translate([0,0,dd]) cube([dd*8,dd*8,dd*2], center=true);
        }
      } 
}

// bent water outlet part, plug on nozzleA
module nozzleC(
    dd=27,       // design inner diameter
    hh=20,       // overall height of cylindrical section
    hr=10,       // height of overlapping region, distance to ridge of nozzleA
    w=1.6,       // wall thickness
    ang=25
    ) {
      do=(dd+4*w);  // outer diameter of nozzle
      h1=tan(ang)*do/2;  // required height excess according to tilt angle
      union() {
        translate([0, 0, -(hh+h1)]) nozzleB(ang=ang,dd=dd, hh=hh, hr=hr, w=w);
        rotate([-2*ang,0,0]) 
        translate([0, 0, (hh+h1)]) mirror([0,0,1]) nozzleB(ang=ang,dd=dd, hh=hh, hr=hr, w=w);
      } 
}

// fixture for nozzleA
module sliderA(
    dd=27,       // design inner diameter
    hh=20,       // height of cylindrical section
    xx=28,       // square section width
    yy=10,       // distance to end
    zz=9.4,      // square section height
    w=1.6,       // wall thickness
    b=1.2,       // bottom thickness
    c=0.6        // clearance
    ) {
      c2=c/2;
      difference() {
        union() {
          // bottom (top)
          translate([0, 0, (zz+2.5*w+b)/2]) cube([ xx+4*w, 2*yy+dd+w, zz+2.5*w+b], center=true);
        }
        union() {
          translate([0, w, (zz+2*w+b)/2+w]) cube([ xx+c, 2*yy+dd, zz+3*w+b], center=true);
          // Nut
          translate([0, w, (w+c)/2+w+zz]) cube([ xx+2*w+c, 2*yy+dd+2*w, w+c], center=true);
          // the outer diameter of nozzleA is a bit too large, cut out, snap.
          translate([0, 0,  w+zz]) cylinder(h=hh, d=dd+2*w, $fn=fn);
          // optional center hole to reduce warping
          translate([0, 0,   -0.1]) cylinder(h=hh/2+c, d=24, $fn=fn);
        }
      } 
}


//---------------- explosion view ---------------------

// optional view to create a picture of all parts
if ( false ) {
translate([0, 0,   25]) nozzleA();
translate([0, 0,   85]) mirror([0,1,0]) nozzleC();
sliderA();
}

//---------------- Instances ---------------------

nozzleA();
//mirror([0,1,0]) nozzleC();
//sliderA();
