// plumbing stuff for garden water or boat bilge pumps
// 
// Background:
//   - currently, there is only the 1" pipe thread (G1)
//   - https://de.wikipedia.org/wiki/Whitworth-Gewinde
//   - https://hackaday.io/page/5252-generating-nice-threads-in-openscad
//   - When rendering thread profiles, this may happen:
//     UI-WARNING: Object may not be a valid 2-manifold and may need repair
//     avoid this by making sure, that the thread generating polygons do 
//     not overlap after one turn of the thread
//   - my printer settings: layer height 0.15mm, infill 33%
//   - https://www.thingiverse.com/thing:4438912
//
//   - https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
//     clone the following libs to your $HOME/.local/share/OpenSCAD/libraries directory:
//
// Author: Andreas Merz, 2020-06-06
//  GPLv3 or later, see http://www.gnu.org/licenses 

use <scad-utils/transformations.scad>    // https://github.com/openscad/scad-utils
use <list-comprehension-demos/skin.scad> // https://github.com/openscad/list-comprehension-demos

inch=25.4;   // mm
fn=360;      // default face number
clr=0.4;     // default clearance
wall=1.0;    // default wall thickness

// -------------- imported code -------------------------------
// Thank you: the following 2 functions are taken from
// https://github.com/MisterHW/IoP-satellite/tree/master/OpenSCAD%20bottle%20threads
//
// radial scaling function for tapered lead-in and lead-out
function lilo_taper(x,N,tapered_fraction) = 
    min( min( 1, (1.0/tapered_fraction)*(x/N) ), (1/tapered_fraction)*(1-x/N) )
;


// helical thread with higbee cut at start and end
// to be attached to a cylindrical surface with matching $fn
module straight_thread(section_profile, pitch = 4, turns = 3, r=10, higbee_arc=45, fn=60)
{
	$fn = fn;
	steps = turns*$fn;
	thing =  [ for (i=[0:steps])
		transform(
			rotation([0, 0, 360*i/$fn - 90])*
			translation([0, r, pitch*i/$fn])*
			rotation([90,0,0])*
			rotation([0,90,0])*
			scaling([0.01+0.99*
			lilo_taper(i/turns,steps/turns,(higbee_arc/360)/turns),1,1]),
			section_profile
			)
		];
	skin(thing);
}


// -------------- my code -------------------------------

G1_pitch = inch/11;             // Steigung 2.309 mm
function G1_thread_profile(mx=1) = [
    [ 0   *mx, 0],
    [ 0   *mx, 0.12],
    [ 1.4 *mx, G1_pitch/2-0.12],
    [ 1.4 *mx, G1_pitch/2+0.12],
    [ 0   *mx, G1_pitch -0.12-0.01],   // avoid render error if overlap after 1 turn
    [ 0   *mx, G1_pitch      -0.01],
    [-0.3 *mx, G1_pitch      -0.01],
    [-0.3 *mx, 0]    
];






module G1_thread(
     di=30.25,     // inner diameter
     c=clr
     ) {
     straight_thread(
        section_profile = G1_thread_profile(),
        pitch = G1_pitch,
        turns = 4.25,
        r = (di-c)/2,
        higbee_arc = 45,
        fn = fn
        );
}

module G1_thread_nut(
     do=33.75,     // outer diameter
     c=clr
     ) {
     rotate([0,0,180])
     straight_thread(
        section_profile = G1_thread_profile(mx=-1),
        pitch = G1_pitch,
        turns = 3.25,
        r = (do+c)/2,
        higbee_arc = 45,
        fn = fn
        );
}

module adapter_clip_profile() { 
    translate([0   ,4,0])
    polygon([
    [-0.5   ,-4.5],
    [-0.5   , 0],
    [ 0.6 , 0],
    [ 1.8 , 1.6],
    [ 2.1 , 2.5],
    [ 2.2 , 3.4],
    [ 2.2 , 0+5.6],   // height of flange
    [ 1.4 , 0+6.0],
    [ 1.4 , 0+7.0],
    [ 3.0 , 12],
    [ 4.0 , 12],
    [ 4.0 , 1]
    ]);
}

// if the connecting hose has a flange, we may snap-in here to fix the adapter
//
module adapter_clip() {
    c=clr;
    difference() { 
      rotate_extrude($fn=fn) translate([(30.25)/2,0,0]) adapter_clip_profile();
      union() {
        translate([+6   ,-20,-1]) cube(40);
        translate([-6-40,-20,-1]) cube(40);
      }
    }
}

