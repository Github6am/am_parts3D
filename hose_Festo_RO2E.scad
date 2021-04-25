/*------------------------------------------------------------* 
   hose_Festo_RO2E.scad
   
   Vacuum cleaner adapter for Festo RO2E excenter grinder

   Background:
   - Excenter-Schleifer Adapter fuer Staubsauger mit 35mm Rohr
   - CAD manual: http://www.openscad.org/documentation.html
   - this design is easily adaptable to other diameters in the
     OpenSCAD source code which is available at
     https://github.com/Github6am/am_parts3D
   - comparable designs
     https://www.thingiverse.com/thing:4592424
     https://www.thingiverse.com/thing:2388924


 *------------------------------------------------------------*/

//import("/home/amerz/download/thingiverse/Festool_RO_150_E_Vacuum_Adapter/files/Festool_RO150E.stl");

w=2.2;      // wall thickness
c=0.4;      // clearance
dox=36;     // outer diameter greater axis of ellipse
doy=18;     // outer diameter smaller axis of ellipse
h1=18;      // section heigth
h2=10;
h3=50;
divac=34.5;  // outer diameter of vacuum cleaner hose

// 2D-shape
module elliptic_shape(a,b,delta) {
      scale([1, (b+delta)/(a+delta)]) circle(d=(a+delta), $fn=96);
}



module elliptic_hoseA( hh=h1 ) {
  difference() {
    translate([0,0,0]) 
      linear_extrude( height = hh, center = true, scale = 1.0)
        elliptic_shape( a=dox, b=doy, delta=-c);
    translate([0,0,-0.01])
      linear_extrude( height = hh+0.04, center = true, scale = 1.0) 
        elliptic_shape( a=dox, b=doy, delta=-w);
  }
}

module vacuum_hoseA( hh=h3 ) {
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

module taper_hoseA( hh=h2 ) {
  scalexo=(divac+w)/(dox-c);
  scalexi=(divac)/(dox-w);
  scaleyo=(divac+w)/(doy-c);
  scaleyi=(divac)/(doy-w);
  difference() {
    translate([0,0,0]) 
      linear_extrude( height = hh, center = true, scale = [scalexo, scaleyo])
        elliptic_shape( a=dox-c, b=doy-c, delta=0);
    translate([0,0,-0.01])
      linear_extrude( height = hh+0.04, center = true, scale = [scalexi, scaleyi]) 
        elliptic_shape( a=dox-w, b=doy-w, delta=0);
  }
}


// assemble the sections

module hose_Festo_RO2E() {
    translate([0,0,       h1/2]) elliptic_hoseA();
    translate([0,0,    h1+h2/2]) taper_hoseA();
    translate([0,0, h1+h2+h3/2]) vacuum_hoseA();
}


//------------- Instances --------------------
//elliptic_shape( a=divac, b=divac, delta=c);

//elliptic_hoseA();
//taper_hoseA();
//vacuum_hoseA();

rotate([0,180,0]) hose_Festo_RO2E();
