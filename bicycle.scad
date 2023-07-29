// Spare parts for bicyles
// 
// 
// Background:
//   - currently only one part
//     replace a nut to cover a worn-out thread at the steering shaft.
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//
// Andreas Merz 2023-07-28, v1.0 
// GPLv3 or later, see http://www.gnu.org/licenses


//-------------------------------------------
// Werkzeuge
//-------------------------------------------

// use <galeb.scad>

// sequence of n conical sections
module conesN(n=3, hh=[0, 1, 8, 10], dd=[5.5, 5.8, 6.2, 5.0], fn=30) {
    for (i = [0 : n-1]) {
      translate([0,0, hh[i]])
        cylinder(d1=dd[i], d2=dd[i+1], h = hh[i+1]-hh[i], $fn=fn);
    }
}

//-----------------------------------------------
// Kontermutter/Ueberwurfmutter fuer Lenkerschaft
//-----------------------------------------------

// thread length 10mm
module lnut() {
  difference() {
    conesN(n=2, hh=[0, 12, 18], dd=[36,   36, 26], fn=12);
    conesN(n=3, hh=[-0.1, 10, 15, 19], dd=[25.8, 25.0, 23, 23], fn=96);
  }
}

// Weil noch ein Einkaufskorb geklemmt wird, kann das Gewinde kuerzer sein:
// thread length 8mm
module lnutA() {
  difference() {
    conesN(n=2, hh=[0, 10, 16], dd=[36,   36, 26], fn=12);
    conesN(n=3, hh=[-0.1, 8, 12, 17], dd=[25.6, 25.0, 23, 23], fn=96);
  }
}



//------------- Instances --------------------

lnut();
