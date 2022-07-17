// Fingerhut / thimble
//
// Andreas Merz 2021-01-06, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses


// Main dimensions
rin=18.0/2;      // inner width
zin=16;          // inner height
wall=0.8;        // wall thickness of printed part
clr=0.4;       // clearance

//-------------------------------------------
// cone+cylinder
//-------------------------------------------

module ccyl(h0=0, h1=wall, h2=wall, r1=rin, ang=-45, h3=0) {
    s0=0.9;
    s1=0.95;   // h1 cone
    ss=(r1-h2*tan(ang))/r1;
    rotate([-90,0,0]) translate([0,0,-0.01])
    union() {
      linear_extrude(height=h0, scale=s0)  circle(r=r1/s0,$fn=48);
      linear_extrude(height=h1, scale=s1)  circle(r=r1/s1,$fn=48);
      translate([0,0,h1])
        linear_extrude(height=h2, scale=ss) circle(r=r1, $fn=48);
      translate([0,0,h1+h2])
        linear_extrude(height=h3, scale=1) circle(r=r1*ss, $fn=48);
    }
}

module fingerhutA(d=2*rin, l=zin) {
  rotate([180,0,0])
  difference()  {
    rotate([90,0,0]) ccyl(r1=d/2+wall, h1=l, h2=2, ang=30, h3=0);
    translate([0,0,-wall])
      rotate([90,0,0]) ccyl(r1=d/2,    h0=3, h1=l, h2=2, ang=30, h3=0);
  }
}


//------------- Instances --------------------
// test-Schnitt
//  difference()  {
fingerhutA();
//    translate([0,0,-30]) cube(40);  }
//fingerhutA(d=17-clr,l=49);     // lipstick cover


