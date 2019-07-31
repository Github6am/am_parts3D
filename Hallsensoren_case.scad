// Gehause fuer Hallsensoren des Ankerkettenzaehlers
// 
// 
// Background:
//   - siehe auch Hallsensoren_brd.pdf
//   - Der Sensor wird ueber ein Kabel mit dem 
//     Ankerkettenzaehler von Thomas Gerner verbunden
//   - Am Winschgehaeuse wird eine Montageplatte angeklebt,
//     und das Sensorgehaeuse daraufgeschoben. Die Bauhoehe
//     der Montageplatte plus Sensor darf 25mm nicht ueberschreiten,
//     aber auch nicht wesentlich darunter liegen, damit der Abstand
//     zu den Magneten klein bleibt.
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
//   - offene Fragen:
//     - wieviel Hoehe braucht der Kleber? derzeit Gesamthoehe 24mm
//     - Schrumpfschlauch auf Kabel ? oder anderer Knickschutz?
//     - board Masse?
//     - Sollen die Sensoren grob in der Board-Flucht liegen oder Z-foermig?
//       ersteres fuehrt zu einem laengeren Gehaeuse.
//
// Andreas Merz 2019-07-20, v0.2 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

// Main dimensions
xbrd=13;       // board width
zbrd=20+8.5;   // board length: 20, Sensors: 8.5
dbrd=1.7;      // board thickness
yout=24-3.5;   // sensor space - mounting plate thickness
wall=0.8;      // wall thickness

//-------------------------------------------
// enclosure for Hallsensor board and wire
//-------------------------------------------
// Die Bauhoehe samt 
module sensorcase2Dhalf() {
    w=wall;      // w: wall thickness
    u=0;         // excess wall thickness at lower part of the case, optional
    c=0.1;       // clearance between ridges
    x=xbrd/2;    // half board width
    y=yout-2*w;  // inner y dimension
    d=dbrd;      // board thickness
    xc=w/2;      // half width of top center ridge
    xf=5/2+c;    // half distance of cable clamp ridges
    xi=x-1.4;    // inset of board fixture
    yf=xf+sqrt((2*xf-w)*w)-0.3+u;  // cable clamp ridge hook
    yk=y-2;      // board 2mm from top
    yj=yk-d-w-c;
    yi=yj-d-w-c;
    yh=yi-d-w-c;
    yc=y-w/2;
    // inner contour
    polygon( points=[[0,u],
       // Kabelhalterung
       [xf,u], [xf,yf],[xf-w,yf],[xf-w,yf+w],[xf+w,yf+w],[xf+w,u],
       [x-u,u],
       // Platinenhalterung
       [x-u,yh],[xi,yh],[xi,yh+w],[x,yh+w],
       [x,yi],  [xi,yi],[xi,yi+w],[x,yi+w],
       [x,yj],  [xi,yj],[xi,yj+w],[x,yj+w],
       [x,yk],  [xi,yk],[xi,yk+w],[x,yk+w],
       // abgeschraegte Ecke
       [x,y-w*1.4],[x-w*1.4,y],
       // Mittelsteg
       [xc,y],[xc,yc],[0,yc],
       // outer contour
       [0,y+w],[x-w,y+w], [x+w,y-w],[x+w,-w],[0,-w]]); // outer contour

}

module sensorcase2D() {
          union() {
             sensorcase2Dhalf();
             mirror() sensorcase2Dhalf();
          }
}

module sensorcase() {
    w=wall;             // w: wall thickness
    hb=1.0;             // bottom
    hc=4.5+hb;          // sensor space depth
    yc=1.7;             // sensor space height
    h=zbrd+hb+2.5;  // overall height, including bottom wall
    x=xbrd/2;           // half board width
    y=yout-2*w;         // inner y dimension

    difference() {
      union() {
          linear_extrude(height = hb) hull() { sensorcase2D(); };  // bottom
          linear_extrude(height = h) 
            sensorcase2D();
          linear_extrude(height = hc)   // sensor support
            polygon( points=[[-x,y-yc],[x,y-yc],[x,y-yc-2-w],[-x,y-yc-2-w]]);
          linear_extrude(height = h)
             translate([ 5,-w,0]) rotate(180) schwalbenschwanz();
          linear_extrude(height = h)
             translate([-5,-w,0]) rotate(180) schwalbenschwanz();
      }
      // avoid broadening of dovetail at the bottom by cutting 45deg
      translate([-(x+2), 0, -w]) rotate([180-45, 0 ,0])  cube([2*(x+2), 5, 5]);
    }
}

module sensorcap() {
    difference() {
        linear_extrude(height = 2.8) hull() { sensorcase2D(); };  // cap
        union() {
          translate([0, 0, 1]) linear_extrude(height = 2) 
            minkowski() { 
              sensorcase2D();
              square([0.15,0.5], center=true);
            }
          translate([0, 2.5, -1]) linear_extrude(height = 4) circle(5.5/2,$fn=32);
          translate([0, 2.5,  1]) linear_extrude(height = 4) circle(7/2,$fn=32);
        }
    }  
}


//------------- Instances --------------------

translate([0,0,0]) connectionH(h=40, l=30, holes=false);
//sensorcase();
//sensorcap();