// it is hard to remove the snaps without breaking them. 
// The release ring may help to lift the snaps without breaking them
//
module release_ring() {
    w=1.0;     // wall thickness, determined by step height of flange
    di=32-1.0; // tight fit
    slot=20;
    difference() { 
      union() {
	    cylinder(h=10, d=di+2*w  , $fn=fn);
	    cylinder(h=2,  d=di+2*w+3, $fn=fn);
      }
      union() {
	    translate([0, 0,-1]) cylinder(h=12, d=di, $fn=fn);
            translate([0,-slot/2,-1]) cube([20,slot,12]);
      }
    }
}




// adapt to a pipe with an optional flange

module pipe_adapter(
    di=27.2,    // inner diameter of the hose we want to connect to
    do=30.25,   // outer diameter of outgoing pipe
    ha=20,      // height of whole adapter section
    c=clr ) {
    union() {
      translate([0,0,0]) adapter_clip();
      difference() {
        union() {
          cylinder(h=ha,d=di-c, $fn=fn);
          cylinder(h=7,d=di-c/2, $fn=fn);  // tighter fit at pipe rim
          cylinder(h=4,d=do-c  , $fn=fn);
        }
        translate([0,0,-0.01])
        union() {
          cylinder(h=ha+0.02, d=di-c-2*wall, $fn=fn);
          cylinder(h=5, d1=do-c-2*wall, d2=di-c-2*wall, $fn=fn);
        }
      }
    }
}

module pipe_bend(
      do=30.25,
      ang=60,      // hope, we can still print without support structures
      bend=18,
      c=clr ) {
      
      translate([-bend,0,0])
      rotate([90,0,0])
      rotate_extrude(angle=ang,$fn=fn) 
      translate([bend,0,0])
      difference() {
        circle(d=do-c);
        circle(d=do-c-2*wall);
      }
}

module pipe_thread_G1(
    dd=30.25,   // outer diameter of outgoing pipe, core diameter of G1 thread
    hh=14,      // height of whole thread section
    c=clr ) {
      union() {
	G1_thread();
	difference() {
	  union() {
	    cylinder(h=hh, d=dd-c, $fn=fn);
	  }
	  translate([0,0,-0.01])
	  union() {
	    cylinder(h=hh+0.02, d1=dd-c-4*wall, d2=dd-c-2*wall, $fn=fn);
	  }
	}
      }
}


// ------------- Nut modules ---------------------

module pipe_thread_nut_cone(
    d1=33.75,   // inner diameter of outgoing pipe, outer diameter of G1 thread
    d2=27,      // hole diameter
    c=clr ) {
      hh=(d1-d2)/2;   // 45 deg angle
      union() {
	difference() {
	  union() {
	    translate([0,0,wall])    // make cone wall 40% (tan(22.5)) stronger.
	    cylinder(h=hh, d1=d1+c+2*wall, d2=d2+c+2*wall, $fn=fn);
	    cylinder(h=wall, d=d1+c+2*wall, $fn=fn);
	  }
	  union() {
	    translate([0,0,-0.01])
	    cylinder(h=hh+0.02, d1=d1+c, d2=d2+c, $fn=fn);
	    translate([0,0,hh])
	    cylinder(h=hh+wall, d=d2+c, $fn=fn);
	  }
	}
      }
}

module pipe_thread_nut_G1(
    dd=33.75,   // inner diameter of outgoing pipe, outer diameter of G1 thread
    hh=12,      // height of whole thread section
    c=clr ) {
      union() {
	translate([0,0,hh]) pipe_thread_nut_cone(d1=dd);
	G1_thread_nut();
	difference() {
	  union() {
	    cylinder(h=hh, d=dd+c+2*wall, $fn=fn);
	  }
	  translate([0,0,-0.01])
	  union() {
	    cylinder(h=hh+0.02, d=dd+c, $fn=fn);
	  }
	}
      }
}

// adapt to a Bilge Pump, type Blanko WWB06928 12VDC, 13A
// WEEE-Reg.-Nr.: DE76956435
// 3000 GPH

module adapterA_G1(
    di=27.2,    // inner diameter of the hose we want to connect to
    do=30.25,   // outer diameter of outgoing pipe
    hh=13,      // height of whole thread section
    bend=18,
    c=clr ) {
    
    union() {
       pipe_thread_G1(dd=do, hh=hh);  
       translate([0,0,hh]) pipe_adapter();
    }
}

