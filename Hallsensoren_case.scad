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
// Andreas Merz 2019-01-12, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses


// import dovetail and mounting plate definitions
use <raspi_RJ45fix.scad>

xbrd=14; // board width
zbrd=30; // board length
dbrd=1;  // board thickness
yinn=15;
wall=0.8;

//-------------------------------------------
// enclosure for Hallsensor board and wire
//-------------------------------------------
// Die Bauhoehe samt 
module sensorcase2Dhalf() {
    w=wall;      // w: wall thickness
    c=0.0;       // clearance between ridges
    x=xbrd/2;    // half board width
    y=yinn;      // inner y dimension
    d=dbrd;      // board thickness
    xc=w/2;
    xf=5/2;
    xi=x-2;
    yf=xf+sqrt((2*xf-w)*w)-0.3;
    yi=11;
    yj=yi+d;
    yc=y-w/2;
    // inner contour
    polygon( points=[[0,0],
       // Kabelhalterung
       [xf,0], [xf,yf],[xf-w,yf],[xf-w,yf+w],[xf+w,yf+w],[xf+w,0],
       [x,0],
       // Platinenhalterung
       [x,yi-w],[xi,yi-w],[xi,yi],[x,yi],
       [x,yj],[xi,yj],[xi,yj+w],[x,yj+w],
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
    w=wall;        // w: wall thickness
    hb=1.0;        // bottom
    yc=2.0;        // sensor space depth
    h=30+hb+yc+10; // overall height, including bottom wall
    x=xbrd/2;      // half board width
    y=yinn;        // inner y dimension

    union() {
        //linear_extrude(height = hb) hull() { sensorcase2D(); };  // bottom
        linear_extrude(height = h) 
          sensorcase2D();
        linear_extrude(height = yc)
          polygon( points=[[-x,y-yc],[x,y-yc],[x,y-yc-3],[-x,y-yc-3]]);
  
    }
}




//------------- Instances --------------------

//translate([30, 40,0]) connectionH(h=40, l=30);
sensorcase();
