// Nozzle
// 
// 
// Background:
//   - select the desired instances at the bottom of this file
//     and use openscad to generate according STL files.
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-09-20, v2 
// GPLv3 or later, see http://www.gnu.org/licenses

dnozzle=10;   // nozzle diameter, this determines the thrust

module oshape(w=2.8,d=3) {
  s=0.25*w;  // slant upper wall to allow for 3D printing without supports
  polygon([[0,0],[0,w-s],[d,w+s],[d,0]]);
}

//-------------------------------------
// Schubduese
//-------------------------------------
function fnoz(r1, r2, num=32, l=20, inslope=1) = 
  [for (i=[0:num-1], x=i*l/num) [ x, 30/sqrt(x+0.2) ]];

module nozzle( d1=20, d2=20, l=30, n=10) {
     rotate_extrude($fn = 80) polygon(fnoz(r1=d1/2,r2=d2/2,l=l));
}

module nozzle2(lcyl=20,lcon=15) {
  r=dnozzle/2;
  R=20/2;
  w=0.1;   // excess, needed in difference
  m=10;   // rounding radius
  c=0.15;  // clearance
  rotate_extrude($fn = 90) 
  //offset(r=-m) {   // trick to create a smooth transition
  //  polygon( [[-m,-m-w],[R+m,-m-w],[r+m,lcon],[r+m,lcyl+lcon+m+w],[-m,lcyl+lcon+m+w]]);
  difference() {
    polygon( [[0,0-w],[R+c,0-w],[R+c,lcyl+lcon+w],[0,lcyl+lcon+w]]);
    minkowski() {
      polygon( [[R+m+c,0-w],[r+m+c,lcon],[r+m+c,lcyl+lcon+w+m],[R+m+c,lcyl+lcon+w+m]]);
      circle(r=m,$fn = 90);
    }
  }
}

module cola_nozzle1(diaouter=21.6, diainner=dnozzle, hh=35, hrim=5) {
  // Diese Duese steht nach innen, ist also zu lang.
  // und sie muss reingeklebt werden.
  c=0.3;
  difference() {
    union() {
      linear_extrude(height = hrim)    // rim
        circle((diaouter+2-c)/2, $fn = 90);
      linear_extrude(height = hh, scale=0.98)    //  
        circle((diaouter-c)/2, $fn = 90);
    }
    union() {
      translate([0,0,-1])
        linear_extrude(height = hh+4)    // bore hole
          circle(d=diainner+c, $fn = 90);  //center hole
      translate([0,0,hh-10])
        linear_extrude(height = 10+1, scale=(diaouter-1)/diainner)    // upper cone
          circle(d=diainner, $fn = 90);  //center hole
      translate([0,0,-1])
        linear_extrude(height = 10, scale=0)    // bottom cone
          circle(d=diainner+4, $fn = 90); 
      //--- O-Ring Nut ---
      translate([0,0,hh-20])
         rotate_extrude($fn = 80)
           translate([diaouter/2-2.4,0,0]) oshape();
    }
  }
}

module cola_nozzle2(diaouter=21.8, diainner=dnozzle, hh=20, hrim=15) {
  // Diese Duese muss mit einem durchbohrten Flaschendeckel fixiert werden
  // ein Kabelbinder verhindert, dass die Duese ins Flascheninnere gedrueckt werden kann
  c=0.3;
  drim=15;
  difference() {
    union() {
      // Aussenkontur
      translate([0,0,hh])
      linear_extrude(height = hrim)    // rim
        circle(d=drim, $fn = 90);
      linear_extrude(height = hh)    //  
        circle(d=(diaouter-c), $fn = 90);
    }
    union() {
      if( false ) {
        // nozzle: cone + cylinder
        translate([0,0,-1])
          linear_extrude(height = hh+4+hrim)    // bore hole
            circle(d=diainner+c, $fn = 90);  //center hole
        translate([0,0,-0.01])
          linear_extrude(height = hh-8, scale=diainner/(diaouter-3))    // nozzle cone
            circle(d=diaouter-3, $fn = 90);  //center hole
      } else {
        nozzle2();
      }
      // die folgende Fase hilft, dass der O-Ring des Launchers leichter reingeht.
      translate([0,0,hh+hrim-2])
        linear_extrude(height = 3.1, scale=1.2)    // bottom cone ( on top)
          circle(d=diainner, $fn = 90); 
      //--- O-Ring Nut ---
      translate([0,0,hh-8])
         rotate_extrude($fn = 80)
           translate([diaouter/2-2.4,0,0]) oshape();
      //--- Kabelbinder Nut ---
      translate([0,0,hh+2])
         rotate_extrude($fn = 80)
           translate([drim/2-0.6,0,0]) oshape(w=10,d=8);
    }
  }
}

