// Ersatzscharnier fuer ein stylisches Alu-Brillenetui mit Magnetverschluss-Klappdeckel.
// Aus Stabilitaetsgruenden wurde die Aussparung fuer die Feder weggelassen.
//
// Das T-Profil passt genau in das Alu-Profil 
// Das kleine Loch fuer die Achse musste leider nachgebohrt werden.
//
// A. Merz, 2021-12-20, GPL v3



c=0.4;  // clearance - roughly one nozzle width

module scharnierA(
    x1=5-c,
    x2=7.8-c,
    x3=8.8-c,
    y1=4,
    y2=12,
    z1=1.6-c,
    z2=3,
    z3=4
    ) {
	difference() {
	  union() {
            translate([ -x1/2,     0,    0  ]) cube([x1, y2, z2], center=false );
            translate([ -x3/2,    y2,    0  ]) cube([x3, y1, z3], center=false );
            translate([ -x2/2,     0, z2-z1 ]) cube([x2, y2, z1], center=false );
	    translate([ -x3/2, y1+y2, z3/2  ]) rotate([0,90,0]) cylinder(h=x3, d=z3, $fn=24);
	  }
	    translate([ -x3/2-0.1, y1+y2, z3/2  ]) rotate([0,90,0]) cylinder(h=x3+0.2, d=1+c, $fn=24);
	}
}



//------------- Instances --------------------
scharnierA();
