// Buchse fuer KFZ-Adapter 12V auf 5V USB, fuer Hutschienenmontage
// 
// 
// Background:
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//   - comparable things:
//     https://www.thingiverse.com/thing:1751807
//     https://www.thingiverse.com/thing:966696
//   - Idee: mit einem Konus oder Keil fixieren, so wie der Druckerschlauch
//
// Andreas Merz 2019-08-20, v0.2 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

// Main dimensions
din=20.4;      // inner diameter
zin=35;        // height
wall=5;        // wall thickness
hb=8;          // bottom thickness

//-------------------------------------------
// enclosure for 12V Adapter
//-------------------------------------------
module screwholes() {
   m3=2.8;    // M3
   d3=6.2;    // M3 cyl head
   m4=3.8;    // M4
   union() {
     // Pluspol
     translate([ 11,0,hb-m3]) rotate([0, 90,0])  cylinder(h=20, d=d3, center=false,$fn=24);
     translate([-11,0,hb-m3]) rotate([0,-90,0])  cylinder(h=20, d=d3, center=false,$fn=24);
     translate([0,0,hb-m3]) rotate([0,90,0])  cylinder(h=30, d=m3, center=true,$fn=24);

     // Minuspol
     translate([0,0,hb-m3]) rotate([90,0,0])  cylinder(h=60, d=m3, center=true,$fn=24);
     translate([0,0,hb+17]) rotate([0,90,0])  cylinder(h=60, d=m3, center=true,$fn=24);
     translate([0,0,hb+24]) rotate([0,90,0])  cylinder(h=60, d=m3, center=true,$fn=24);

     // Halteschrauben
     translate([0,0,hb+31]) rotate([0,90,0])  cylinder(h=60, d=m4, center=true,$fn=24);
     translate([0,0,hb+31]) rotate([0,90,30])  cylinder(h=60, d=m4, center=true,$fn=24);
     translate([0,0,hb+31]) rotate([0,90,-30])  cylinder(h=60, d=m4, center=true,$fn=24);
     translate([0,0,hb+31]) rotate([0,90,90])  cylinder(h=60, d=m4, center=true,$fn=24);

     // Dummy holes
     translate([0,0,hb+4]) rotate([0,90,30])  cylinder(h=60, d=m4, center=true,$fn=24);
     translate([0,0,hb+4]) rotate([0,90,-30])  cylinder(h=60, d=m4, center=true,$fn=24);
     translate([0,0,hb+4]) rotate([0,90,90])  cylinder(h=60, d=m4, center=true,$fn=24);
     
   }

}

module mounts(y1=16) {
     linear_extrude(height = zin+hb) 
       union() {
         translate([-1*10+5, y1,0]) rotate(0) schwalbenschwanz();
         translate([ 0*10+5, y1,0]) rotate(0) schwalbenschwanz();
         translate([-1*10+5,-y1,0]) rotate(180) schwalbenschwanz();
         translate([ 0*10+5,-y1,0]) rotate(180) schwalbenschwanz();
       }
}

module KFZstecker() {
   h1=4*(din/2+wall)/sqrt(3);  // outer hexagon diameter
   difference() {
     union() {
       translate([-h1/2,-10/2,0]) cube([h1, 10,zin+hb],center=false);
       translate([0,0,0])         cylinder(h=zin+hb  ,d=h1,center=false,$fn=6);
       mounts(y1=din/2+wall);
     }
     union() {
       translate([-(din+1)/2,-6/2,hb]) cube([din+1, 6, zin+1],center=false);
       translate([0,0, hb])             cylinder(h=zin+1+hb,d=din,center=false,$fn=48);
       translate([0,0,2])              cylinder(h=30,   d=7,    center=false,$fn=48);
       translate([0,0,-1])             cylinder(h=10,   d=4.7,  center=false,$fn=48);
       screwholes();
     }
   }
}  

//------------- Instances --------------------


translate([0,0,0]) KFZstecker();

       //mounts(y1=14.5);