//-------------------------------------
// Druckluftadapter / Startvorrichtung
//-------------------------------------

module cola_launcher1(do=22, di=dnozzle, dbore=4, hh=35, hrim=10) {
  c=0.2;
  drim=8;
  drim=12.5;
  difference() {
    union() {
      translate([0,0,0])
        linear_extrude(height = hrim)    // rim
          circle(d=drim, $fn = 90);
      translate([0,0,hrim-2])
        linear_extrude(height = 2)    // rim
          circle(d=16, $fn = 90);
      translate([0,0,hrim])
        linear_extrude(height = hh-3)    //  
          circle((di-c)/2, $fn = 90);
      translate([0,0,hrim+hh-3])
        linear_extrude(height = 3, scale=0.9)    //  
          circle((di-c)/2, $fn = 90);
    }
    union() {
      translate([0,0,-1])
        linear_extrude(height = hh+4+hrim)    // bore hole
          circle(d=dbore, $fn = 90);  //center hole
      translate([0,0,hh-10+hrim])
        linear_extrude(height = 10+1, scale=(di-2)/dbore)    // cone
          circle(d=dbore, $fn = 90);  //center hole
      //--- O-Ring Nut ---
      translate([0,0,hh-5])
         rotate_extrude($fn = 80)
           translate([di/2-1.5,0,0]) oshape(w=2.2);
      translate([0,0,hrim-3.5])
         rotate_extrude($fn = 80)
           translate([drim/2-1.2,0,0]) oshape(w=1.9,d=4);
    }
  }
}


module cola_launcher2(do=22, di=dnozzle, dbore=4, hh=35, hrim=10) {
  // Dieses Teil eignet sich auch in Verbindung mit einem r=1 O-Ring,
  // um Fahrraeder mit franzoesischen und deutschen Ventilen aufzupumpen.
  // v1: Mit drim=8 hat ein Autoventilkegel den Anschluss ermoeglicht.
  c=0.2;
  drim=7.6;
  difference() {
    union() {
      translate([0,0,0])
        linear_extrude(height = 0.4)    // increase adhesion surface
          circle(d=14, $fn = 90);
      translate([0,0,0])
        linear_extrude(height = hrim)    // Ventilanschluss
          circle(d=drim, $fn = 90);
      translate([0,0,3])
        linear_extrude(height = 2)       // rim to hook connection
          circle(d=drim+0.5, $fn = 90);
      translate([0,0,hrim])
        linear_extrude(height = hh-3)    //  
          circle((di-c)/2, $fn = 90);
      translate([0,0,hrim+hh-3])
        linear_extrude(height = 3, scale=0.9)    //  
          circle((di-c)/2, $fn = 90);
    }
    union() {
      translate([0,0,-1])
        linear_extrude(height = hh+4+hrim)    // bore hole
          circle(d=dbore, $fn = 90);  //center hole
      translate([0,0,hh-20+hrim])
        linear_extrude(height = 20+1, scale=(di-3)/dbore)    // cone
          circle(d=dbore, $fn = 90);  //center hole
      //--- O-Ring Nut ---
      translate([0,0,hh-20-2+hrim])
         rotate_extrude($fn = 80)
           translate([di/2-1.5,0,0]) oshape(w=2.2);
    }
  }
}




//------------- Instances --------------------

translate([12,0,0]) cola_nozzle2();
//translate([-12,0,0]) cola_launcher2();
//nozzle();
//polygon(fnoz(r1=20,r2=10));
//nozzle2();