module adapterB_G1(
    di=27.2,    // inner diameter of the hose we want to connect to
    do=30.25,   // outer diameter of outgoing pipe
    hh=14,      // height of whole thread section
    bend=18,    // bend radius
    ang=60,     // higher bend angles may require support structures
    c=clr ) {
    
    union() {
       pipe_thread_G1(dd=do, hh=hh);  
       translate([0,0,hh]) pipe_bend();
       translate([-bend/2,0,hh+bend*sin(60)]) rotate([0,-60,0]) pipe_adapter();
    }
}

// ------------- Plugs ---------------------

// simple cylindrical or conical plug
module plugA(
    w=1.0,       // wall thickness
    b=1.2,       // bottom thickness
    do=25,       // average outer diameter - clearance 
    co=0,        // cone: diameter change from top to bottom
    rr=4,        // additional rim radius
    hh=10,        // height of whole plug
    ) {
    di=do-2*w;   // inner diameter
    difference() { 
      union() {
	    translate([0, 0, 0])    cylinder(h=hh-w, d1=do+co/2,   d2=do-co/2, $fn=fn);
	    translate([0, 0, hh-w]) cylinder(h=w,   d1=do-co/2, d2=do-co/2-w/2, $fn=fn);
            // chamfered cap
	    translate([0, 0, b/2]) cylinder(h=b/2,  d=do+2*rr, $fn=fn);
	    translate([0, 0, 0])   cylinder(h=b/2,  d1=do+2*rr-b, d2=do+2*rr, $fn=fn);
      }
      union() {
	    translate([0, 0,1]) cylinder(h=hh, d1=di+co/2, d2=di-co/2, $fn=fn);
      }
    }
}

// ------------- Adapters ---------------------

// very simple version without chamfer  - under construction
module gardena_fitA(
    c=0.0   // radial clearance
    ) {
    d1=16;
    h1=9.4;
    d2=17;
    h2=3.4;
    d3=14;
    h3=1;
    h4=4;
    union() {
          translate([0, 0, 0])       cylinder(h=w,   d1=d1, d2=d1, $fn=fn);
          translate([0, 0, w])       cylinder(h=h1,  d1=d1, d2=d2, $fn=fn);
          translate([0, 0, w+h1])    cylinder(h=w,   d1=d2, d2=d2, $fn=fn);
          translate([0, 0, 2*w+h1 ]) cylinder(h=hh-h1-2*w,  d1=d3, d2=d4, $fn=fn);
          translate([0, 0, hh-6 ])   cylinder(h=1,  d1=d4, d2=df, $fn=fn);
          translate([0, 0, hh-5 ])   cylinder(h=5,  d1=df, d2=d4, $fn=fn);
    }
}    

// fit hose to a G1 nut
module hose_cone(
    d1=30.25,   // inner diameter of outgoing pipe, outer diameter of G1 thread
    d2=27,      // hole diameter
    d3=17,      // max stub outer diameter, hose inner diameter
    d4=12,      // min stub outer diameter, hose inner diameter
    hh=20,
    w=wall,
    c=clr 
    ) {
      df=d4+3;    // diameter to fit hose tightly, alt: d4*1.15 ?
      h1=(d1-d2)/2;
      difference() {
        union() {
	      translate([0, 0, 0])       cylinder(h=w,   d1=d1, d2=d1, $fn=fn);
	      translate([0, 0, w])       cylinder(h=h1,  d1=d1, d2=d2, $fn=fn);
	      translate([0, 0, w+h1])    cylinder(h=w,   d1=d2, d2=d2, $fn=fn);
	      translate([0, 0, 2*w+h1 ]) cylinder(h=hh-h1-2*w,  d1=d3, d2=d4, $fn=fn);
	      translate([0, 0, hh-6 ])   cylinder(h=1,  d1=d4, d2=df, $fn=fn);
	      translate([0, 0, hh-5 ])   cylinder(h=5,  d1=df, d2=d4, $fn=fn);
        }
        union() {
	      translate([0, 0, -0.1])      cylinder(h=h1+1.4*w,  d1=d1-2*w, d2=d3-3*w, $fn=fn);
	      translate([0, 0, h1-0.1])  cylinder(h=hh-h1+1, d1=d3-2*w, d2=d4-w, $fn=fn);
        }
      }
}

