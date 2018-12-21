// Simple horizontal bearing for a Filament Coil
//
// print 2 cone instances and stack them.
//
// Andreas Merz 21.12.2018, v0.2, GPL



module cone(dia=53, h=68) {
  difference() {
    union() {
      translate([0,0,1])
        linear_extrude(height = h*10/11-2, scale = 0.015)    // base cone
          circle(dia/2, $fn = 90);
      translate([0,0,2])
        linear_extrude(height = h-2, scale = 0.015)  // tip cone
          circle(dia/3, $fn = 90);
      linear_extrude(height = 2, scale = 1)      // rim
        circle(dia/2 +3, $fn = 90 );
      }
    translate([0,0,-0.1])
      linear_extrude(height = h*10/11-2, scale = 0.015)    // cone boring
        circle(dia/2, $fn = 90);
  }
}  

cone();
