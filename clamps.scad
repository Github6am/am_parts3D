// clamps for various purposes
//
//
// Background:
//   - Greenhouse clamp - Weinranken am Gewaechshaus befestigen
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2020-04-19, v0.3 
// GPLv3 or later, see http://www.gnu.org/licenses


//---------------- Primitives ---------------------

// Werkzeuge, um Fasen mit minkowski() herzustellen

module pyramid(h=1) {
    linear_extrude(height=h, scale=0) rotate([0,0,45]) square(sqrt(2)*h,center=true);
}

module octaeder(r=0.3) {
  union() {
    pyramid(h=r);
    rotate([180,0,0]) pyramid(h=r);
  }
}

module clampshape1half(s1=3.7, y1=17.5) {
             // y1        // clamp length
             // s1        // clamp width at bottom
             c=0.3;       // clearance / spiel in mm
             w=2;         // wall thickness
             b=w*3/2;     // bottom thickness
             m=0.3;       // reduce shape for minkowski()
             s2=(s1+c)/2;     // width at bottom
             translate([0,b])
               polygon(points=[
                [0,0-m],[s2-0.3+m,0-m],[s2-0.1+m,0.1-m],[s2+m,0.3-m],[s2+0.1+m,0.5-m],[s2+m+0.1,1-m],[s2+m,1.5-m],
                [s1/2-c-0.1+m,3.5],[s2+m,5], 
                [min(0.35,s1/2-1+0.05)+m,y1-3],[min(0.3,s1/2-1)+m,y1-2.5],[min(0.3,s1/2)+0.2+m,y1-2.1],
                [(s1+1)/2+m/2,y1-m],                   // outer contour starts here
                [min(0.3,s1/2-1)+w-0.9-m,y1-2.8],
                [s2+w-m-c,5],
                [1+s2+w-m,0],
                [1+s2+w-m,-b+m],
                [0,-b+m]]);
}


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

module schwalbenschwanz_hollow(h=2, w1=4, w2=6, w3=0.9) {
        // w3      // wall thickness
        c=0.13;   // clearance / spiel in mm
        difference() {
             schwalbenschwanz(h=h, w1=w1, w2=w2);
             schwalbenschwanz(h=h-w3+c, w1=w1-2*w3, w2=(w2-w1)/2*(h-w3+c)/h + w1-w3-2*c);
        }  
}

module dovetail3D(h=20, s=45, t=0.8) {
         c=0.3;   // clearance / spiel in mm
         difference() { 
           linear_extrude(height=h)
              union() {
                schwalbenschwanz_hollow();
                translate([-2+c,-t]) square([4-2*c,t]);

              }
           union() {
             rotate([s,0,0]) translate([-4,0,-4]) cube([8, 4, 4]);
             //translate([0,0,(h+1)/2]) cube([1.6+c, 2.2+c, 4*h+2], center=true);
           }
         }
 }


//---------------- Clamps ---------------------

module clampshape1(clampwidth=3.7, clamplength=17.5, cz=20) {
     w=2;
     union() {
       minkowski() {
         linear_extrude(height=cz)
           union() {
             mirror() 
             clampshape1half(s1=clampwidth, y1=clamplength);
             clampshape1half(s1=clampwidth, y1=clamplength);
           }
          octaeder();
       } 
       //translate([0,-w,cz/2]) rotate([90,90,0]) linear_extrude(height=0.2) text(str(clampwidth), size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 32);
     }
}

module clampshape2(clampwidth=3.7, clamplength=17.5, cz=20) {
     w=2;
     fontsize = 4;
     //fontname = "Liberation Sans";
     fontname = "FreeSans:Bold";
     union() {
       clampshape1(clampwidth=clampwidth, clamplength=clamplength, cz=cz);
       translate([0,0,cz/2]) rotate([90,90,0]) linear_extrude(height=0.3) text(str(clampwidth), size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 32);
     }
}

module clampshape3(clampwidth=3.7, clamplength=17.5, cz=20) {
     w=2;
     m=0.3;
     union() {
         clampshape2(clampwidth=clampwidth, clamplength=clamplength, cz=cz);
         translate([0,0,  cz/4-m]) rotate(180) rotate([0,180]) dovetail3D(h=cz/4, s=45, t=m);
         translate([0,0,3*cz/4+m]) rotate(180) rotate([0,  0]) dovetail3D(h=cz/4, s=45, t=m);
     }       
}