// fit gardena to a G1 nut
module gardena_cone(
    d1=30.25,   // inner diameter of outgoing pipe, outer diameter of G1 thread
    d2=27,      // hole diameter
    d3=17,      // max stub outer diameter, hose inner diameter
    d4=12,      // min stub outer diameter, hose inner diameter
    hh=20,
    w=wall,
    c=clr 
    ) {
      df=d4+3;    // diameter to fit hose tightly, alt: d4*1.15 ?
      h1=(d1-d2)/2;
      difference() {
        union() {
	      translate([0, 0, 0])       cylinder(h=w,   d1=d1, d2=d1, $fn=fn);
	      translate([0, 0, w])       cylinder(h=h1,  d1=d1, d2=d2, $fn=fn);
	      translate([0, 0, w+h1])    cylinder(h=w,   d1=d2, d2=d2, $fn=fn);
	      translate([0, 0, 2*w+h1 ]) cylinder(h=hh-h1-2*w,  d1=d3, d2=d4, $fn=fn);
        }
        union() {
	      translate([0, 0, -0.1])      cylinder(h=h1+1.4*w,  d1=d1-2*w, d2=d3-3*w, $fn=fn);
	      translate([0, 0, h1-0.1])  cylinder(h=hh-h1+1, d1=d3-2*w, d2=d4-w, $fn=fn);
	      //translate([0, 0, hh-6 ])   cylinder(h=1,  d1=d4, d2=df, $fn=fn);
	      //translate([0, 0, hh-5 ])   cylinder(h=5,  d1=df, d2=d4, $fn=fn);
        }
      }
}

// ------------- Pump ---------------------

// hose pump, does not work very well; valve() works much better. 
// Attach floating material around the waist.

module pumpA(
    w=1.6,       // wall thickness
    b=1.2,       // bottom thickness
    do=25,       // outer diameter
    rr=4,        // additional rim radius
    hh=30,       // height of cylindrical section
    sm=2.4,      // slot margin
    dit=30,      // inner diameter at top
    dot=32,       // outer diameter at top
    c=0.2        // clearance, reduces clearance at bottom 
    ) {
    di=do-2*w;   // inner diameter
    sw=di/3;       // slot width
    sh=hh/2-2*sm;  // slot height
    difference() { 
      union() {
	translate([0, 0,  0])    cylinder(h=rr, d1=do+2*rr, d2=do+2*c,      $fn=fn);
	translate([0, 0, rr])    cylinder(h=sm, d1=do+2*c,  d2=do,      $fn=fn);
	translate([0, 0, rr])    cylinder(h=hh, d1=do,      d2=do,      $fn=fn);
	translate([0, 0, hh])    cylinder(h=rr, d1=do,      d2=do+2*rr, $fn=fn);
	translate([0, 0, hh+rr]) cylinder(h=rr, d1=do+2*rr, d2=dot,     $fn=fn);
      }
      union() {
	translate([0, 0,b]) cylinder(h=hh+2*rr, d=di,        $fn=fn);
	translate([0, 0, hh+rr]) cylinder(h=rr+0.01, d1=di,    d2=dit,     $fn=fn);
        // slots
        for (i = [0 : 2]) {
          rotate( [0, 0, i*120] ) translate([ 0, 0, sh/2+rr+sm]) cube([do+2, sw, sh], center=true); 
        }
      }
    }
}

module pumpB(
    w=1.6,       // wall thickness of cylindrical section
    dd=25,       // design diameter
    rr=4,        // additional rim radius
    hh=15,       // height of cylindrical section
    c=0.6        // clearance
    ) {
    di=dd+2*c;      // inner diameter
    do=dd+2*c+2*w;  // outer diameter
    rf=2*rr;        // radius of funnel
    e=0.1;          // 
    difference() {
      union() {
	translate([0, 0,  0])    cylinder(h=rf, d1=do+2*rf, d2=do,      $fn=fn);
	translate([0, 0, rf])    cylinder(h=hh, d1=do,      d2=do,      $fn=fn);
	translate([0, 0, rf+hh]) cylinder(h=2*rf, d1=do,      d2=do+4*rf, $fn=fn);
      }
      union() {
	translate([0, 0, -e])    cylinder(h=rf+e,   d1=di+2*rf, d2=di,      $fn=fn);
	translate([0, 0, rf-e])  cylinder(h=hh+2*e, d1=di,      d2=di,      $fn=fn);
	translate([0, 0, rf+hh]) cylinder(h=2*rf+e,   d1=di,      d2=di+4*rf, $fn=fn);
      }
    }
}

