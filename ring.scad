// Rings
//
// Andreas Merz 21.12.2018, v0.1, GPL


function ellipse(num=16, dx=3, dy=5) = 
  [for (i=[0:num-1], a=i*360/num) [ dx/2*cos(a), dy/2*(sin(a)+1) ]];


module ringA(di=16) {
         rotate_extrude($fn = 80)
           translate([di/2, 0, 0])
             polygon( points=[[0,0],[1,0],[2,1],[2,4],[1,5],[0,5]] );
}

module ringB(di=16) {
         rotate_extrude($fn = 80)
           translate([(di+2)/2, 0, 0])
             polygon( points=ellipse(dx=2,dy=5));
}

module ringC(di=16) {
         rotate_extrude($fn = 80)
           translate([(di+2)/2, 0, 0])
             polygon( points=ellipse(num=6, dx=2,dy=5));
}

color("blue")
translate([0, 0, 0])
  ringA();

color("red")
translate([30, 0, 0])
  ringB();

color("green")
translate([15, 26, 0])
  ringC();

