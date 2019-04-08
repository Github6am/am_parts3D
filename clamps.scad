// clamps for various purposes
//
//
// Background:
//   - Greenhouse clamp - Weinranken am Gewaechshaus befestigen
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-03-10, v0.2 
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

//---------------- Instances ---------------------

clampshape3();

//schwalbenschwanz_hollow(h=2);
