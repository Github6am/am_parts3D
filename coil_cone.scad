// Simple horizontal bearing for a Filament Coil
//
// print 2 cone instances and stack them.
// or print spokewheels to put reels in a box
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


// This wheel has the rim on top, because of the integrated spacer
    
module spokewheelA(dia=58, h=5, th=3, diabore=5) {
  difference() {
    union() {
      rotate_extrude($fn = 80)
        translate([dia/2-th, 0, 0])  // rim 
             polygon( points=[[0,0],[th-0.2,0],[th,h-2],[th+4,h-1],[th+4,h],[0,h]] );
      
      linear_extrude(height = h)    // spoke x
             polygon( points=[[dia/2-1,-2.5],[dia/2-1,2.5],[-dia/2+1,2.5],[-dia/2+1,-2.5]]);
      linear_extrude(height = h)    // spoke y
             polygon( points=[[-2.5,dia/2-1],[2.5,dia/2-1],[2.5,-dia/2+1],[-2.5,-dia/2+1]]);
      
      linear_extrude(height = h)    // hub 
          circle(th+diabore*0.8, $fn = 90);
      linear_extrude(height = h+2)    // spacer 
          circle(diabore/2+2, $fn = 90);
    }
    translate([0,0,-1])
      linear_extrude(height = h+4)    // bore hole
        circle(diabore/2, $fn = 90);
  }
}


// This wheel has the rim on the bottom which is easier to print, 
// but outer spacer needs to be a separate part
    
module spokewheelB(dia=58, h=5, th=3, diabore=10) {
  difference() {
    union() {
      rotate_extrude($fn = 80)
        translate([dia/2-th, 0, 0])  // rim 
             polygon( points=[[0,0],[th+4,0],[th+4,1],[th,1],[th,h],[0,h]] );
      
      linear_extrude(height = h)    // spoke x
             polygon( points=[[dia/2-1,-2.5],[dia/2-1,2.5],[-dia/2+1,2.5],[-dia/2+1,-2.5]]);
      linear_extrude(height = h)    // spoke y
             polygon( points=[[-2.5,dia/2-1],[2.5,dia/2-1],[2.5,-dia/2+1],[-2.5,-dia/2+1]]);
      
      linear_extrude(height = h)    // hub 
          circle(th+diabore*0.8, $fn = 90);
      //linear_extrude(height = h+2)    // spacer 
          //circle(diabore/2+2, $fn = 90);
    }
    translate([0,0,-1])
      linear_extrude(height = h+4)    // bore hole
        circle(diabore/2, $fn = 90);
  }
}
    
    
    
module axeA(d=5, h=2) {
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

module axeB(diabore=10, h=3) {
    union() {
      linear_extrude(height = h)    //  
        circle(diabore/2-0.1, $fn = 90);
      translate([0,0,h])
          linear_extrude(height = 1)    // rim
            circle((diabore+1)/2, $fn = 90);
      translate([0,0,3+1])
          linear_extrude(height = 2*h, scale=0.1)    // tip
            circle(diabore/4, $fn = 90);
  }
}

module inset(diabore=10, h=7) {
  difference() {
    union() {
      linear_extrude(height = 2)    // rim
        circle((diabore+1)/2, $fn = 90);
      linear_extrude(height = h)    //  
        circle(diabore/2-0.12, $fn = 90);
    }
    translate([0,0,-1])
      linear_extrude(height = h+4)    // bore hole
        circle(diabore/4, $fn = 90);  // 5mm center hole
    
  }
}

//------------- Instances --------------------

//cone();
//spokewheelB();
spokewheelB(dia=53);

translate([12,12,0]) inset();
translate([-12,-12,0]) axeB();

// extended inset
translate([12,-12,0]) 
  union() {
    translate([0,0,12]) 
      inset();
    inset(h=13);
  }

