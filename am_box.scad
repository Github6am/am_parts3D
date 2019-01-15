

// Werkzeuge, um Fasen mit minkowsky() herzustellen

module pyramid(h=1) {
    linear_extrude(height=h, scale=0) rotate([0,0,45]) square(sqrt(2)*h,center=true);
}

module octaeder(r=1) {
  union() {
    pyramid(h=r);
    rotate([180,0,0]) pyramid(h=r);
  }
}

module mouseear4(xm=100, ym=100, hm=0.45) {
  rm=9;
  linear_extrude(height=hm)
    union() {
      translate([0,  0]) circle(r=rm);
      translate([xm, 0]) circle(r=rm);
      translate([0, ym]) circle(r=rm);
      translate([xm,ym]) circle(r=rm);
    }
}


module am_boxA(x=100, y=100, z=20) {
  // x,y,z: inner dimensions
  w=1;    // wall thickness
  union() {
    difference() {
      minkowski() {        // outer contour, chamfered
        cube([x,y,z]);
        rotate([180,0,0]) pyramid(h=w);
      }
      cube([x,y,z+w]);
    }
  }
}

module am_boxB(x=100, y=100, z=20) {
  // x,y,z: inner dimensions
  w=1;    // wall thickness
  union() {
    difference() {
      minkowski() {        // outer contour, chamfered
        cube([x,y,z]);
        rotate([180,0,0]) pyramid(h=w);
      }
      translate([0.25, 0.25, 0]) // inner box
      minkowski() {        // outer contour, chamfered
        cube([x-0.5,y-0.5,z+w]);
        cylinder(r=0.25,h=0.1,$fn=32);
      }
    }
  }
}

//---------------- Instances ---------------------

//octaeder(r=10);

am_boxA(x=50);


