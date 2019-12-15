// hose branch  -  Regenrohr Abzweig
// 
// Background:
//   - Einbau in ein Carport-Regenfallrohr, um Wasser ueber
//     einen Gartenschlauch zu entnehmen. Schmutz soll sich 
//     an Boden absetzen. Ein kleines Entwaesserungsloch kann
//     optional am Boden gebohrt werden.
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-12-15, v0.1
// GPLv3 or later, see http://www.gnu.org/licenses

// https://www.thingiverse.com/thing:2405122
// Gardena Profi System Plug to your Thing - hier gibts ein openscad file!
// O-Ring-Nut Oberkante ist scharf, koennte Druckprobleme geben?

// https://www.thingiverse.com/thing:2470917
// Gardena Hose Joiner (extended version)
// by cschumac Aug 6, 2017 

// https://www.thingiverse.com/thing:1096796
// Gardena Hose Joiner
// by TLC3DP Oct 28, 2015 

// ----------------------------------------------
// Global parameters
w=1.5;   // wall thickness
nf=180;  // number of polygon faces

module gardena_joiner() {
   import("gardena-top-joiner_fixed.stl");
}

module gardena_half() {
      union() {
        translate([0,-0.5,-21]) gardena_joiner();
	translate([0,0,-20]) cylinder(r=11, h=40, center=true);
	
      }
}

module hose_branch(hh=120, d=50) {
    //d:  outer diameter of hose
    c=0.2;    // clearance
    ro=d/2+w;
    rn=d/2;
    ri=d/2-w;
    hm=24;           // Hoehe Mittelteil
    h2=(hh-hm)/2;    // Einstecktiefe Anschlussrohr
    
    // branch
    rbo=12/2;
    rbi=rbo-w;
    
    difference() {
      union() {
	difference() {
	  // outer contour
	  union() {
	    translate([0,0,   -hm/2-w]) cylinder(r1=rn, r2=ro, h=w, $fn=nf); // make printable step
	    translate([0,0,   -hm/2]) cylinder(r=ro, h=h2+hm/2,$fn=nf);      // upper
	    translate([0,0,-h2-hm/2]) cylinder(r=rn-c, h=h2,$fn=nf);         // lower
	  }
	  // inner contour
	  union() {
	    translate([0,0,    hm/2])   cylinder(r=rn+c, h=h2+c,$fn=nf);
	    translate([0,0,-h2-hm/2+w]) cylinder(r=ri, h=h2+hm+2*c,$fn=nf);
	  }
	}
        translate([0,-12,-hm+w]) rotate( [30,0,0]) translate([0,0,hm/2+0.5]) cylinder(r=rbo, h=h2+hm/4,$fn=nf);
      }
      translate([0,-12,-hm+w]) rotate( [30,0,0]) translate([0,0,hm/2+0.5-1]) cylinder(r=rbi, h=h2+hm/2+2,$fn=nf);
    }
}


//------------- Instances --------------------

//gardena_half();
hose_branch();
