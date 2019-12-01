// fixture for PCB, Daypower step down module 2596-2
// 
// 
// Background:
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//   - product purchase
//     https://www.pollin.de/p/step-down-modul-mit-spannungsanzeige-daypower-power-2596-2-810585
//
// Andreas Merz 2019-08-20, v0.2 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

// Main dimensions
bw=43.6;       // board width
dw=0.6;        // ridge depth to hold board
bt=1.8;        // board thickness
wall=1.8;      // wall thickness
fw=10;         // fixture width

//-------------------------------------------
// board fixure
//-------------------------------------------
module dovetailmounts(y1=0) {
     linear_extrude(height = fw) 
       union() {
         translate([-2*10+5, y1,0]) rotate(180) schwalbenschwanz();
         translate([-1*10+5, y1,0]) rotate(180) schwalbenschwanz();
         translate([-0*10+5, y1,0]) rotate(180) schwalbenschwanz();
         translate([ 1*10+5, y1,0]) rotate(180) schwalbenschwanz();
         //translate([ 2*10+5, y1,0]) rotate(180) schwalbenschwanz();
       }
}

module boardfixture() {
   h3=4.5;
   union() {
     linear_extrude(height = fw)
       difference() {
         union() {
           square([bw+2*wall+2*dw, h3+bt+2*wall]);
         }
         union() {
           minkowski() {
             translate([wall+2*dw+1, wall+1, 0]) square([bw-2*dw-2, h3+bt+2*wall]);
             circle(r=1,$fn=48);
           }
           translate([wall+dw   , h3+wall, 0]) square([bw, bt]);
         }
       }  
    translate([(bw+2*wall+2*dw)/2,0, 0]) dovetailmounts();
  }     
}



//------------- Instances --------------------

boardfixture();

