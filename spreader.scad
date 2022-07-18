// Spreizer - conical spreader
// 
// Background:
//   - two conical shapes, one being slotted to press against a cylinder
//   - Waschbeckenverschluss
//     hiermit kann im Abfluss der Ueberlauf verschlossen werden, um
//     die unzugaenglichen Hohlraeume im Waschbecken mit 
//     Reinigungsmitteln zu fluten.
//   - hosted on:
//     git@github.com:Github6am/am_parts3D.git
//
// Author: Andreas Merz, 2021-05-01
//   GPLv3 or later, see http://www.gnu.org/licenses 


w  =  1.0;    // wall thickness
dr =  5.0;    // change in radius of cones
c  =  0.15;   // clearance
do = 35.0;    // outer diameter of outer cylinder
h1 = 40.0;    // cylinder height


// conical boundary
module cone_b( dd=do-2*w, hh=h1 ) {
  cylinder( d1=dd, d2=dd-dr, h=hh, $fn=96);
}

module cone_i() {
  difference () {
    translate([0,0,0])   cone_b(dd=do-2*w, hh=h1);
    union() {
      translate([0,0,w]) cone_b(dd=do-4*w, hh=h1+0.1);
      translate([0,0,-0.1]) cylinder( d=do-4*w-10, h=w+0.2, $fn=96);
    }
  }  
}


// one fin
module fin(ri=do/2-dr, ro=do/2, hh=h1, ww=w) {
  translate([ri,-ww/2, 0]) cube([ro-ri-ww/2, ww, hh]);
}

// many fins in a circle
module fins() {
  n=27;
  for(i=[1:n]) {
    phi=(360/n)*(i+0.5);
    rotate([0, 0, phi]) fin();
  }
}


// cylinder with inner fins
module fincyl_o() {
    union() {
      difference () {
	translate([0,0,   0]) cylinder( d=do,     h=h1,     $fn=96);
	translate([0,0,-0.1]) cylinder( d=do-2*w, h=h1+0.2, $fn=96);
      } 
      fins();
      //cone_b(dd=do-2*w, hh=h1);
    }
}

// final part: cut a cone and a gap
module cone_o() {
    rotate([180, 0, 0])
    difference() {
      fincyl_o();
      translate([0,0, -0.01])
	union() {
          cone_b(hh=h1+0.02);
	  fin(ro=do/2+dr, hh=h1+0.02, ww=2.9*w);
	}
    }
}



//------------- Instances --------------------
//fins();

//cone_i();
cone_o();
