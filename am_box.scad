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
             c=0.16;   // clearance / spiel in mm
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
// box with separator wall 
//---------------------------------
module am_boxWall(x=50, y=40, z=20) {
  w=0.8;         // wall thickness
  c=0.6;         // clearance
  t=3.2;         // clearance on top of wall
  sx=(x+2*w*(z-t)/z+c)/x;  // slope factor x
         linear_extrude(height=z-t,scale=[sx,1]) 
           square([x+w,w],center=true);
}

module am_boxD(x=50, y=100, z=20) {
  yratio=0.6;  // size ratio of compartments
  union() {
    am_boxC(x=x, y=y, z=z);
    translate([0,y*(0.5 - yratio),0]) am_boxWall(x=x, y=y, z=z);
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

module am_boxlabel( txt="1", lx=25, ly=15, align=1/2, fontname = "FreeSans:Bold" ) {
  // lx:    mean label width
  w=0.8;               // thickness
  //fontname = "Liberation Sans";
  fontsize = 7;
  c=0.3;               // clearance
  difference() {
    union() {
      translate([0,0,0]) linear_extrude(height = w) 
        square([lx+2,ly]);
      color("red")
      translate([(lx+0.5)/2,ly*align,w]) linear_extrude(height = 0.4) 
        text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 40);
    }

    union() {
        translate([-5/2+0.8+c,-1,0.75]) rotate([92.5,0,180]) dovetail3D(h=ly+2);
        translate([lx+5-5/2,  -1,0.75]) rotate([92.5,0,180]) dovetail3D(h=ly+2);
    }
  }
}


//---------------------------------
// handle to attach to am_box 
//---------------------------------
module am_boxhandleHalf(lx=40, ly=15, b=0) {
   // b: additional spacing from center line
   c=0;             // dummy
   h=5;             // height of dovetails
   w=1.0;           // thickness of handle
   t=4;             // trapez shape
   union() {
     // handle
     linear_extrude(height=w)
        polygon(points=[[0,0],[lx/2-c,0], [lx/2-c,-t],[lx/2-c-t,-ly],[0,-ly]]);
     // dovetail connection
     linear_extrude(height=h)
       difference() {
         union() {
           translate([ 1*10+0+b,0]) schwalbenschwanz();
           translate([ 2*10+0+b,0]) schwalbenschwanz();
         }
         union() {
           translate([ 0*10+0+b,-0.1]) square([10,3]);
           translate([ 2*10+0+b,-0.1]) square([10,3]);
         }
       }
       // reinforcement
       linear_extrude(height=h, scale=[1,0])
       rotate(180)
       union() {
         translate([-2*10+0-b,-0.1]) square([2,t]);
         translate([-1*10-2-b,-0.1]) square([2,t]);
       }
     }
}

module am_boxhandleA( txt="A", align=1/2, ly=15, fontname = "FreeSans:Bold",  fontsize = 10 ) {
   w=1.0;           // thickness of handle
   union() {
        // handle
        am_boxhandleHalf(lx=40, ly=15);
        mirror([1,0,0]) 
        am_boxhandleHalf(lx=40, ly=15);
        // text
        if ( txt != "" ) {
          translate([0,-ly*align,w]) linear_extrude(height = 0.4) 
            text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 40);
        }
   }
}

module am_boxhandleB( txt="B", align=1/2, ly=15, fontname = "FreeSans:Bold",  fontsize = 10 ) {
   w=1.0;           // thickness of handle
   union() {
        // handle
        am_boxhandleHalf(lx=50, ly=15, b=5);
        mirror([1,0,0]) 
        am_boxhandleHalf(lx=50, ly=15, b=5);
        // text
        if ( txt != "" ) {
          translate([0,-ly*align,w]) linear_extrude(height = 0.4) 
            text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 40);
        }
   }
}


//---------------------------------
// gauge to check screw diameters
//---------------------------------

module am_gauge( fontname = "FreeSans:Bold" ) {
  w=0.8;               // thickness
  //fontname = "Liberation Sans";
  fontsize = 4;
  c=0.3;               // clearance
  n=7;                 // step length
    union() {
      translate([0,0,0]) linear_extrude(height = w) 
        difference() {
          translate([-15,-5,0]) square([20,80]);
          polygon([ [-1.5,10*n],[-1.5,9*n],
                    [-2.0,9*n],[-2.0,8*n],
                    [-2.5,8*n],[-2.5,7*n],
                    [-3.0,7*n],[-3.0,6*n],
                    [-3.5,6*n],[-3.5,5*n],
                    [-4.0,5*n],[-4.0,4*n],
                    [-4.5,4*n],[-4.5,3*n],
                    [-5.0,3*n],[-5.0,2*n],
                    [-5.5,2*n],[-5.5,1*n],
                    [-6.0,1*n],[-6.0,0*n],
                    [c, 0],    [c,10*n] ]);
      }
      color("red")
      translate([0,3,w]) linear_extrude(height = 0.4) 
      union() {
        translate([-14,9*n]) text("1.5", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,8*n]) text("2  ", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,7*n]) text("2.5", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,6*n]) text("3  ", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,5*n]) text("3.5", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,4*n]) text("4  ", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,3*n]) text("4.5", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,2*n]) text("5  ", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,1*n]) text("5.5", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
        translate([-14,0*n]) text("6  ", size = fontsize, font = fontname, halign = "left", valign = "center", $fn = 32);
      }
    }

}


//---------------- Instances ---------------------

//octaeder(r=10);
//trapezrot(r=10);

am_boxhandleA();

//translate([0,0,0]) am_boxD();
//translate([0,106,0]) am_boxC();
//translate([0,106,0]) am_boxC(z=20);  // double height

/*
if ( 0 ) {
  // do not forget to change color in slicer before the text layers
  translate([0, 2*17,0]) am_boxlabel(lx=35,txt="Baubles");
  translate([0, 1*17,0]) am_boxlabel(lx=35,txt="Bangles");
  translate([0, 0*17,0]) am_boxlabel(      txt="Beads");
  translate([0,-1*17,0]) am_boxlabel(      txt="Rings");
}
if ( 1 ) {
  // do not forget to change color in slicer before the text layers
  translate([0, 3*17,0]) am_boxlabel(txt="M 8");
  translate([0, 2*17,0]) am_boxlabel(txt="M 6");
  translate([0, 1*17,0]) am_boxlabel(txt="M 5");
  translate([0, 0*17,0]) am_boxlabel(txt="M 4");
  translate([0,-1*17,0]) am_boxlabel(txt="M 3");
  translate([0,-2*17,0]) am_boxlabel(txt="M 2.5");
  translate([0,-3*17,0]) am_boxlabel(txt="M 2");

  translate([27, 3*17,0]) am_boxlabel(txt="\u2300 8", fontname="FreeSans:style=Mittel");
  translate([27, 2*17,0]) am_boxlabel(txt="\u2300 6", fontname="FreeSans:style=Mittel");
  translate([27, 1*17,0]) am_boxlabel(txt="\u2300 5", fontname="FreeSans:style=Mittel");
  translate([27, 0*17,0]) am_boxlabel(txt="\u2300 4", fontname="FreeSans:style=Mittel");
  translate([27,-1*17,0]) am_boxlabel(txt="\u2300 3", fontname="FreeSans:style=Mittel");
  translate([27,-2*17,0]) am_boxlabel(txt="\u2300 2.5", fontname="FreeSans:style=Mittel");
  translate([27,-3*17,0]) am_boxlabel(txt="\u2300 2", fontname="FreeSans:style=Mittel");
}

translate([-7,-9,0]) am_gauge();
*/