module clampshape4(clampwidth=3.7, clamplength=17.5, cz=20) {
     w=2;
     m=0.3;
     wl=1.2;   // wall thickness of attachment loops
     fontsize = 4;
     //fontname = "Liberation Sans";
     fontname = "FreeSans:Bold";
     union() {
         clampshape1(clampwidth=clampwidth, clamplength=clamplength, cz=cz);
         translate([0,-w -(4-2*wl)/2,  cz/2]) 
           difference() {
           cube([6.5,    4,    cz+2*m],   center=true);
           union() {
             cube([6.5-2*wl, 4-2*wl, cz+2*m+2], center=true);
             cube([6.5+2,    4-2*wl, cz/2], center=true);
           }
         }
         // add text
         translate([0,-w-(4-wl),cz/2]) rotate([90,90,0]) linear_extrude(height=0.3) text(str(clampwidth), size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 32);
     }       
}

//---------------- Book stand, Standfuss fuer Leitz-Order ---------------------

module pedestalshape2D(
     clampwidth=3.4,   // thickness of the book cover incl. tolerance
     clamplength=25,
     bookheight=330,   // just needed to calculate the angle to keep center of gravity
     xp=100,           // length of pedestal foot
     yp=100,           // heigth of pedestal
     yw=3              // bottom thickness
     ) {
     scale=0.6;        // scale factor of cut out triangle
     cr=1.5;           // chamfer / radius
     y=sqrt(bookheight*bookheight -xp*xp);
     x1=xp*yp/y;
     p1=[0,0];
     p2=[xp,0];    // left point
     p3=[x1,yp];   // top point

     mr=[[0,-1],[1,0]];
     v13 = p3-p1;
     e13 = v13/norm(v13); // unit direction vector of book contact side
     n13 = mr*e13;        // normal vector of book contact side
     p4= p1+yw*e13;
     p5= p4 + n13*(clampwidth+2*cr);
     p6= p5 + e13*clamplength-0.15*n13*clampwidth;  // slight cone, narrowing 15%
     p7= p6 + n13*cr/2;
     t = -p6[2]/n13[2];
     p8= p1 +[-9,0];
     pcenter=(p1+p2+p3)/3;
     difference() {
       offset(r=cr,$fn=12) polygon(points=[ p1,p2,p3,p4,p5,p6,p7,p8 ]*1.0);
       union() {
         translate(pcenter*((1-scale))) offset(r=6) polygon(points=[ p1,p2,p3 ]*scale );
         // radius at the notch bottom
	 translate((p4+p5)/2 + cr*e13) circle(d=clampwidth, $fn=24);
	 // dirty, fixme: hole position at the top
	 translate(p3-0.13*yp*[-0.1,1]) circle(d=5.2, $fn=24);
       }
     }       
}

// Book stand, Musical Stand, Notenstaender
module pedestalA(
     xp=100,           // length of pedestal foot
     z=3,              // z thickness
     foot=20,          // foot width
     ) {
     // dirty: may not fit anymore, if parameters of pedestalshape2D are changed
     difference() {
       linear_extrude(height=foot) pedestalshape2D(xp=xp);
       
       // cut away excess material
       union() {
         translate([  -xp, 5, z+0.01])  cube([2*xp,500,20-z], center=false);
         translate([  (2*foot+10)/4, -30, z+0.01])  cube([xp-2*foot+10,500,foot-z], center=false);
       }
     }
}



//---------------- Weidenzweige arrangieren ---------------------
// https://www.thingiverse.com/thing:4432806
// this is a fixture to arrange 12 or 24 cut branches of a
// willow tree to form a hyperboloidal structure
// Ideally, two instances are used to yield a well-defined geometry.
//
// of course, it may also be used to create a magnetic loop antenna;
// if n is choosen to be odd.  :-)

// default globals
wz_n=24;    // number of segments
wz_w=4;     // width of structures
wz_s=16;    // space between rims
wz_c=0.4;   // clearance
wz_r1=50;   // nominal inner diameter

module hyperboloid(r1=wz_r1+wz_s/2, h1=50) {
  w=2;
  phioff=5;
  slant=45;
  for(ii=[0:15:360])
     rotate([0,0,ii+phioff])
       translate([r1,0,0]) rotate([slant,0,0]) rotate([0,0,22.5])
         cylinder(r=w/2, h=h1/cos(slant),center=true, $fn=16);
}

