// experiments with pentagons
//
//
// Background:
//   - CAD manual: http://www.openscad.org/documentation.html
//   - https://de.wikipedia.org/wiki/Dodekaeder
//   - https://en.wikipedia.org/wiki/Dodecahedron
//
// Andreas Merz 2019-11-23, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses

a=20;   // outer edge length
w=0.6;    // wall thickness

// Dodekaederzahlen
ci=1.113516364411607;    // Inkugelradius/a  sqrt((25+11*sqrt(5))/10)/2;
h=a*ci;

beta=121.7174744114610;  // Flaechen-Kantenwinkel


module poly2D(r=30, n=5) {
   circle(r=r, $fn=n);
}

module pentagon2D(l_edge = a) {
  poly2D(r = l_edge/(2*sin(36)), n=5);
}

module facet0() {
  d=a/(2*tan(36));   // Abstand Seitenmitte vom Zentrum
  phi1=atan(d/h);    // Winkel zwischen Seitenflaeche und Lot
  dh=w/sin(phi1);    // vertikale Verschiebung, um Wandstaerke zu erreichen
  
  difference() {
    linear_extrude(height=h, scale=0) pentagon2D();
    translate([0, 0, -dh]) 
      linear_extrude(height=h, scale=0) pentagon2D();
  }
}

module facet1() {
  u=1.5*w;
  union() {
    facet0();
    difference() {
      linear_extrude(height=u, scale=1) pentagon2D(l_edge=a-1.5*w);
      translate([0, 0, -0.1])
        linear_extrude(height=u+0.2, scale=1) pentagon2D(l_edge=a-3*w);
    }
  }
}

module facet1t() {
  phi2=2*beta-180;    // 63.43 deg
  translate([0, 0, h]) rotate([0, phi2, 0]) translate([0, 0, -h]) rotate([0, 0, 36]) facet1(); 
}

module facet6() {
  union() {
    facet1();
    rotate([0, 0, 0*72]) facet1t();
    rotate([0, 0, 1*72]) facet1t();
    rotate([0, 0, 2*72]) facet1t();
    rotate([0, 0, 3*72]) facet1t();
    rotate([0, 0, 4*72]) facet1t();
  }
}

module facet12() {
  union() {
    facet6();
    translate([0, 0, h]) rotate([0, 180, 72]) translate([0, 0, -h]) facet6();
  }
}

translate([2*a, 0, 0]) facet12();

facet1();
