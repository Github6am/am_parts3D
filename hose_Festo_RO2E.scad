/*------------------------------------------------------------* 
   hose_Festo_RO2E.scad
   
   Vacuum cleaner adapter for Festo RO2E excenter grinder

   Background:
   - Exzenter-Schleifer Adapter fuer Staubsauger mit 35mm Rohr
   - this design is easily adaptable to other diameters in the
     OpenSCAD source code which is available at
     https://github.com/Github6am/am_parts3D
   - CAD manual: http://www.openscad.org/documentation.html
   - comparable designs
     https://www.thingiverse.com/thing:4592424
     https://www.thingiverse.com/thing:2388924


 *------------------------------------------------------------*/

//import("/home/amerz/download/thingiverse/Festool_RO_150_E_Vacuum_Adapter/files/Festool_RO150E.stl");

w=2.0;      // wall thickness
c=0.15;     // clearance
dox=36;     // outer diameter greater axis of ellipse
doy=18;     // outer diameter smaller axis of ellipse
h1=18;      // elliptic section heigth
h2=10;      // taper section heigth
h3=50;      // cylindrical section heigth
divac=34.5; // outer diameter of vacuum cleaner hose at end


// 2D-shape
module elliptic_shape(a,b,delta) {
      scale([1, (b+2*delta)/(a+2*delta)]) circle(d=(a+2*delta), $fn=96);
}



module elliptic_pipeA( hh=h1 ) {
  difference() {
    translate([0,0,0]) 
      linear_extrude( height = hh, center = true, scale = 1.0)
        elliptic_shape( a=dox, b=doy, delta=-c);
    translate([0,0,-0.01])
      linear_extrude( height = hh+0.04, center = true, scale = 1.0) 
        elliptic_shape( a=dox, b=doy, delta=-w);
  }
}

module vacuum_pipeA( hh=h3 ) {
  s=(divac+1)/divac;    // make 1mm conical
  difference() {
    translate([0,0,0]) 
      linear_extrude( height = hh, center = true, scale = s)
        elliptic_shape( a=divac, b=divac, delta=w);
    translate([0,0,-0.01])
      linear_extrude( height = hh+0.04, center = true, scale = s) 
        elliptic_shape( a=divac, b=divac, delta=c);
  }
}

module taper_pipeA( hh=h2 ) {
  scalexo=(divac+2*w)/(dox-2*c);
  scalexi=(divac)/(dox-2*w);
  scaleyo=(divac+2*w)/(doy-2*c);
  scaleyi=(divac)/(doy-2*w);
  difference() {
    translate([0,0,0]) 
      linear_extrude( height = hh, center = true, scale = [scalexo, scaleyo])
        elliptic_shape( a=dox-2*c, b=doy-2*c, delta=0);
    translate([0,0,-0.01])
      linear_extrude( height = hh+0.04, center = true, scale = [scalexi, scaleyi]) 
        elliptic_shape( a=dox-2*w, b=doy-2*w, delta=0);
  }
}


// assemble the sections

module hose_Festo_RO2E() {
    translate([0,0,       h1/2]) elliptic_pipeA();
    translate([0,0,    h1+h2/2]) taper_pipeA();
    translate([0,0, h1+h2+h3/2]) vacuum_pipeA();
}


//------------- Instances --------------------
//elliptic_shape( a=divac, b=divac, delta=c);

//elliptic_pipeA();
//taper_pipeA();
//vacuum_pipeA();

rotate([0,180,0]) hose_Festo_RO2E();
