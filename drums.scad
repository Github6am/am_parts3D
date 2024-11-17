// Drum rims to fix a drumhead
// 
// Background:
//   - two conical rings to fix a drumhead
//   - material may be paper, plastic foil, or other sheet material
//   - hosted on:
//     git@github.com:Github6am/am_parts3D.git
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Author: Andreas Merz, 2024-11-17
//   GPLv3 or later, see http://www.gnu.org/licenses 

fn  = 96;       // default face number
ww  = 2.0;      // default wall thickness
cs0 = 1/20;     // default cone slope

// inner part shape
module drum_rim_profile_i(
    w  =  ww,     // wall thickness
    h1 = 10.0,    // height
    cs = cs0,     // cone slope
    ) { 
    dr = (h1-1-0.5)*cs;        // radius difference of outer conical shape
    polygon([
    [ 0.4     , 0],
    [ 0     , 1],
    [ 0     , h1],
    [ w     , h1-0.5],  // make top rim a bit slanted
    [ w+dr  , 1],       // avoid outer diameter error when standing on the printer plate
    [ w+dr-0.4  , 0],
    ]);
}

// outer part shape
module drum_rim_profile_o(
    w  =  ww,     // wall thickness of inner part drum_rim_profile_i()
    c  =  0.2,    // clearance
    wo =  3.0,    // wall thickness
    h2 =  8.0,    // height
    cs = cs0,     // cone slope
    ) { 
    dr = h2*cs;   // radius difference of inner conical shape
    union() {
      difference() {
        polygon([
        [ c+w+dr  , 0],
        [ c+w     , h2],
        [ c+w+0.4 , h2+1],  // avoid inner diameter error when standing on the printer plate
        [ w+wo    , h2+1],
        [ w+wo    , 0],
        ]);
        translate([w+wo+0.2 ,h2/3]) circle(d=2.5);         // optional wire groove 
      }
      translate([w+1-0.1 ,2*h2/3]) rotate(45) square(size=1);   // 0.1mm extra ridge to apply local pressure
    }
}


// ------------- Drum rims ---------------------

// inner rim
module drum_rim_i(
    di = 60.0,    // inner diameter of inner cylinder
    ) { 
    rotate_extrude($fn=fn) translate([di/2 ,0,0]) drum_rim_profile_i();
}

// outer rim
module drum_rim_o(
    di = 60.0,    // inner diameter of inner cylinder
    ) { 
    rotate_extrude($fn=fn) translate([di/2 ,0,0]) drum_rim_profile_o();
}

//------------- Instances --------------------

drum_rim_i();
//drum_rim_o();
//mirror([0,0,1]) drum_rim_o();
