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
//
//   - https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
//     clone the following libs to your $HOME/.local/share/OpenSCAD/libraries directory:
//
// Author: Andreas Merz, 2020-06-06
//  GPLv3 or later, see http://www.gnu.org/licenses 

use <scad-utils/transformations.scad>    // https://github.com/openscad/scad-utils
use <list-comprehension-demos/skin.scad> // https://github.com/openscad/list-comprehension-demos

inch=25.4;   // mm
fn=120;      // default face number
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
function G1_thread_profile() = [
    [ 0,0],
    [ 0,0.12],
    [ 1.4,  G1_pitch/2-0.12],
    [ 1.4,  G1_pitch/2+0.12],
    [ 0,    G1_pitch -0.12-0.01],   // avoid render error if overlap after 1 turn
    [ 0,    G1_pitch      -0.01],
    [-0.3,  G1_pitch      -0.01],
    [-0.3,  0]    
];






module G1_thread() {
     c=clr;
     straight_thread(
        section_profile = G1_thread_profile(),
        pitch = G1_pitch,
        turns = 4.25,
        r = (30.25-c)/2,
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

//---------------- Instances ---------------------


// --- test components

//polygon( G1_thread_profile());
//G1_thread();
//adapter_clip();

//pipe_bend();
//pipe_thread_G1();
//pipe_adapter();


// --- target items

//adapterA_G1();
adapterB_G1();
//release_ring();
