// Simple horizontal bearing for a Filament Coil
//
// print 2 cone instances and stack them.
// or print spokewheels to put reels in a box
//
// Andreas Merz 21.12.2018, v0.5, GPL



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

module inset(diabore=10, h=7, hrim=2) {
  c=0.3;
  difference() {
    union() {
      linear_extrude(height = hrim)    // rim
        circle((diabore+1-c)/2, $fn = 90);
      linear_extrude(height = h)    //  
        circle((diabore-c)/2, $fn = 90);
    }
    translate([0,0,-1])
      linear_extrude(height = h+4)    // bore hole
        circle(diabore/4, $fn = 90);  // 5mm center hole
    
  }
}


//-------------------------------------
// Laufrolle fuer Kirchenweg Glashaus
//-------------------------------------
module rolle(di=10) {
         c=0.4;
         rotate_extrude($fn = 80)
           translate([(di+c)/2, 0, 0])
             difference() {
               polygon( [[(22-(di+c))/2,   9-c], [(1+c)/2,9-c], [(1+c)/2,7-c], [0,7-c], [0,0], [(22-(di+c))/2,0]]);
               //square( [(22-(di+c))/2,   9-c]);
               translate([(22-(di+c)+1)/2, (9-c)/2]) circle(r=5/2);
             }
}

//-------------------------------------
// Filament Clip
//-------------------------------------
module filamentclip(di=9) {
         c=0.2;
         d=1.75;  // filament diameter
         union() {
           translate([ 0, 0, 1]) cube([10,20,2], center=true);
           translate([ 0, -2*(2+d-c),2])   linear_extrude(height=10, scale=[1, 0.8]) square([10,2], center=true);
           translate([ 0, -1*(2+d-c),2])   linear_extrude(height=10, scale=[1, 0.8]) square([10,2], center=true);
           translate([ 0,  0*(2+d-c),2])   linear_extrude(height=10, scale=[1, 0.8]) square([10,2], center=true);
           translate([ 0,  1*(2+d-c),2])   linear_extrude(height=10, scale=[1, 0.8]) square([10,2], center=true);
           translate([ 0,  2*(2+d-c),2])   linear_extrude(height=10, scale=[1, 0.8]) square([10,2], center=true);
    }
}


//------------- Instances --------------------


//cone();
//spokewheelB();
//spokewheelB(dia=53);

//translate([12,12,0]) inset();
//translate([12,-12,0]) inset(h=21, hrim=14);  // extended inset
//translate([-12,-12,0]) axeB();


translate([12,0,0]) inset(h=9.3);
//rolle();


translate([-0*12,0,0]) filamentclip();
translate([-1*12,0,0]) filamentclip();
translate([-2*12,0,0]) filamentclip();
