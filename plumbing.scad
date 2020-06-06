// plumbing stuff for garden water
// 
// Background:
//   - https://de.wikipedia.org/wiki/Whitworth-Gewinde
//   - https://hackaday.io/page/5252-generating-nice-threads-in-openscad
//   - When rendering, this may happen:
//     UI-WARNING: Object may not be a valid 2-manifold and may need repair
//     avoid this by making sure, that the thread generating polygons do 
//     not overlap after one turn of the thread
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

// demo: straight_thread(section_profile=demo_thread_profile());
function demo_thread_profile() = [
    [0,0],
    [1.5,1],
    [1.5,1.5],
    [0,3],
    [-1,3],
    [-1,0]    
];

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





// PCO-1881 soda bottle neck thread
// function bottle_pco1881_neck_clear_dia()      = 21.74;
// function bottle_pco1881_neck_thread_dia()     = 24.94;
// function bottle_pco1881_neck_thread_pitch()   = 2.7;
// function bottle_pco1881_neck_thread_height()  = 1.15;
// function bottle_pco1881_neck_thread_profile() = [
//     [0,0],
//     [0,1.42],
//     [bottle_pco1881_neck_thread_height(),1.22],
// 	[bottle_pco1881_neck_thread_height(),0.22] 
// ];




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
    [ 0   ,-4],
    [ 0   , 0],
    [ 0.6 , 0],
    [ 2   , 2],
    [ 2   , 0+5.6],
    [ 1.2 , 0+6.0],
    [ 3.0 , 12],
    [ 4.0 , 12],
    [ 4.0 , 1]
    ]);
}

module adapter_clip() {
    c=clr;
    difference() { 
      rotate_extrude($fn=fn) translate([(30.25-c-0.01)/2,0,0]) adapter_clip_profile();
      union() {
        translate([+6   ,-20,-1]) cube(40);
        translate([-6-40,-20,-1]) cube(40);
      }
    }
}



// adapt to a Bilge Pump, type Blanko WWB06928 12VDC, 13A
// WEEE-Reg.-Nr.: DE76956435
// 3000 GPH
module adapter_hose() {
    c=clr;
    difference() {
      translate([0,0,0])
      union() {
	G1_thread();
	translate([0,0,13]) adapter_clip();
	difference() {
	  union() {
	    cylinder(h=35,d=27-c, $fn=fn);
	    cylinder(h=21,d=27-c/2, $fn=fn);
	    cylinder(h=17,d=30.25-c, $fn=fn);
	  }
	  translate([0,0,-0.5])
	  union() {
	    cylinder(h=36, d=27-c-2*wall, $fn=fn);
	    cylinder(h=17, d1=27, d2=27-c-2*wall, $fn=fn);
	  }
	}
      }
      //translate([0,0,-1.1]) cylinder(h=1.1, d=35, $fn=fn);
    }
}

module test_render() {
  union() {
    G1_thread();
    //cylinder(h=35,d=27, $fn=fn);
    cylinder(h=14,d=20, $fn=fn);
  }
}

//test_render();
adapter_hose();
//G1_thread();

//polygon( G1_thread_profile());

//adapter_clip();
