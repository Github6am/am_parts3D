// Bauteile fuer Segelyacht Galeb, Typ Fountain-Pajot Athena 38
// 
// 
// Background:
//   - galeb_plateE:
//     Lueftungsgitter mit Einsatz fuer novopal NPL-01 Remote control
//     https://www.novopal.com fuer 3000W Sinus-Wechselrichter
//   - see also - a simple case: https://www.thingiverse.com/thing:4544627
//   - see also Hallsensoren_case.scad
//   - galeb_M8cover:
//     cover to be printed in red(+) and black(-) covering M8 
//     high-current battery connections.
//   - galeb_fan_adapter, galeb_fan_inlet:
//     snap them on a Jabsco axial blower to adapt to a 70mm hose.
//   - galeb_rod_polisher:
//     intended to clean and polish stainless steel rods, print 4 instances.
//   - galeb_vcase: 
//     housing for three 4-digit COM-VM433 Voltmeter modules, Joy-It, EAN: 4250236817873 
//     https://www.pollin.de/p/joy-it-digital-voltmeter-4-digit-einbauinstrument-830840
//     intended to be plugged onto the battery power switch control panel.
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


// sequence of n conical sections
module conesN(n=3, hh=[0, 1, 8, 10], dd=[5.5, 5.8, 6.2, 5.0], fn=30) {
    for (i = [0 : n-1]) {
      translate([0,0, hh[i] -i*0.005])
        cylinder(d1=dd[i], d2=dd[i+1], h = hh[i+1]-hh[i], $fn=fn);
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
// electrical cover for M8 12V power supply contacts with 4mm jack holes
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

//-----------------------------------------------------------------------------------
// adapter for a Jabsco 3'' in-line blower (Model 30480-0000, 12V 2.9A) to 70mm hose
//-----------------------------------------------------------------------------------
// see also hose_branch.scad and pipe_adapter() in plumbing.scad

// Nennmasse: 
//   Schlauchinnendurchmesser  -> do1
//   Geblaeseaussendurchmesser -> di4, ..

module galeb_fan_adapter(
    do1=70,  // outer diameter bottom
    di2=72,  // inner diameter at fan outlet
    di3=76,
    di4=77,
    di5=75.6,
    di6=78,
    h0=5,    // length of section 0, covered by hose
    h1=40,   // length of section 1, partly covered by hose
    h2=0,    // length of section 2  
    h3=9.7,  // length of section 3  
    h6=1.5,  // length of the 4 teeth
    rr=10,   // ridge
    w=1.5    // wall thickness
    ) {
    c=0.4;    // clearance
    e=0.01;   // epsilon
    ss=0.6;   // snap slope
    ww=2*w;   // double wall thickness
    sw=8;     // slot width
    fn=96;    // face number for cylinders, affects rendering time and smoothness

    union() {
      difference() {   
        // outer contour
        union() {
	    translate([ 0, 0, 0        ]) cylinder( d1=do1-2,     d2=do1-0,     h=h0,     center=false, $fn=fn);
	    translate([ 0, 0, 0        ]) cylinder( d1=do1-2,     d2=di2+ww+c,  h=h1,     center=false, $fn=fn);
	    translate([ 0, 0, h1-4     ]) cylinder( d1=di2+w+c,   d2=di3+ww+c,  h=h2+4-w, center=false, $fn=fn);
	    translate([ 0, 0, h1+h2-w  ]) cylinder( d1=di3+ww+c,  d2=di4+ww+c,  h=h3+w,   center=false, $fn=fn);
	    translate([ 0, 0, h1+h2+h3 ]) cylinder( d1=di4+ww+c,  d2=di4+ww+c,  h=2.6,    center=false, $fn=fn);
        }
        // inner contour
        union() {
            //cube([80,80,80],center=false);   // debug cross-section
	    translate([ 0, 0, -e/2         ]) cylinder( d1=do1-2-ww,  d2=di2+c,   h=h1+e,     center=false, $fn=fn);
	    translate([ 0, 0, h1           ]) cylinder( d1=di2+c,     d2=di3+c,   h=h2+e,     center=false, $fn=fn);
	    translate([ 0, 0, h1+h2        ]) cylinder( d1=di3+c,     d2=di4+c,   h=h3+e,     center=false, $fn=fn);
	    translate([ 0, 0, h1+h2+h3     ]) cylinder( d1=di4+c,     d2=di5+c,   h=ss+e,     center=false, $fn=fn);
	    translate([ 0, 0, h1+h2+h3+ss  ]) cylinder( d1=di5+c,     d2=di4+c,   h=2.6-ss+e, center=false, $fn=fn);

            // 8 slots
            // rotate([0,0,  0]) translate([ 0, 0, h1+h2+w+20/2  ]) cube([di4+10, 6, 20], center=true);
            // rotate([0,0, 90]) translate([ 0, 0, h1+h2+w+20/2  ]) cube([di4+10, 6, 20], center=true);
            // rotate([0,0, 45]) translate([ 0, 0, h1+h2+w+20/2  ]) cube([di4+10, 6, 20], center=true);
            // rotate([0,0,135]) translate([ 0, 0, h1+h2+w+20/2  ]) cube([di4+10, 6, 20], center=true);
            for (i = [0 : 3]) {
              rotate([0,0, i*45]) translate([ -(di4+4)/2 , 0, h1+h2+w+20/2  ]) 
                rotate([0, 90, 0]) linear_extrude(height=di4+2*ww) 
                  offset(r = 1, chamfer=false, $fn=24) square([20-2,sw-2], center = true);
            }
        }
      }
      
      // add 3 ridges inside
      for (i = [0 : 2]) {
        rotate( [90, 0, i*120] ) translate([ 0, 0, -w/2  ]) linear_extrude(height=w) 
          polygon( points=[ [(do1-2-ww-rr)/2, 0], [(do1-2-ww)/2, 0],
                            [(di2+c)/2,h1],       [(do1-ww-rr)/2, h1-10] ]);
      }
   }   
}


// a protective grid cover for the inlet

module galeb_fan_inlet(
    di0=90    // inlet diameter
    ) {
    q=1.5;   // wall thickness of grid
    union() {
      galeb_fan_adapter(do1=di0, h0=0, h1=10, rr=16);

      // ring grid
      rotate_extrude($fn=96)
        union() { 
          translate([ di0/2-10, 0, 0]) square([q, 2*q], center = false);
          translate([ di0/2-20, 0, 0]) square([q, 2*q], center = false);
          translate([ di0/2-30, 0, 0]) square([q, 2*q], center = false);
        }

      // radial grid
      for (i = [0 : 2]) {
        rotate( [0, 0, i*120] ) translate([ di0/2-30, -q/2, 0]) cube([20, q, 2*q], center=false); 
      }
    }    
}


//-----------------------------------------------------------------------------------
// tool for cleaning or polishing stainless steel rods
//-----------------------------------------------------------------------------------

module galeb_rod_polisher_contour1(L=50, w=4) {
          e=0.4;
          polygon( points=[ [5,   0], [15,  0],
                            [15,  1], [7+w, 5 ],
                            [5+w, 9], [5+w, L],
                            [5,   L], [5,   6.5], [4.5, 6],
                            [0,   9], [e,   8],
                            [5,   4], [5.7, 2.4], [5, 2],
                            [0,   6], [e,   5]
                            ] );
}

// Punktsymmetrische Kontur die als Schnappverbinder gedacht ist
module galeb_rod_connector_contour2(
     L=10,    // length of overlap
     w=4,     // wall thickness
     c=0.4,   // clearance
     outer=0  // mirror contour
     ) {
     s=0.4;    // slope at interlocking point
     l=0.8;      // lock length
          rotate([180,180*outer])
          translate([-(w)/2, -L])
          polygon( points=[ [0,   0], [0+(w-c)/4,  0], [0+(w+l-c)/2,  L/4],
                            [0+(w+l-c)/2,  (L-c)/2-s], [0+(w-l-c)/2, (L-c)/2],
                            [0+(w-l-c)/2,  L], [0, L]
                            ] );
}

module galeb_rod_connector( d=27, L=10, w=4, circ=1) {
     n=3;
     c=0.5;
     debug=0;
     union() {
       // inner teeth
       for (i = [0 : (2*n-1)*circ]) {
         rotate( [0, 0, (i)*180/n +0.5] )  // add 2*0.5 degree gap
           rotate_extrude(angle=90/n -1, $fn=96) translate([ d/2+c, 0, 0 ]) 
             galeb_rod_connector_contour2(L=L, w=w, c=c);
       }
       // outer teeth
         for (i = [0 : (2*n-1)*circ]) {
           rotate( [0, 0, (i+0.5)*180/n +0.5] )
             rotate_extrude(angle=90/n -1, $fn=96) translate([ d/2+c, 0, 0 ]) 
               galeb_rod_connector_contour2(L=L, w=w, c=c, outer=1);
         }
       // debugging: add ring, small printout part to test the interlocking
       if(debug)
         difference() { 
           translate([0, 0,  0  -3]) cylinder(d=d+w, h=3, center=false, $fn=192); 
           translate([0, 0, -0.1-3]) cylinder(d=d-w, h=3.2, center=false, $fn=192);
         }

     }        
}


module galeb_rod_polisher1(d=27, L=100, w=4) {
        r0= d/2;
        r1= r0 +15;
        r2= r0 +5;
        
        // outer case
        rotate([0,0,0 ])
          rotate_extrude(angle=180+10,$fn=96) translate([ d/2, 0, 0 ]) 
            galeb_rod_polisher_contour1();
        
        // spiral inlay in 
        difference() {
          translate([ 0, 0, 10])  
            linear_extrude(height=L/2-10, twist=90,$fn=96) 
               for (i = [0 : 1]) {
                  rotate([0,0,(i+1)*90 ]) translate([ d/2, 0, 0])
                     rotate([0,0,-45 ]) square([7,1.6], center=false);
               }
             translate([ 0, -d, 0])
               cube([4*d,2*d,2*L], center=true);   // cut away one half
        }
}

module galeb_rod_polisher(d=27, L=100) {
     w=4;    // wall thickness
     c=0.45; // clearance
     p=w/3;  // with of ridge connecting two halves
     q=(w-p-c)/2;
     difference() {
       union() {
         galeb_rod_polisher1(d=d, L=L, w=w);
         translate([ 0, 0, L/2 ]) 
           galeb_rod_connector(d=d+5+2*w, w=w, circ=0.5);
       }  
       // cut such, that two halves can be attached to each other to surround a rod
       union() {
         // groove
         rotate([0,0,-10 ])
           rotate_extrude(angle=20,$fn=96) translate([ d/2+5+(w-p-c)/2, 0, 0 ]) 
              union() {
                square([p+c,   L/2+c]);
                translate([ (p+c)/2, 0, 0 ]) square([p+3*c, 2*c], center=true);
              }
         
         // ridge
         rotate([0,0,180 ])
           difference() {
             rotate_extrude(angle= 20,$fn=96) translate([ d/4, 0, -0.1 ]) 
                square([d, L]);
             rotate_extrude(angle= 30,$fn=96) translate([ d/2+5+(w-p)/2, 0, 0 ]) 
                  square([p, L]);
         }
         
         // screwdriver slot to simplify reopening
         translate([ -(d/2+w+5+1.8-p-0.4), -0.01, L/4 ]) cube([1.8,2,8]);
         //translate([ +(d/2+w/2+5), 0, 0]) cube([2,8,2], center=true);
       }
     }
}

       
//-----------------------------------------------------------------------------------
// housing for 3 Voltmeter Displays, Type COM-VM433, available via Pollin electronics
//-----------------------------------------------------------------------------------

// Zapfen, der in ein 6mm Bohrloch passt
module peg(h0=0, diameter=6, length=8) {
  c=0.3;
  d1=diameter-c;
  d2=diameter+c;
  d0=1;
  difference() {
    conesN(n=4, hh=[-h0, 0, 1, length-1.5, length], dd=[d0, diameter-2*c, d1, d2, diameter-0.5], fn=10);
    // cut a slot
    translate([0,0,1+length/2]) cube([2*diameter, 1.0, length], center=true);
  }
}

module vcase_quarter(lx=150, ly=34, lz=25,    // box outer dimensions
    w=2.4   // wall thickness
)
{
    rd=0.8;   // ridge depth
    rw=1.4;   // ridge width
    ix=45.6;  // instrument size x, plus clearance
    iy=26.8;  // instrument size y, plus clearance
    // We print bottom walls separately to avoid warping and allow test access.
    difference() {
      // a quarter of the whole box
      union() {
        translate([0,0,0])       cube([lx/2, ly/2, w], center=false);   // front panel
        translate([lx/2-w, 0,0]) cube([w, ly/2, lz],   center=false);   // side
        // add warping protection
        translate([lx/2, ly/2,0]) cylinder(d=12, h=0.4,   center=false);   // side
      }
      union() {
        // cut ridge to insert bottom wall
        translate([-w+rd, ly/2-rd-rw,w-rw]) cube([lx/2, rw, lz], center=false);
        // instrument cut-outs
        translate([ -ix/2, -iy/2,-0.01])       cube([ix, iy, 2*w], center=false);
        translate([  -ix/2+ ix + 4, -iy/2,-0.01])       cube([ix, iy, 2*w], center=false);
      }
    }
}

module vcase_half(lx=150, ly=34, lz=25,    // box outer dimensions
    w=2.4   // wall thickness
)
{
    union() {
      mirror([0,0,0]) vcase_quarter(lx=lx, ly=ly, lz=lz, w=w);
      mirror([0,1,0]) vcase_quarter(lx=lx, ly=ly, lz=lz, w=w);
      translate([lx/2-w/2, 0,lz ]) peg(h0=6);
    }
}


// the final triple voltmeter case
module vcase(lx=150, ly=34, lz=25,    // box outer dimensions
    w=2.4   // wall thickness
)
{
    union() {
      mirror([0,0,0]) vcase_half(lx=lx, ly=ly, lz=lz, w=w);
      mirror([1,0,0]) vcase_half(lx=lx, ly=ly, lz=lz, w=w);
    }
}

// top and bottom wall sheet as separate inset
module vcase_bottom( lx=150, ly=34, lz=25,    // box outer dimensions
    w=2.4   // wall thickness of vcase
)
{
    rw=0.8;   // fit to vcase ridge width including clearance
    rd=0.4;   // fit to vcase ridge depth including clearance
    union() {
        cube([lx-2*w+2*rd, lz-w+rd, rw],   center=true);
    }
}

//-------------------------------------------------------------------------
// SUP pump adapter for Capelli Dinghy
//-------------------------------------------------------------------------

module adapter_sup2dinghy( 
    dii=21.5,   // inlet inner diameter
    c=0.3,    // clearance
    ) {
    dq=6-c;   // Querstange diameter
    hq=10-0.1;// Querstange offset from inlet rim
    h1=20;    // SUP inlet height
    h2=4;     // center part height
    h3=16;    // cone  height
    d2=22;    // dinghy cone max diameter
    d3=20;    // dinghy cone min diameter
    ff=1;     // chamfer (de: Fase)
    w=3;      // wall thickness
    u=h2/3;   // dirty: Knickpunkt nach oben oder unten verschieben, dass Wandstaerke ~konstant
    union() {
      difference() {
        conesN(n=4, hh=[0,          ff,      h1+u,  h1+h2,     h1+h2+h3 ], 
                    dd=[dii+2*w-ff, dii+2*w, dii+2*w, 22,        20], fn=96);
        conesN(n=4, hh=[-0.01,          ff,   h1,      h1+h2-u,  h1+h2+h3+0.1  ], 
                    dd=[dii+1.4*ff,     dii+c,   dii+c,   22-2*w,    20-1.5*w,     ], fn=96);
      }
      translate([0,(dii+w)/2, hq]) rotate([90,0,0]) cylinder(d=dq, h=dii+w, $fn=48);
    }
}


//------------- Instances --------------------

//translate([0,-40,0]) ccyl();
//conesN();
//peg();


//galeb_plateB();
//galeb_plateC();
//cslots();
//galeb_plateD();
//galeb_plateE();
//galeb_lockE();

//galeb_M8cover();

//galeb_fan_adapter();
//galeb_fan_inlet();

//galeb_rod_polisher_contour1();
//galeb_rod_connector_contour2();
//galeb_rod_connector();
//galeb_rod_polisher();

//vcase();
//vcase_bottom();

//difference() {
adapter_sup2dinghy();
//translate([0,0,-0.1]) cube([50,50,50]);}
