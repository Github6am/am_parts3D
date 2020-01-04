// Halterung fuer 610mAh flat LiPo Handy-Akkus von Infineon
// 
// 
// Background:
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2020-01-04, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <am_dovetail.scad>


// Main battery dimensions
xaa1=27.2;     // Weite am Sockel
xaa2=34;       // max Weite
yaa1=4.5;      // Dicke am Sockel
zaa1=15;       // height

wall=1.2;      // wall thickness
caa=0.3;       // clearance

// inner shape
module battery_shapeI() {
    c=caa;
    sx=(xaa1+c+1)/(xaa1+c);   // Fase an der Stufe
    difference() {
      union() {
	 translate([0,(yaa1+c)/2,2+wall]) linear_extrude(height=1+c, scale=[sx,1]) 
	                                   square([xaa1+c, yaa1+c], center=true);
	 translate([-(xaa1+c)/2,0,0+wall]) cube([xaa1+c, yaa1+c, 2+c]);
	 translate([-(xaa2+c)/2,0,3+wall]) cube([xaa2+c, yaa1+c, zaa1]);
	 // bore holes
	 translate([-2.5,yaa1/2,4.2+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 translate([-2.5,yaa1/2,1.5+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 translate([ 0.0,yaa1/2,3.0+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 translate([ 0.0,yaa1/2,1.0+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 translate([+2.5,yaa1/2,4.2+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 translate([+2.5,yaa1/2,1.5+wall]) rotate([90,0,0]) cylinder(d=1.1,h=13, $fn=16, center=true);
	 
	 //translate([-(xaa2+c+2.5)/2,     0,12+wall]) rotate([90,0,0]) cylinder(r=3,h=7, $fn=32, center=false);
	 //translate([-(xaa2+c+2.5)/2,yaa1+7+caa,12+wall]) rotate([90,0,0]) cylinder(r=3,h=7, $fn=32, center=false);
	 
	 // triangle hole to simplify contact mounting
	 translate([0,-yaa1/2+1,wall]) linear_extrude(height=10,scale=[0,1]) square([11.55,3], center=true);

      }
      union() {
	 translate([-(xaa2+c+3.0)/2,yaa1/2,12+wall]) rotate([90,0,0]) cylinder(r=2,h=yaa1+1, $fn=32, center=true);
	 translate([+(xaa2+c+3.0)/2,yaa1/2,12+wall]) rotate([90,0,0]) cylinder(r=2,h=yaa1+1, $fn=32, center=true);

         // contact support
	 translate([+2.5,yaa1/2+2.7,2.85+wall]) rotate([0,90,0]) cylinder(r=0.8,h=1.3, $fn=32, center=true);
	 translate([ 0.0,yaa1/2+2.5,2.0 +wall]) rotate([0,90,0]) cylinder(r=0.5,h=1.3, $fn=32, center=true);
	 translate([-2.5,yaa1/2+2.7,2.85+wall]) rotate([0,90,0]) cylinder(r=0.8,h=1.3, $fn=32, center=true);
      }
    }
}

// outer shape
module battery_shapeO() {
    c=caa;
    union() {
       translate([-(xaa2+2*wall)/2,-wall,0]) cube([xaa2+2*wall, yaa1+2*wall+c, zaa1]);
       translate([-(xaa2+2*wall)/2,+(yaa1)/2,0]) rotate([0,0,90]) dovetailAdd(h=zaa1);
       translate([+(xaa2+2*wall)/2,+(yaa1)/2,0]) rotate([0,0,-90]) dovetailAdd(h=zaa1);
    }
}

module battery_holder1() {
    c=caa;
    difference() {
      battery_shapeO();
      battery_shapeI();
    }
}

module battery_holder2() {
    union() {
      battery_holder1();
        
    }
}

//------------- Instances --------------------

//battery_shapeI();
battery_holder1();
