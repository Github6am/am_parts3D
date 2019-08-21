// Fixture for TP-Link MR3020 WLAN Router 
// 
// 
// Background:
//   - Optional mounting on a 35mm DIN-Rail (Hutschiene) 
//     using dovetail connection
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2019-08-21, v0.4 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

// Main dimensions
xin=67.1;      // width
yin=74.2;      // length
zin=22.0;      // height
wall=0.8;      // wall thickness
h1=4+wall;     // wall height

//-------------------------------------------
// enclosure for TP-Link MR3020 Router case
//-------------------------------------------
module MR3020shape(w=0) {
    rc=10;     // corner radius
    minkowski() { 
        circle(r=rc+w);
        square([xin-2*rc,yin-2*rc], center=true);
        }
}

module MR3020cornerclip() {
    difference() {
      linear_extrude(height = zin+wall+2*wall) MR3020shape(w=wall);  // outer wall
      union() {
        translate([0, 0 , -0.1 ]) cube([xin-20, yin+20, 3*zin], center=true);
        translate([0, 0 , -0.1 ]) cube([xin+20, yin-20, 3*zin], center=true);
        translate([0, (yin+20)/2 , -0.1 ]) cube([xin+20, yin+20, 2.5*zin], center=true);
      }    
    }
}

module MR3020fixture() {
   h2= zin/2;  // height of mounting plane
   union() {
     difference() {
         union(){    
           linear_extrude(height = h1) MR3020shape(w=wall);  // outer wall
           
           // Rueckwand
           translate([0, yin/2-1, h2/2]) cube([xin*0.94, 4, h2], center=true);

           // Halteclips
           translate([0, yin/2-1, (zin+wall)/2+2*wall]) cube([10, 4, zin+wall], center=true);
           //translate([  xin/2+wall-3.4/2,  0, (zin+wall+2)/2+1.2]) cube([3.4, 10, zin+wall], center=true);
           //translate([-(xin/2+wall-3.4/2), 0, (zin+wall+2)/2+1.2]) cube([3.4, 10, zin+wall], center=true);
           MR3020cornerclip();
         }
         union() {   // TP-Link Gehaeuse mit Dachschraege
           translate([0,0, -0.2]) linear_extrude(height = wall+0.2) MR3020shape(w=-5);   // bottom hole
           translate([0,0,+wall]) linear_extrude(height = zin)      MR3020shape(w= 0);    // body for TP-Link
           translate([0,0,zin+wall-0.1]) linear_extrude(height = xin/4,scale=0) MR3020shape(w=0);  // roof
           linear_extrude(height = zin+wall+10) MR3020shape(w=-3);
         }
     }
     // right interface
     linear_extrude(height = h2) 
       union() {
         translate([-3*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
         translate([-2*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
         translate([-1*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
         translate([ 0*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
         translate([ 1*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
         translate([ 2*10+5,yin/2+1,0]) rotate(0) schwalbenschwanz();
       }
   } 
}

//------------- Instances --------------------

MR3020fixture();
