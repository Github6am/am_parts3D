// dodekaeder.scad
//   experiments with pentagons forming a dodecahedron
//
//
// Background:
//   - kann auch als Adventskalender benutzt werden.
//   - printed with a layer step of 0.15 mm
//   - CAD manual: http://www.openscad.org/documentation.html
//   - https://de.wikipedia.org/wiki/Dodekaeder
//   - https://en.wikipedia.org/wiki/Dodecahedron
//   - hosted on:
//     https://www.thingiverse.com/thing:4012530
//     git@github.com:Github6am/am_parts3D.git
//
// Andreas Merz 2019-12-01, v1.2 
// GPLv3 or later, see http://www.gnu.org/licenses

a=30;     // outer edge length
b=27;     // inner edge length
w=0.6;    // wall thickness

// Dodekaederzahlen
ci=1.113516364411607;    // Inkugelradius/a  sqrt((25+11*sqrt(5))/10)/2;
co=1.401258538444073;    // Umkugelradius/a  sqrt(3)*(1+sqrt(5))/4;
h=a*ci;                  // height of a cone           

beta=121.7174744114610;  // deg, Flaechen-Kantenwinkel
alpha=116.5650511770780; // deg, Flaechenwinkel , acos(-1/sqrt(5))


module poly2D(r=30, n=5) {
   circle(r=r, $fn=n);
}

module pentagon2D(l_edge = a) {
  poly2D(r = l_edge/(2*sin(36)), n=5);
}

//-----------------------------------------------
// pyramid shaped parts of a dodecahedron
//-----------------------------------------------

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
  u=ci*(a-b);
  union() {
    facet0();
    difference() {
      linear_extrude(height=u, scale=(h-u)/h) pentagon2D(l_edge=a-w);
      translate([0, 0, -0.1])
        linear_extrude(height=u+0.2, scale=1) pentagon2D(l_edge=b);
    }
  }
}

module facet1t() {
  phi2=2*beta-180;   
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

//-----------------------------------------------
// numbered caps to close the faces
//-----------------------------------------------

module cap1() {
  c=0.35;
  hrim=0.7*(a-b);
  union() {
    linear_extrude(height=w, scale=1) pentagon2D(l_edge=a-c);
    difference() {    // rim
      linear_extrude(height=w+hrim, scale=1) pentagon2D(l_edge=b-c);
      translate([0, 0, w+0.15])
  	linear_extrude(height=w+hrim, scale=1) pentagon2D(l_edge=b-c-1.5*w);
    }
  }
}

module grid2D(spacing=0.8) {    // a grid pattern for the text
  w=0.5;
  for( i=[-a:spacing:a] ) {
    translate([i,0,-0.01]) square([spacing/2,a],center=true);
  }
}

module capA(txt="12") {
  depth=0.2;
  fontname = "Liberation Sans:Bold";
  fontsize = 20;
  difference() {
    cap1();
    //color("red")
    translate([0,0,-0.01]) mirror([1,0,0]) rotate(90)
      linear_extrude(height = depth)
	difference() {
	  text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 16);
	  grid2D();
	}
  }
}

//-----------------------------------------------
// a foot to place the dodecahedron segments in
//-----------------------------------------------

nf=5;	   // nf     number of faces, a high number yields a circular shape.
c2=2;	   // c2     height of foot cone below rim
kk=tan(180-beta);
clr=1.2;     // clearance

//h2=a;      // h2     height of foot cone above rim

module foot0(hole=0, h2=1.2*a) {
  //hole    option for depth of conical borehole
  // h2     height of foot cone above rim
  c=clr;
  // helper sizes
  rr = a/(2*sin(36)); // inner rim radius
  h=kk*rr;            // dirty trick: override height with height of imagined sidewall pyramid
  r2 = rr*(h+h2)/h+c;   // inner upper radius
  rc = rr*(h-c2)/h+c;   // inner lower radius
  rh = rr*(h-hole)/h+c; // inner lower hole radius
  phi1=atan(rr/h);      // Winkel zwischen Kante und Lot
  dh=w/sin(phi1);       // vertikale Verschiebung, um Wandstaerke zu erreichen
  H=h+dh;               // outer height of full cone
  Rr=rr+w;              // outer radius
  R2=r2+w;
  Rc=rc+w;
  Rh=rh+w;
  
  translate([0, 0, 0])
    difference() {
      translate([0, 0, 0])            linear_extrude(height=(h2+c2),   scale=R2/Rc) poly2D(r = Rc, n=nf);
      translate([0, 0, c2-hole+0.05]) linear_extrude(height=(h2+hole), scale=r2/rh) poly2D(r = rh, n=nf);
  }
}

module foot1() {
  rim=2;
  c=clr;
  h2=a/4;
  rr = a/(2*sin(36)); // rim radius
  h=kk*rr;
  rc = rr*(h-c2)/h+c;   // lower radius
  r2 = rr*(h+h2)/h+c;   // inner upper radius
  
  
  union() {
  translate([0, 0, h2+c2])
    union() {
      translate([0, 0, 0])
	difference() {
          foot0(hole=0);
          translate([0, 0, -h]) linear_extrude(height=2*h, scale=0) poly2D(r = 1.99*rr, n=nf);
	}
      mirror([0, 0, 1]) foot0(hole=c2+1,h2=h2);
    }
    difference() {
       translate([0, 0, 0])    linear_extrude(height=1)  poly2D(r = r2+rim, n=nf);
       translate([0, 0, -0.1]) linear_extrude(height=1.2, scale=0.99) poly2D(r = r2, n=nf);
    }
  }
}

module foot2() {
  rim=3;
  c=clr;
  h2=1;
  nc=144;
  rs=a*co+c;           // inner sphere radius
  Rs=rs+w;             // outer sphere radius
  rc = 0.7*a;          // inner cylinder radius
  Rc=rc+w;             // outer cylinder radius
  
  translate([0, 0, Rs+h2])
    difference() {
      union() {
	sphere(r=Rs,$fn=196);
	translate([0, 0, -Rs-h2]) cylinder(r=Rc,     h=2*h,$fn=nc);
	translate([0, 0, -Rs-h2]) cylinder(r=Rc+rim, h=2,  $fn=nc);
      }
      union() {
	sphere(r=rs,$fn=196);
	//translate([0, 0, -Rs-h2-0.1]) cylinder(r1=rc, r2=a/2-2,  h=h2+4, $fn=nc);
	translate([0, 0, a/5])      cylinder(r=Rs+1, h=Rs+1,$fn=nc);   // cut off top of sphere
      }
    }
}

//---------------- Instances ---------------------

//translate([0, 0, 0]) facet12();     // das hat bisher beim Ausdrucken Probleme gemacht.

facet1();
//facet6();

translate([2*a, 0, 0]) capA(txt=str(12));

//foot1();
//difference() {
//foot2();
//translate([0, 0, -10]) cube(40, center=false); }

if(false) {
  for( ii=[1:3] ) {
    rotate(ii*120) translate([-0.9*a, 0, 0]) capA(txt=str(ii*2));
  }

  for( ii=[7:9] ) {
    translate([-10, -2.6*a, 0])
    rotate(ii*120+60) translate([-0.9*a, 0, 0]) capA(txt=str(ii*2));
  }


  for( ii=[10:12] ) {
    translate([1.6*a, (ii-11)*1.7*a, 0]) capA(txt=str(ii*2));
  }

}
