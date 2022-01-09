// Replacement part for the board game Camel Cup
//
// Background:
//   - https://de.wikipedia.org/wiki/Camel_Up
//   - CAD manual: http://www.openscad.org/documentation.html
//
//   - see also:
//     https://www.thingiverse.com/thing:5193783
//   - I forgot to search for related stuff before:
//     see also:
//     https://www.thingiverse.com/thing:3215604
//     https://www.thingiverse.com/thing:3729634
//     https://www.thingiverse.com/thing:2025015
//
// Andreas Merz 2022-01-08, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses



//---------------- Pyramid parts ---------------------

// the slider which is retracted by a rubber band
module pyramid_slider(
     r=1,           // chamfer / radius
     z=1.8,         // thickness
     ) {
     a=38;
     b=96;    // overall length
     c=50;    // overall width
     d=13;
     e=29;    // slot separation
     f=5;
     w=3.5;   // slot width
     m=0.2;   // chamfer 3D
     R=2*(r+m);
     minkowski() { 
       sphere(r=m);   // chamfer the whole thing, this is just nice to have ...
       linear_extrude(height=z-2*m) 
	 difference() {
	   union() {
             translate([0,b/2]) offset(r=r,$fn=12) square([a-R,b-R], center=true);
             translate([0,d/2]) offset(r=r,$fn=12) square([c-R,d-R], center=true);
	   }       
	   union() {
             translate([ (e+w)/2,0]) square([w+2*m, 2*f], center=true);  // slot
             translate([-(e+w)/2,0]) square([w+2*m, 2*f], center=true);  // slot
             translate([0, 59])      circle(d=24.4+2*m, $fn=48);        // hole
             // Arrow
	     translate([0, 79]) polygon(points=[[2,12],[1.5,4],[3.5,4],[0,0],[-3.5,4],[-1.5,4],[-2,12]]);

	   }       
	 }
     }
}



//---------------- Instances ---------------------

pyramid_slider();
