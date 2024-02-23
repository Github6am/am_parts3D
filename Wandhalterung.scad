// Wandhalterung fuer Licht-Fernbedienung - wall mount for RC
// Lampenhalterung fuer Deckenlampe und Stehlampe
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
//   - Abdeckkappe fuer eine Verteilerdose, die zu nahe an der Wand ist.
//   - Sicherungshalter fuer einen Detleffs-Wohnwagen
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-11-08, v0.4 
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


// zwei Verkleidungen fuer die Lampensockel der Wohnzimmerlampe

// erstere sollte ohne infill gedruckt werden, da die Waende so duenn sind.
module Lampenfusshalterung_B( 
    dd=42,   // inner diameter
    hh=42,   // height
    dx=0,    // excess,  for conical shape
    w=0.8    // wall thickness
    ) {
	difference() {
            cylinder(d1=dd+2*w, d2=dd+dx+2*w, h=hh,     $fn=180);
	  union() {
            translate([0,0,  w  ]) cylinder(d1=dd,     d2=dd+dx,   h=hh+0.2, $fn=180);
            translate([0,0, -0.1  ]) cylinder(d1=dd-2, d2=dd-2,    h=w +0.2, $fn=180);
	  }
	}
}

module Lampenfusshalterung_C( 
    dd0=28.4,  // inner diameter
    dd1=36,    // inner diameter of cone at beginning
    dd3=42,    // inner diameter of cone at end
    hh1=16,    // height
    hh3=36,    // height
    w=0.8      // wall thickness
    ) {
	dx=hh1/hh3*(dd3-dd1);
	difference() {
            cylinder(d1=dd1+2*w, d2=dd3+2*w, h=hh3,     $fn=180);
	  union() {
            translate([0,0,  hh1  ]) cylinder(d1=dd1+dx,  d2=dd3,   h=hh3+0.2-hh1, $fn=180);
            translate([0,0, -0.1  ]) cylinder(d1=dd0,     d2=dd0,   h=hh1+0.2,     $fn=180);
	  }
	}
}

//-------------------------------------------
// Abdeckkappe fuer elektrische Verteilerdose
//-------------------------------------------

module cut_circle_2D(
    r0=50,   // outer radius of circle
    r1=43,   // cut away, if r1<r0
    ) {
    difference() {
      circle(r=r0, $fn=180); 
      translate([r1,-r0,0]) square(2*r0);
    }
}

// TODO: Fase oder Aussenwand des Kreises kegelig machen?  
module distribution_box_cover(
    r0=45,   // outer radius of cover
    r1=18,   // cut away, if r1<r0
    di=9,    // inner diameter of inner rim
    hi=7,    // height of inner rim
    ho=4,    // height of outer rim
    w=1.6    // wall thickness
    ) {
    difference() {
      union() {
        // bottom and outer rim
        difference() {
          translate([0,0,0]) linear_extrude(height=ho) cut_circle_2D( r0=r0,   r1=r1);
          translate([0,0,w]) linear_extrude(height=ho) cut_circle_2D( r0=r0-w, r1=r1-w);
        }
        // inner rim
        difference() {
          translate([0,0,   0])   linear_extrude(height=w+hi) cut_circle_2D( r0=di/2+w, r1=r0);
          // set 1mm lower at inner for a tight fit at the outer rim
          translate([0,0,w+ho-1]) linear_extrude(height=hi  ) cut_circle_2D( r0=di/2,   r1=r0-w);
        }
      }
      // center bore hole for countersunk Spax screw
      translate([0,0,20]) rotate([-90,0,0])  ccyl(r1=2, h1=16, h2=4, ang=-30, h3=1);
    }
}
 

//-------------------------------------------
// Unterputzdose fuer Steckdosen
//-------------------------------------------

// Dose ohne Boden

module updoseA(
    da=69,   // standard wall bore hole diameter:68
    db=62,   // outer diameter
    dc=60,   // inner diameter
    dd=71,   // Dosendistanz bei Doppeldosen, typ: 71
    zz=32,   // height
    ww=1.2,  // wall thickness
    nn=4     // number of fin pairs
    ) {
    difference() {
      linear_extrude(height=zz)
      union() { 
        circle(r=db/2, $fn=180);
        for (i = [0 : nn-1]) {
	  rotate([0, 0, 360.01/nn*i +8]) translate([(db+dc)/4,-ww/2]) square( [da/2 -(db+dc)/4, ww]);
	  rotate([0, 0, 360.01/nn*i -8]) translate([(db+dc)/4,-ww/2]) square( [da/2 -(db+dc)/4, ww]);
        }
        if(dd > da) {
          xsq=(dd-da)/2;
          ysq=10.78;      // Augenschein, nicht gerechnet.
          translate([dd/2-xsq-0.6, -ysq/2]) square( [xsq+0.6, ysq]);
        }
      }
      // Innenraum
      translate([0,0,-1]) cylinder(d=dc, h=zz+2, $fn=180); 
    }
}

//----------------------------------------------------
// Sicherungshalter fuer Wohnwagen-Stromanschluss
//----------------------------------------------------
module fuseplugA(
    d1=7.7,   // inner diameter, cut M8 screw
    d2=12,   // outer diameter
    h1=25,   // outer height
    fn=12    // outer face number
    ) {
    dnut=d2/cos(180/fn);
    difference() {
      cylinder(d=dnut, h=h1, $fn=fn);
      translate([0,0,-0.01])
      union() {
         cylinder(d=5,  h=h1-3, $fn=24);
         cylinder(d=6,  h=8,    $fn=24);
         cylinder(d=d1, h=5,    $fn=24);
         // slot for Screwdriver
         translate([0,0, h1+2-1.6]) cube([2,2*d2,4], center=true);  
      }  
    }
}

//------------- Instances --------------------
// test
//rotate([90,0,0]) ccyl(r1=20, h1=10, h2=5, ang=30, h3=0);


//Wandhalterung_A();
//Lampenfusshalterung();
//Lampenfusshalterung_A();
//Lampenfusshalterung_B();
//Lampenfusshalterung_C();
//distribution_box_cover();

//updoseA();
fuseplugA();
