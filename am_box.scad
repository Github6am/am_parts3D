// some simple but versatile thin-walled storage boxes
//
//
// Background:
//   - CAD manual: http://www.openscad.org/documentation.html
//   - possibility to attach to parts from raspi_RJ45fix.scad
//
// Andreas Merz 2019-01-12, v0.8 
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

module schwalbenschwanz(h=2, w1=4, w2=6) {
             //w1=(w2-h*tan(30));      // Flankenwinkel 30 deg
             c=0.13;   // clearance / spiel in mm
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}

module dovetail3D(h=20, s=45, t=0.8) {
         c=0.3;   // clearance / spiel in mm
         difference() { 
           linear_extrude(height=h)
              union() {
                schwalbenschwanz();
                translate([-2+c,-t]) square([4-2*c,t]);

              }
           rotate([s,0,0]) translate([-4,0,-4]) cube([8, 4, 4]);
         }
 }


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

// add-on to avoid warping
module mouseear4(xm=50, ym=100, hm=0.45) {
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
module am_boxA(x=50, y=100, z=20) {
  // x,y,z: inner dimensions
  w=0.8;    // wall thickness
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
module am_boxB(x=50, y=100, z=20) {
  // x,y,z: inner dimensions
  w=0.8;         // wall thickness
  c=0.6;         // clearance
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
            trapezrot(r=w+c/2);
          }
      }
      linear_extrude(height=z+0.05, scale=[sx,sy]) square([x,y],center=true); // inner box
    }
  }
}

//-----------------------------------------------------------
// stackable box with dove tail connection / label holder
//-----------------------------------------------------------
module am_boxC(x=50, y=100, z=20) {
  // x,y,z: inner dimensions
  w=0.8;         // wall thickness
  c=0.6;         // clearance
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
            trapezrot(r=w+c/2);
          }
        
        // dovetail connector
        translate([-2*10+5,-(y/2+2*w+c/2),3]) rotate(180) dovetail3D(h=z-3);
        translate([+2*10-5,-(y/2+2*w+c/2),3]) rotate(180) dovetail3D(h=z-3);
        translate([-2*10+0, (y/2+2*w+c/2),3]) rotate(  0) dovetail3D(h=z-3);
        translate([+2*10-0, (y/2+2*w+c/2),3]) rotate(  0) dovetail3D(h=z-3);
      }
      linear_extrude(height=z+0.05, scale=[sx,sy]) square([x,y],center=true); // inner box
    }
  }
}

//---------------------------------
// label to fit between dovetail 
//---------------------------------
// for symbols, consider png23d
//
module am_boxlabelA( txt="1", lx=25, ly=15, align=2/3 ) {
  // lx:    label width, actually it will be 1 mm more to fit between dovetails
  // ly:    label heigth
  w=0.8;               // thickness
  fontname = "Liberation Sans";
  fontsize = 5;
  c=0.3;               // clearance - negative: make tighter
  s=1-w/(2*(lx+1-c));  // scale factor
  union() {
    translate([(lx+1-c)/2,ly/2,0]) linear_extrude(height = w, scale=[s,1]) 
      square([lx+1-c,ly],center=true);
    color("red")
    translate([lx/2,ly*align,w]) linear_extrude(height = 0.4) 
      text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 16);
  }
}

module am_boxlabel( txt="1", lx=25, ly=15, align=2/3 ) {
  // lx:    mean label width
  w=0.8;               // thickness
  fontname = "Liberation Sans";
  fontsize = 5;
  c=0.3;               // clearance
  difference() {
    union() {
      translate([0,0,0]) linear_extrude(height = w) 
        square([lx+2,ly]);
      color("red")
      translate([(lx+0.5)/2,ly*align,w]) linear_extrude(height = 0.4) 
        text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 16);
    }

    union() {
        translate([-5/2+0.8+c,-1,0.75]) rotate([92.5,0,180]) dovetail3D(h=ly+2);
        translate([lx+5-5/2,  -1,0.75]) rotate([92.5,0,180]) dovetail3D(h=ly+2);
    }
  }
}


//---------------- Instances ---------------------

//octaeder(r=10);
//trapezrot(r=10);

//translate([0,0,0]) am_boxC();
//translate([0,106,0]) am_boxC();
translate([0,106,0]) am_boxC(z=37);  // double height

if ( 0 ) {
  // do not forget to change color in slicer before the text layers
  translate([0, 2*17,0]) am_boxlabel(lx=35,txt="Baubles");
  translate([0, 1*17,0]) am_boxlabel(lx=35,txt="Bangles");
  translate([0, 0*17,0]) am_boxlabel(      txt="Beads");
  translate([0,-1*17,0]) am_boxlabel(      txt="Rings");
}
