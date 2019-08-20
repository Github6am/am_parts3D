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
// Andreas Merz 2019-08-20, v0.3 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

// Main dimensions
xin=67.2;      // width
yin=74.4;      // length
zin=22.7;      // height
wall=0.8;      // wall thickness

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


module MR3020fixture() {
   h1=4+wall;
   
   union() {
     linear_extrude(height = h1)
       difference() {
         MR3020shape(w=wall);
         MR3020shape(w=0);
       }
     linear_extrude(height = wall)
       difference() {
         MR3020shape(w=wall);
         MR3020shape(w=-5);
       }
     difference() {
         union(){    // Halteclips
           translate([0, yin/2-1, 5])              cube([xin*0.9, 4, 10], center=true);
           translate([0, yin/2-1, (zin+wall+2)/2+1.2]) cube([10, 4, zin+wall], center=true);
           translate([  xin/2+wall-3.4/2,  0, (zin+wall+2)/2+1.2]) cube([3.4, 10, zin+wall], center=true);
           translate([-(xin/2+wall-3.4/2), 0, (zin+wall+2)/2+1.2]) cube([3.4, 10, zin+wall], center=true);
         }
         union() {   // TP-Link Gehaeuse mit Dachschraege
           linear_extrude(height = zin+wall) MR3020shape(w=0);
           translate([0,0,zin+wall-0.1]) linear_extrude(height = xin/3,scale=0) MR3020shape(w=0);
         }
     }
     // right interface
     linear_extrude(height = 10) 
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

