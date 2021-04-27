// Wandhalterung fuer Licht-Fernbedienung - wall mount for RC
// Lampenhalterung fuer Deckenlampe
// 
// 
// Background:
//   - immer verlegt man die Fernbedienung. Und wenn es dunkel im Raum
//     ist, dann sollte die Fernbedienung genau an der Wand 
//     neben dem Lichtschalter sein,
//     sonst findet man sie nicht, weil es ja dunkel ist ;-)
//   - Lampenfusshalterung: erlaubt, eine "Glocke" ueber die
//     Kabelanschluesse der Lampe zu schieben, die fest auf
//     dem Konus der Halterung klemmt. 
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-11-08, v0.3 
// GPLv3 or later, see http://www.gnu.org/licenses



// Main dimensions
xin=39.5;      // inner width,  width of RC
yin=15;        // inner width,  thickness of RC
zin=40;        // inner height
wall=1.2;      // wall thickness of printed part
clr=0.4;       // clearance

//-------------------------------------------
// drill
//-------------------------------------------

// cone+cylinder

module ccyl(h1=wall, h2=wall, r1=2, ang=-45, h3=yin+1) {
    ss=(r1-h2*tan(ang))/r1;
    rotate([-90,0,0]) translate([0,0,-0.01])
    union() {
      linear_extrude(height=h1, scale=1)  circle(r=r1,$fn=48);
      translate([0,0,h1])
        linear_extrude(height=h2, scale=ss) circle(r=r1, $fn=48);
      translate([0,0,h1+h2])
        linear_extrude(height=h3, scale=1) circle(r=r1*ss, $fn=48);
    }
}


//-------------------------------------------
// wall storage for remote controls (RC)
//-------------------------------------------
module Wandhalterung_2Dhalf() {
    r=2;             // chamfer inner radius
    w=wall;          // w: wall thickness
    x=xin/2;         // half RC width
    y=yin;           // inner y dimension, RC thickness
    t=(1-tan(45/2));
    // outer contour
    polygon( points=[
       // outer contour
       [0,0], [x+w, 0],
       [x+w, y+2*w-(r+w)*t], [x+w-(r+w)*t, y+2*w], [0, y+2*w],
       // inner contour
       [0, y+w], [x-r*t, y+w], [x, y+w-r*t], [x, 0+2*w], 
       [x-10, 0+2*w], [x-10, 0+2*w], [x-10, 0+w], [0, 0+w]
       ]);

}

module Wandhalterung_2D() {
  union() {
    Wandhalterung_2Dhalf();
    mirror([1,0,0]) 
    Wandhalterung_2Dhalf();
  }
}

module Wandhalterung_3D() {
  union() {
  linear_extrude(height = zin) Wandhalterung_2D();
  }
}

module Wandhalterung_A() {
  x=xin/2;         // half rc width
  difference() {
    union() {
      linear_extrude(height = zin) Wandhalterung_2D();
      linear_extrude(height = wall) hull() Wandhalterung_2D();
    }
    union() {
      translate([-(x-5),0,5+xin*1/2]) ccyl();
      translate([ (x-5),0,5+xin*1/2]) ccyl();
      // cut a hole in the bottom to prevent dirt accumulation
      translate([  0,yin/2+1,0]) cube([xin-10, yin-5, 3*wall], center=true);
    }
  }
}

//-------------------------------------------
// mount for Lightbulb socket connection cover
//-------------------------------------------

module Lampenfusshalterung(
    // Main dimensions
    rin=63.0/2,	   // radius
    hin=12,	   // inner height
    wall=0.8,	   // wall thickness of printed part
    rim=10,	   // rim width to mount
    cone=2.5	   // most covers have a slight conical shape, degrees
    ) {
      difference() {
        rotate([90,0,0])
	  ccyl(r1=rin, h1=2*wall, h2=hin, ang=cone, h3=0);
        union() {
	  translate([0,0,1.5*wall])
          rotate([90,0,0])
	    ccyl(r1=rin-wall, h1=2*wall, h2=hin, ang=cone, h3=0);
	  translate([0,0,-2*wall])
	    cylinder(r=rin-rim, h=8*wall, $fn=48);
	}
      }
}
    
module Lampenfusshalterung_A( 
    rmax=65, 
    hin=12,	   // inner height
    rim=10,	   //  inner mounting rim
    wall=0.8, 
    rin=63.0/2,	   // innerradius
    cone=2.5	   // most covers have a slight conical shape, degrees
    ) {
    bottom=3;      // bottom thickness at mounting rim
    step=(rmax-rin-wall)/3;
    difference() {
      union() {
	rotate_extrude($fn=96)
          // step or sawtooth like contour
	  polygon( points=[
	     // bottom contour
	     [rin-rim,0], [rmax,0],
	     [rmax,2],
	     // top contour
	     [rmax-0*step, 2], [rmax-1*step, 0.8],  // keep thin to avoid warping
	     [rmax-1*step, 4], [rmax-2*step, 1.9], 
	     [rmax-2*step, 6], [rmax-3*step, 3.0], 
	     [rin-rim, 3]
	     ]);
	translate([0,0,3])
          rotate([90,0,0])
	    ccyl(r1=rin, h1=2*wall, h2=hin, ang=cone, h3=0);
        }
	union() {
	  translate([0,0,bottom-0.1])
            rotate([90,0,0])
	      ccyl(r1=rin-wall, h1=2*wall+5-bottom, h2=hin+0.2, ang=cone, h3=0);
      }
    }
}
   

//------------- Instances --------------------
// test
//rotate([90,0,0]) ccyl(r1=20, h1=10, h2=5, ang=30, h3=0);

Wandhalterung_A();
//Lampenfusshalterung();
//Lampenfusshalterung_A();
