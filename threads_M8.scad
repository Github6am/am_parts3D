// M8 Schraube und Mutter, Sechskant
//
// rendering takes some time
//
// Beobachtung unter dem Mikroskop:
// - das Bolzengewinde ist saegezahnfoermig verformt, es sieht aus
// wie ein Tannenbaum, der auf dem Kopf steht.
// - Das Gewinde der Mutter ist zu eng, vermutlich sind die Gewindegaenge
// nicht tief genug geschnitten. Auch ueber eine heisse Eisenschraube
// kann es nicht optimal ausgeformt werden, so dass bislang nur
// ein Nachschneiden mit dem Gewindebohrer half.
// Das Aendern der Aufloesung von 0.2 auf 0.1mm hat die Probleme nicht geloest.
// Vermutete Ursache: das Filament nimmt in der Kurve immer eine kleine Abkuerzung.
// Vermutlich ist der Effekt umso staerker, je kleiner das Gewinde ist.
// Moegliche Abhilfe:
//  - Kompensation durch Saegezahn-Vorverzerrung, kommt es auf die Slicer-Richtung an?
//  - keine Radien an den Gewindespitzen im CAD-Modell, die kommen beim Drucken von selbst
//  - mehr Spiel vorsehen.
// Weitere Verbesserungen:
//  - Fasen/lead-in an die Gewindeenden.
// 
// Andreas Merz 19.12.2018, v0.3 


// http://dkprojects.net/openscad-threads/
use <threads.scad>

// Polygon vertices
function ngon(num, r) = 
  [for (i=[0:num-1], a=i*360/num) [ r*cos(a), r*sin(a) ]];


// 30 deg anfasen - chamfer
module fase() {
  difference() {
    linear_extrude(height = 2, scale = 1)    // cylinder
      circle(8.66);
    linear_extrude(height = 5, scale = 0)    // cone
      circle(8.66);
  }
}  

//----------------------------------- 
// Schraube - screw
//----------------------------------- 
module M8screw( len=12, head=3 ) {
  difference() {
    union() {
      linear_extrude(height = head)
        polygon(ngon(6, 13/2/cos(30)));   // Sechskantkopf, Gabelschluessel 13mm / cos(30deg)                         

      translate([0,0,2])
        metric_thread (diameter=8, pitch=1.25, n_starts=1, length=len);
    }
    union() {
      translate([0,0,1.7])
        fase();
      translate([0,0,1.3])
        mirror([0,0,1])
          fase();
    }
  }
}

//----------------------------------- 
// Mutter - nut
//----------------------------------- 
// 
module M8nut( len=5 ) {
  difference() {
    difference() {
      linear_extrude(height = len)
        polygon(ngon(6, 13/2/cos(30)));   // Gabelschluessel 13mm                       

      translate([0,0,-1])
        metric_thread (diameter=8, pitch=1.25, n_starts=1, internal=0, length=7);
    }  
    union() {
      translate([0,0,3.7])
        fase();
      translate([0,0,1.3])
        mirror([0,0,1])
          fase();
    }
  }
}

//----------------------------------- 
// Instances
//----------------------------------- 
//translate([-30,-30,0])
translate([0,8.5,0]) M8nut();

translate([0,-8.5,0]) M8screw();