// print entangled parts  - needs redesign, prototype does not function as intended :-(
module pumpC(
    w=1.6,       // wall thickness of cylindrical section
    dd=25,       // design diameter
    rr=4,        // additional rim radius
    hh=30,       // height of cylindrical section
    debug=0
    ) {
    difference() {
      union() {
        pumpA(w=w, do=dd, rr=rr, hh=hh, dit=30.25-4*wall-clr, dot=30.25-clr);
        pumpB(w=w, dd=dd, rr=rr, hh=hh/2);
        translate([0, 0, hh+2*rr]) pipe_thread_G1();  
      }
      if(debug)
        rotate([0,0,-90]) translate([0, 0, -1]) cube([ 2*dd, 2*dd, 2*hh], center=false);  // debug: cross-section
    }
}

// ------------- Valve ---------------------

// valve plug, overall length: hh+3*rr

module valve_plug(
    dd=16,       // design diameter
    hh=20,       // height of cylindrical section
    rr=4,        // rim radius
    c=0.4        // clearance
    ) {
    do=dd+2*c;     // outer diameter
      union() {
	translate([0, 0,  0])   cylinder(h=2*rr, d1=do-2*rr, d2=do,      $fn=fn);
	translate([0, 0, 2*rr])   cylinder(h=hh, d1=do, d2=do,     $fn=fn); 
	translate([0, 0, 2*rr+hh])   cylinder(h=rr, d1=do, d2=do-rr,     $fn=fn); 
      }
}


module valve(
    w=1.6,         // wall thickness
    b=3,           // bottom thickness
    do=30.25-clr,  // outer diameter
    rr=4,          // rim radius
    hh=32,         // height of cylindrical section
    hv=25,         // height of valve mechanism
    mm=9,          // movement of plug
    debug=0
    ) {
    di=do-2*w;   // inner diameter
    dp=2/3*di;   // plug diameter
    difference() {
      union() {
        difference() {
          union() {
            difference() {
              // outer contour
              union() {
	        translate([0, 0,  0])   cylinder(h=hh, d1=do, d2=do,      $fn=fn);
              }
              // cavity
              union() {
	        translate([0, 0, b]) cylinder(h=hh+2*rr, d=di,        $fn=fn);
              if(debug==1)
                rotate([0,0,180]) translate([-do, 0, -1]) cube([ 2*do, 2*do, 2*hh], center=false);  // debug: cross-section
              }
            }

            // guidance ridges
            for (i = [0 : 4]) {
              rotate( [0, 0, i*72] ) translate([ di/4, 0, hv/2]) cube([di/2, w, hv], center=true); 
            }
          }

          // cut cavity for plug
          union() {
            translate([0, 0, -rr]) valve_plug(dd=dp, c=0.6, hh=hv-4*rr+mm);
	    translate([0, 0, b])   cylinder(h=rr, d=dp+2*0.6,      $fn=fn);
          }
        }

      // print the valve plug inside the structure
      valve_plug(dd=dp, c=0.0, hh=hv-3*rr-1);

      // add threads at top and bottom
      translate([0, 0, hh-14]) G1_thread();  
      translate([0, 0, 0])       G1_thread();  
      //translate([0, 0, 40])      pipe_thread_G1();  
     }
     if(debug==2)
       rotate([0,0,180]) translate([-do, 0, -1]) cube([ 2*do, 2*do, 2*hh], center=false);  // debug: cross-section
   }
}



//---------------- Instances ---------------------


// --- test components

//polygon(  G1_thread_profile());
//G1_thread();
//G1_thread_nut();
//adapter_clip();

//pipe_bend();
//pipe_thread_G1();
//pipe_adapter();

// view cross-section
//difference(){
//pipe_thread_nut_G1();
//hose_cone();
//cube([20,20,20], center=false); }


// --- target items

//adapterA_G1();
//adapterB_G1();
//release_ring();

//plugA();
//plugA(do=23.2, rr=6.4);
plugA(do=85.0, rr=4, w=1.8, co=0.8);

//pumpC(debug=1);     // Fehlkonstruktion :-(

//valve();

//pipe_thread_nut_G1();
//hose_cone();

// --- under construction
//gardena_cone();   //  derived from hose_cone();
//gardena_fitA();   // 
