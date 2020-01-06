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
dt_c=0.18;            // lateral clearance / spiel in mm


// 2D shapes

module dt_shapeNominal(h=dt_h, w1=dt_w1, w2=dt_w2, c=0) {
             hh=h-c;
	     y2=w2/2*hh/h-c;   // keep slope angle, even if c is not 0;
	     y1=w1/2-c;
             polygon(points=[[-y1,0],[y1,0],[y2,hh],[-y2,hh]]);
}

module dt_shapeMajor() {
  dt_shapeNominal(c=-dt_c);
}

module dt_shapeMinor() {
  dt_shapeNominal(c=dt_c);
}

module re_shapeNominal(h=dt_h, w1=5/3, w2=dt_w2, c=0) {
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}

// 3D shapes

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


module am_lead_in(h=20, t=1.1, sub=0) {
}



// Dovetail to be attached to another body

module am_dovetailAdd(h=20, t=1.1, sub=0) {
    //t:  transition region
    cc=dt_c/2;
    sy=(dt_h-dt_c)/(dt_h-dt_c-t);
    union () {
      translate([0,0,0])
	linear_extrude(height=t, scale=sy)
          dt_shapeNominal(w1=(2*dt_w1-dt_c)/2/sy*0.93, w2=(2*dt_w2-dt_c)/2/sy*0.86, h=dt_h-t-dt_c, c=0);
          //dt_shapeNominal(w1=(2*dt_w1-dt_c)/2/sy*1.16, w2=(2*dt_w2-dt_c)/2/sy*1.27, h=dt_h-t, c=dt_c);
      translate([0,0,t])
	linear_extrude(height=h-2*t, scale=1)
	  dt_shapeNominal(c=dt_c);
      translate([0,0,h]) mirror([0,0,1])
        linear_extrude(height=t, scale=sy) 
          dt_shapeNominal(w1=(dt_w1+cc)/sy, w2=(dt_w2+cc)/sy, h=dt_h-t, c=dt_c);
    }
}


// Dovetail to be carved out of another body

module am_dovetailSub(h=20, t=0.8) {
    //t:  transition region
    sy=dt_h/(dt_h+t);
    cc=+dt_c/2;
    union () {
      translate([0,0,0])
	linear_extrude(height=t, scale=sy)
          dt_shapeNominal(w1=(dt_w1+cc)/sy, w2=(dt_w2+cc)/(sy), h=dt_h+t, c=-dt_c);
      translate([0,0,t])
	linear_extrude(height=h-2*t, scale=1)
	  dt_shapeNominal(c=-dt_c);
      translate([0,0,h]) mirror([0,0,1])
        linear_extrude(height=t, scale=sy) 
          dt_shapeNominal(w1=(dt_w1+cc)/sy, w2=(dt_w2+cc)/(sy), h=dt_h+t, c=-dt_c);
    }
}



//------------- Instances --------------------

am_dovetailAdd();


