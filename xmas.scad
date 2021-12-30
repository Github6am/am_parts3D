// xmas.scad
//   X-mas related stuff, stars for decoration
//
// Background:
//   - the starts can be parameterized to create
//     a wealth of various shapes
//   - printed with a layer step of 0.2 mm
//   - CAD manual: http://www.openscad.org/documentation.html
//   - see also dodekaeder.scad as "Adventskalender"
//   - hosted on:
//     git@github.com:Github6am/am_parts3D.git
//
// Andreas Merz 2021-12-21, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses


//-----------------------------------------------
// stars for decoration
//-----------------------------------------------

// a 2D single edge polygon
module star_edge1(
  w=1,       // width
  a=18,      // radius outer circle
  b=10,       // radius inner circle
  n=4,       // number of rays
  ) {
      c=cos(180/n);
      s=sin(180/n);
      bb=[c, s]*b;
      aa=[a, 0];
      phi=atan(s*b/(a-b*c));    // tip angle/2
      w2=w/2;
      da=w2*[1/sin(phi),0];
      eb=[c, s];
      en=[sin(phi), cos(phi)];
      t=eb*en;
      db=w2*eb/t;
      polygon( points=[aa-da, aa+da, bb+db, bb-db]);
}

// a 2D star shape
module star_edge2(
  w=2,     // width
  a=80,    // radius outer circle
  b=30,     // radius inner circle
  n=5,       // number of rays
  ) {
      for (i = [0 : n-1]) {
	rotate([0, 0, 360.01/n*i])
	union() {
            star_edge1(w=w, a=a, b=b, n=n);
	  mirror([0,1,0]) 
            star_edge1(w=w, a=a, b=b, n=n);
	}
      }
}

// the 3D multi star
module star(
  h=0.8,     // height
  w=0.8,     // width
  a=80,      // radius outer circle
  b=30,      // radius inner circle
  n=5,       // number of rays
  m=4,       // number of scaled and rotated stars
  rot=0.5,   // rotation in units of rays
  scl=0.618, // scale for every sub star
  zinc=0     // heigth increment for every sub star
  ) {
      //s1=b/a*1.618;
      s1=scl;
      for (i =[0 : m-1] ) {
        s = exp(ln(s1)*i);    // older openscad versions do not know s1^i
	//echo( s );
        rotate([0, 0, rot*360/n*i]) 
          linear_extrude( height = (h+i*zinc))
            star_edge2(w=w, a=(a*s), b=(b*s), n=n);
      }
}



//---------------- Instances ---------------------


//star();
//star( h=1.0, w=1.2, a=80, b=30,   n=5, m=5, rot=0.5,   scl=0.618, zinc=0.2);
star( h=1.0, w=1.2, a=50, b=19,   n=5, m=5, rot=0.5,   scl=0.618, zinc=0.2);
//star( h=1.0, w=1.2, a=50, b=19,   n=5, m=7, rot=0.065, scl=0.79,  zinc=0.2);

//star( h=1.0, w=1.2, a=50, b=10,   n=6, m=3, rot=0.5,   scl=0.618, zinc=0.2);
//star( h=1.0, w=2.2, a=50, b=25,   n=3, m=2, rot=0.5,   scl=1.0,   zinc=0.0); // davidstern
//star( h=1.0, w=1.2, a=50, b=31.7, n=8, m=7, rot=0.18,  scl=0.8,   zinc=0.2);
