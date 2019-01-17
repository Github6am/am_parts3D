

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

module halfsphere(r=1) {
  intersection() { 
    sphere(r, $fn=20); 
    translate([-2,-2,0]*r) cube(4*r);
  }
}


module trapezrot(r=1) {
   rotate_extrude($fn=20)
      polygon([[0,r/2],[r,r/3],[r,-r/3],[0,-r/2]]);
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

//------------------------
// simple brick-shaped box
//------------------------
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

//------------------------
// stackable box
//------------------------
module am_boxB(x=100, y=100, z=20) {
  // x,y,z: inner dimensions
  w=0.8;         // wall thickness
  c=0.9;         // clearance
  sx=(x+2*w+c)/x;  // slope factor x
  sy=(y+2*w+c)/y;  // slope factor y
  union() {
    difference() {
      union() {
        minkowski() {                    // outer contour, chamfered
          linear_extrude(height=z, scale=[sx,sy]) square([x,y],center=true);
          rotate([180,0,0]) halfsphere(r=w);
        }
        translate([0,0,3])               // stacking rim
          minkowski() { 
            linear_extrude(height=0.1) 
              square([x+2*w,y+2*w],center=true);
            trapezrot(r=w);
          }
            
      }
      linear_extrude(height=z+0.05, scale=[sx,sy]) square([x,y],center=true); // inner box
    }
  }
}

//---------------- Instances ---------------------

//octaeder(r=10);

translate([0,0,0]) am_boxB(x=50);

//trapezrot(r=10);