module starwheel1(r1=wz_r1) {
  // Nachteil: muss zerstoert werden beim Entfernen.
  n=wz_n;
  w=wz_w;
  s=wz_s;
  c=wz_c;   // clearance
  linear_extrude(height=w)
  union() {
    difference() {
      for(ii=[0:360/n:360]) {
	 rotate([0,0,ii])
	   union() {
             //translate([0,0,0]) polygon(points=[ [0,0],[r1+w+s,-w],[r1+w+s,+w]]);
	     translate([r1,0,0])square([s,w-c/2]);
	     circle(r=r1+w, $fn=4*n);
	   }
      }
      circle(r=r1+c/2, $fn=4*n);
    }
    // outer rim
    difference() {
      circle(r=r1+s+w*1.0, $fn=4*n);
      circle(r=r1+s -c/2,  $fn=4*n);
    }
  }
}

module starwheel2(r1=wz_r1) {
  n=wz_n;
  w=wz_w;
  s=wz_s;
  c=wz_c;   // clearance
  difference() {
    // star
    linear_extrude(height=w)
    difference() {
      for(ii=[0:360/n:360]) {
	 rotate([0,0,ii])
	   union() {
	     translate([r1,0,0]) square([s+1.5*w,w-c]);
	     circle(r=r1+w, $fn=4*n);
	   }
      }
      circle(r=r1, $fn=4*n);
    }
    // outer rim gaps
    translate([0,0,w/2])
      linear_extrude(height=w)
	difference() {
	  circle(r=r1+s+w+c/2, $fn=4*n);
	  circle(r=r1+s-c/2,   $fn=4*n);
	}
  
  }
}


module starwheel3(r1=wz_r1) {    // outer rim to click into starwheel2
  n=wz_n;
  w=wz_w;
  s=wz_s;
  c=wz_c;   // clearance
  rotate([0,0,0.75*180/n])
  difference() {
    // outer rim
    translate([0,0,0])
      linear_extrude(height=w)
	difference() {
	  circle(r=r1+s+w-c/2, $fn=4*n);
	  circle(r=r1+s  +c/2, $fn=4*n);
	}
    // star gaps
    translate([0,0,w/2])
      linear_extrude(height=w)
	for(ii=[0:360/n:360]) {
	   rotate([0,0,ii])
	     union() {
	       translate([r1,0,0]) square([s+1.5*w,w+c]);
	       circle(r=r1+w, $fn=4*n);
	     }
	}
  }
}


module starwheel4(r1=wz_r1) {     // outer rim segments to click into starwheel2
  n=wz_n;
  w=wz_w;
  s=wz_s;
  c=wz_c;   // clearance
  difference() {
    translate([0,0,0]) starwheel3();
    union() {
      rotate([0,0, asin(2/2*w/(r1+w+s))]) translate([0,0,-0.1])         cube([(r1+w+s), r1+w+s, w+0.2]);
      rotate([0,0,-asin(2/2*w/(r1+w+s))]) translate([-(r1+w+s),0,-0.1]) cube([(r1+w+s), r1+w+s, w+0.2]);
      // Endverschluss rechts
      rotate([0,0,-asin(1/2*w/(r1+w+s))]) translate([(r1+s+w/2)/2,0,0]) cube([(r1+s+w/2), w+c,   w+0.2], center=true);
      rotate([0,0,-asin(1/2*w/(r1+w+s))]) translate([(r1+s+w/2)/2,0,w]) cube([(r1+s+w*2), w+c,   w+0.2], center=true);
      rotate([0,0, asin(1/2*w/(r1+w+s))]) translate([(r1+s+w/2)/2,0,w]) cube([(r1+s+w/2), w+c,   w+0.2], center=true);
      // Endverschluss links
      rotate([0,0, asin(1/2*w/(r1+w+s))]) translate([-3*(r1+s+w/2)/2,0,w]) cube([(r1+s+w/2), w+c, w+0.2], center=true);
      rotate([0,0, asin(1/2*w/(r1+w+s))]) translate([-3*(r1+s+w/2)/2,0,0]) cube([(r1+s+w*2), w+c, w+0.2], center=true);
      rotate([0,0,-asin(1/2*w/(r1+w+s))]) translate([-3*(r1+s+w/2)/2,0,0]) cube([(r1+s+w/2), w+c, w+0.2], center=true);
    }
  }  
}

//---------------- Instances ---------------------

//clampshape3();

//schwalbenschwanz_hollow(h=2);

//translate([0,0,20]) hyperboloid();
//starwheel2();
//starwheel4();

pedestalA();
