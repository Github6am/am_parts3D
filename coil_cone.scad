// Simple horizontal bearing for a Filament Coil
//
// print 2 cone instances and stack them.
//
// Andreas Merz 21.12.2018, v0.4, GPL



module cone(dia=53, h=68) {
  difference() {
    union() {
      translate([0,0,1])
        linear_extrude(height = h*10/11-2, scale = 0.025)    // base cone
          circle(dia/2, $fn = 90);
      translate([0,0,2])
        linear_extrude(height = h-2, scale = 0.02)  // tip cone
          circle(dia/3, $fn = 90);
      linear_extrude(height = 2, scale = 1)      // rim
        circle(dia/2 +3, $fn = 90 );
      }
    translate([0,0,-0.1])
      linear_extrude(height = h*10/11-2, scale = 0.02)    // cone boring
        circle(dia/2, $fn = 90);
  }
}  

module spokewheel(dia=58, h=2) {
  difference() {
    union() {
      rotate_extrude($fn = 80)
        translate([dia/2-3, 0, 0])  // inner rim 
             polygon( points=[[0,0],[2.8,0],[3,3],[8,4],[8,5],[0,5]] );
      
      linear_extrude(height = 5)    // spoke
             polygon( points=[[dia/2,-2.5],[dia/2,2.5],[-dia/2,2.5],[-dia/2,-2.5]]);
      linear_extrude(height = 5)    // spoke
             polygon( points=[[-2.5,dia/2],[2.5,dia/2],[2.5,-dia/2],[-2.5,-dia/2]]);
      
      linear_extrude(height = 5)    // hub 
          circle(7, $fn = 90);
      linear_extrude(height = 7)    // spacer 
          circle(4, $fn = 90);
    }
    translate([0,0,-1])
      linear_extrude(height = 9)    // bore hole
        circle(2.5, $fn = 90);
  }
}
    
module axe(d=5, h=2) {
    union() {
      linear_extrude(height = 2.5)    //  
        circle(d/2-0.2, $fn = 90);
      translate([0,0,2.5])
          linear_extrude(height = 1)    // rim
            circle((d+1)/2, $fn = 90);
      translate([0,0,2.5])
          linear_extrude(height = 7, scale=0.1)    // tip
            circle(d/2, $fn = 90);
  }
}

//cone();
spokewheel();

//translate([10,10,0]) axe();
