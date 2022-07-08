// Bauteile fuer Segelyacht Galeb, Typ Fountain-Pajot Athena 38
// 
// 
// Background:
//   - galeb_plateE:
//     Lueftungsgitter mit Einsatz fuer novopal NPL-01 Remote control
//     https://www.novopal.com fuer 3000W Sinus-Wechselrichter
//   - see also - a simple case: https://www.thingiverse.com/thing:4544627
//   - see also Hallsensoren_case.scad
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2021-07-02, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <am_dovetail.scad>

// Main dimensions
xin=173.6;     // cut-out width, xin + 2*wrim < 200mm for my printer. 
yin=74;        // cut-out height
zin=3;         // cut-out thickness
wall=1.5;      // wall thickness of printed part
wrim=12.5;     // rim width
rrim=5;        // radius of corners
clr=0.4;       // clearance

//-------------------------------------------
// Werkzeuge, um Fasen mit minkowski() herzustellen (chamfer)
//-------------------------------------------

// cone+cylinder

module ccyl(h1=wall*2/3, h2=wall*1/3, r1=rrim, ang=45) {
    ss=(r1-h2*tan(ang))/r1;
    union() {
      linear_extrude(height=h1, scale=1)  circle(r=r1,$fn=24);
      translate([0,0,h1-0.01])
        linear_extrude(height=h2, scale=ss) circle(r=r1, $fn=24);
    }
}


//-------------------------------------------------------------------------
// plate with inset for remote control and ventilation grid
//-------------------------------------------------------------------------

// simple plate

module galeb_plateA(x=xin, y=yin, z=wall) {
    union() {
	minkowski() {
          translate([0,0,0])
            cube( [x-2*rrim+2*wrim, y-2*rrim+2*wrim, 0.01], center=true);
	  ccyl();
	}
    }
}

// same but with mounting holes

module galeb_plateB() {
    xb=0.5*(183);
    yb=0.5*(82);
    difference() {
        galeb_plateA();
        union() {
           translate([ xb, yb,-1]) ccyl(h1=1+0.3, h2=wall+0.1, r1=1.25, ang=-45);
           translate([-xb, yb,-1]) ccyl(h1=1+0.3, h2=wall+0.1, r1=1.25, ang=-45);
           translate([-xb,-yb,-1]) ccyl(h1=1+0.3, h2=wall+0.1, r1=1.25, ang=-45);
           translate([ xb,-yb,-1]) ccyl(h1=1+0.3, h2=wall+0.1, r1=1.25, ang=-45);
        }
    }
}

// inset part

module galeb_plateC(x=xin, y=yin, z=zin) {
    union() {
      mirror([0,0,1])
	 minkowski() {
           translate([0,0,(z-wall)/2])
             cube( [x-2*rrim-clr, y-2*rrim-clr, z-wall], center=true);
	   ccyl(ang=0);
	 }
    }
}


// slots to be cut

module cslots(xs=44, ys=10, ang=52) {
    d=1.8;
    xshift=-20.5;
    yshift= -1.5;
    NPLshift=0.5;     // so, dass die Schraubenloecher nicht ueberdeckt werden.
    NPLsize=86;       // outer dimension of NPL-01
    union() {
      for(ix = [-1:0 ])  {
      for(iy = [-3:3 ])  {
	translate([ xshift+ix*xs, yshift+iy*ys,  0])
	  rotate([ang, 0, 0])
	    cube([xs-d, ys*cos(ang)-d, 20], center=true);
      }
      }
      translate([(xin-NPLsize)/2+NPLshift,0, 0]) union() {
	// cut for the NPL-01 Remote control, outer dim = 86mm
	cube([52,71,20], center=true);
	//cube([NPLsize,NPLsize,20], center=true);   // debug to see the coverage of the outer contour

	// bore holes
	translate([ 30,  0, 0]) cylinder(d=2.5, h=25, center=true, $fn=24);
	translate([-30,  0, 0]) cylinder(d=2.5, h=25, center=true, $fn=24);
      }
    }
}


// the final part

module galeb_plateD() {
    translate([0,  0, wall]) rotate([0,0,0]) mirror([0,0,1])      // printable only in this orientation.
      difference() {
	union() {
          galeb_plateB();
          galeb_plateC();
	}
	cslots();
      }
}


// the final part with dovetail extension

module galeb_plateE() {
	union() {
          galeb_plateD();
          translate([1,  0, wall+zin]) rotate([90,0,90]) am_dovetailAddN(n=8);
	}
}


// part may be used to lock the plate from behind

module galeb_lockE() {
        d=2;
	difference() {
	  union() {
            translate([0, -12, 0]) cube([10,24, d], center=false);;
            translate([0,  0, d]) rotate([90,0,90]) am_dovetailAddN(n=3);
	  }
	  // thickness of surrounding material is 3.5, but zin is only 3
	  translate([0, 5, d+2-(3.5-zin)]) cube([10,10, 10], center=false);;
        }
}

//-------------------------------------------------------------------------
// electrical cover for M8 12V power supply contacts with 4mm jack  holes
//-------------------------------------------------------------------------

// cover for a M8 screw, inner cavity

module galeb_M8cover_i(
    L=30,   // Length of the screw
    bz=0    // borehole
    ) {
    dm=8.0;   // diameter M8
    dn=14.0;  // diameter Nut
    db=4.0;   // diameter Bananenstecker
    zn=6;     // height of nut
    w=1;      // wall thickness
    c=0.2;    // clearance
    fn=48;    // face number for cylinders, affects rendering time and smoothness
    
    union() {
        // M8 bore hole
	translate([   0,            0, 0 ]) cylinder( d=dm+c,   h=L,    center=false, $fn=fn);
	// 4 mm jack holes
        translate([  (db+dm-c)/2,   0, 0 ]) cylinder( d=db+c,   h=L+bz, center=false, $fn=fn);
	translate([-((db+dm-c)/2),  0, 0 ]) cylinder( d=db+c,   h=L+bz, center=false, $fn=fn);
        translate([  (db+dm-c)/2,   0, L ]) cylinder( d=db+0.8, h=bz,   center=false, $fn=fn);
	translate([-((db+dm-c)/2),  0, L ]) cylinder( d=db+0.8, h=bz,   center=false, $fn=fn);
	// Nut cover
        translate([   0,            0, 0 ]) cylinder( d=dn+c,   h=zn,   center=false, $fn=fn);
        translate([   0,            0, zn]) cylinder( d1=dn+c, d2=dm+c, h=3, center=false, $fn=fn);
    }
}

// cover for a M8 screw, outer hull

module galeb_M8cover_o() {
	minkowski() {
          hull() galeb_M8cover_i();
          ccyl(h1=0.75, h2=0.75, r1=1.0, ang=30);
        }
}

// cover for a M8 screw, final part

module galeb_M8cover() {
  rotate([180, 0, 0])      // better stick to the build plate
  difference() {
    galeb_M8cover_o();
    union() {
      translate([ 0, 0, -0.1]) galeb_M8cover_i(bz=4);
      //cube( [ 40, 40, 40 ] );  // debug: cross-section view
    }
  }
}


//------------- Instances --------------------

//translate([0,-40,0]) ccyl();
//galeb_plateB();
//galeb_plateC();
//cslots();
//galeb_plateD();
//galeb_plateE();
//galeb_lockE();

//galeb_M8cover_i();
//galeb_M8cover_o();
galeb_M8cover();
