// Raspberry Pi fixture for 3D printing, modular system
// 
// Attach to the RJ45 case, if using Raspi's mounting holes is not an option.
// 
// Background:
//   - The Pi1 version is designed to fit also the Pi2
//   - The Pi2 version has an additional screw hole but 
//     then it will not fit on the Pi1
//   - Pi3 not considered yet
//   - select the desired instances at the bottom of this file
//     and use openscad to generate according STL files.
//   - the dovetail connection plates fit also to a 35mm DIN-rail
//     and may be combined in various ways
//   - future ideas: make longsides of wallmount a dovetail snap-on
//   - repository: https://github.com/Github6am/am_parts3D
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-01-12, v0.8 
// GPLv3 or later, see http://www.gnu.org/licenses

// general purpose
function ellipse(r1, r2, num=32) = 
  [for (i=[0:num-1], a=i*360/num) [ r1*cos(a), r2*sin(a) ]];


//-------------------------------
// dovetail
//
//       w2
//    ---------
//    \       /  h
//     ---+---
//       w1
//-------------------------------

module schwalbenschwanz(h=2, w1=4, w2=6) {
             //w1=(w2-h*tan(30));      // Flankenwinkel 30 deg
             c=0.17;   // clearance / spiel in mm
             polygon(points=[[-w1/2+c,0],[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h]]);
}

module neg_schwalbenschwanz(h=2, w1=4, w2=6, b=5) {
             c=0.17;   // clearance / spiel in mm
             polygon(points=[[w1/2-c,0],[w2/2-c,h],[-w2/2+c,h],[-w1/2+c,0],
             [-w2/2+c-h,-h],[-w2/2+c-b,-h],[-w2/2+c-b,b+h],[w2/2-c+b,b+h],[w2/2-c+b,-h],[w2/2-c+h,-h]]);
}

//-------------------------------------------
// enclosure to attach to the RJ45 jack
//-------------------------------------------
module rj45case(w=2.0, PiVersion=1) {
    // w: wall thickness
    // wb: bottom wall
    // PiVersion:  Raspberry Pi version
    c=0.05;      // clearance - spiel in mm im Gehaeuse
    b=2.8-w;     // board edge excess, Pi2 has 3mm from RJ45 to board edge
    wb=2.5;      // bottom 
    h=14+wb;     // overall height, including bottom wall
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[16+2*w+b,0],[16+2*w+b,21.5+2*w],[0,21.5+2*w]]);  // outer rectangle
              polygon( points=[[w-c,w-c],[16+w+c,w-c],[16+w+c,21.5+w+c],[w-c,21.5+w+c]]);          // inner rectangle
            }
            if (PiVersion >= 2) {
              // Raspberry Pi 2 only: add Screw fixture
              translate([16+2*w-6.5,21.5+2*w,0]) square([6.5+b, 5]);
            }
            // right interface
            translate([16+2*w+b,8,0])    rotate(-90) schwalbenschwanz();
            translate([16+2*w+b,10+8,0]) rotate(-90) schwalbenschwanz();
            // left interface
            translate([0,0*10+3,0]) rotate(90) schwalbenschwanz();
            translate([0,1*10+3,0]) rotate(90) schwalbenschwanz();
            translate([0,2*10+3,0]) rotate(90) schwalbenschwanz();
          }
        linear_extrude(height = wb)       // bottom plate
          polygon( points=[[0,0],[16+2*w,0],[16+2*w,21.5+2*w],[0,21.5+2*w]]);     
      }
      union() {
          translate([w+1.5,-1,2+wb])
            linear_extrude(height = h)    // RJ45 breakout
              square( [13, 6]);
          translate([w+1.5,21.5-1+w,h-2.5])
            linear_extrude(height = h)    // breakout for SMD parts 
              square( [13, 4]);
          translate([-3,-1, h-2.5])
            linear_extrude(height = h)    // breakout for SMD capacitor in Pi2 
              square( [3+w-2, 28]);
          translate([-3,-1+19, h-2.5])
            linear_extrude(height = h)    // breakout for SMD capacitor in Pi3 
              square( [3+w-1.5, 10]);
          translate([-3,0, -1])
            linear_extrude(height = h+2)  // cut schwalbenschwanz for Pi2 USB jack
              square( [3+w-2, w+1]);
          translate([14.8+w,21.5+w+4.3,0])
            linear_extrude(height = h+1)  // hole for mounting screw
              circle(1.2, $fn=4);
          translate([w+16/2,w+21.5/2,-1])
            linear_extrude(height = h+1)  // save material in bottom
              square([2*(w+16/2-5),2*(w+21.5/2-6)],center=true);
      }
    }
}


//-------------------------------------------
// wall mount fixture
//-------------------------------------------
module wallmount(h=16.5, w=2.5, l=50) {
    // h: overall height, including bottom wall
    // w: wall thickness
    // l: length to mount point - depending on connectors and cable bend radius
    // wb: bottom wall
    wb=2.5;     // bottom thickness
    ws=6;       // side wall
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[l,0],[l,30],[0,30]]);  // outer rectangle
              polygon( points=[[w,w],[l-w,w],[l-w,30-w],[w,30-w]]);  // inner rectangle
            }
            // left interface
            translate([0,0*10+5,0]) rotate(90) schwalbenschwanz();
            translate([0,1*10+5,0]) rotate(90) schwalbenschwanz();
            translate([0,2*10+5,0]) rotate(90) schwalbenschwanz();
            // right interface
            translate([l,0*10+0,0]) rotate(-90) schwalbenschwanz();
            translate([l,1*10+0,0]) rotate(-90) schwalbenschwanz();
            translate([l,2*10+0,0]) rotate(-90) schwalbenschwanz();
            translate([l,3*10+0,0]) rotate(-90) schwalbenschwanz();
          }
          linear_extrude(height = wb)    // bottom plate
            polygon( points=[[0,0],[l,0],[l,30],[0,30]]);  // outer rectangle
      }
      union() {
          translate([l/2,-1,ws])
            linear_extrude(height = h-ws+1, scale=1.5)    // save material in longside wall
              square( [(l-2*w)/1.5, 2*30+2*w], center=true);
          translate([l/2,30/2,-1])
            linear_extrude(height = h+1)     // save material in bottom
              //polygon(ellipse(l*0.4,30*1/3));
              square([2*(l/2-7), 2*(30/2-6)], center=true);
          translate([l-10,30*3/4,h/2])       // mounting hole 4mm
            rotate([0,90,0])
              linear_extrude(height = 20)
                circle(4/2,$fn=32);
          translate([l-10,30*1/4,h/2])       // mounting hole 4mm
            rotate([0,90,0])
              linear_extrude(height = 20)
                circle(4/2,$fn=32);
          translate([l-1,-4,-1])
            linear_extrude(height = h+2)    // cut excess dovetails
              square( [4,4]);
          translate([l-1,30,-1])
            linear_extrude(height = h+2)    // cut excess dovetails
              square( [4,4]);
      }
    }
  }

module wallmount1(h=16.5+6.5, w=2.5, l=50) {
  difference() {
    union() {
      wallmount(h=h, w=w, l=l);
        translate([0,     0,0]) linear_extrude(height = w) square( [16.5,30]);
        translate([l-16.5,0,0]) linear_extrude(height = w) square( [16.5,30]);
    }
    union() {
         translate([l-8.25,30*3/4,-5])       // mounting hole 4mm
             linear_extrude(height = 20)
               circle(4/2,$fn=32);
         translate([l-8.25,30*1/4,-5])       // mounting hole 4mm
             linear_extrude(height = 20)
               circle(4/2,$fn=32);
         translate([  8.25,30*3/4,-5])       // mounting hole 4mm
             linear_extrude(height = 20)
               circle(4/2,$fn=32);
         translate([  8.25,30*1/4,-5])       // mounting hole 4mm
             linear_extrude(height = 20)
               circle(4/2,$fn=32);
    }
  }   
}

module wallmount2(h=23, w=2.5, l=50) {
  difference() {
      wallmount1(h=h, w=w, l=l);
      translate([-3, -1,-1]) linear_extrude(height = h+2) square( [l+3.5-16.5,32]);
    }
}

//-------------------------------------------
// connection plate for general purpose
//-------------------------------------------
module connection(h=32, w=4, l=60) {
    // h: overall height
    // w: wall thickness
    // l: length to mount point
    difference() {
      union() {
        linear_extrude(height = h)
          difference() {
            union() {
              square([w,l]);
              for (i = [0 : l/10 - 1]) {
              // left interface
              translate([0, i*10+2.5, 0]) rotate( 90) schwalbenschwanz();
              // right interface
              translate([w, i*10+7.5, 0]) rotate(-90) schwalbenschwanz();
              }
            }

            // make ends a dovetail too for 90 deg connection
            union() {
              translate ([1, 2, 0]) rotate( 180)
                neg_schwalbenschwanz();
              translate ([3, l-2, 0]) rotate( 0)
                neg_schwalbenschwanz();
            }
          }
      }
      // make long sides a dovetail too for 90 deg connection
      // additional benefit: avoid inaccuacies from the bottom layers.
      union() {
        translate ([2, l+1, h-2]) rotate([ 90, 0, 0])
          linear_extrude(height = l+2)
             neg_schwalbenschwanz();
        translate ([2, -1, 2]) rotate([ -90, 0, 0])
          linear_extrude(height = l+2)
             neg_schwalbenschwanz();
        
      }
  }
}

// horizontal print
module connectionH(h=60, w=1.5, l=30, holes=true) {
    // h: overall height
    // w: wall thickness
    // l: length 
    difference() {
      union() {
        rotate([0,-90,0])
        union() {
          linear_extrude(height = h)
              union() {
                square([w,l]);
                for (i = [0 : l/10 - 1]) {
                  // right interface
                  translate([w, i*10+5, 0]) rotate(-90) schwalbenschwanz();
                }
              }
        }
        // place tabs at the corners to prevent bending and rip-off
        linear_extrude(height = 0.4)
          translate([0,0])
             circle(8/2,$fn=32);
        linear_extrude(height = 0.4)
          translate([0,l])
             circle(8/2,$fn=32);
        linear_extrude(height = 0.4)
          translate([-h,l])
             circle(8/2,$fn=32);
        linear_extrude(height = 0.4)
          translate([-h,0])
             circle(8/2,$fn=32);
        
      }
      union() {
        if(holes==true) {
          for (ix = [0 : h/20]) {          // mounting hole grid 
            for (iy = [0 : l/20]) {        // mounting hole grid 
              union() {
                translate([ix*20-h+10,iy*20+5,-0.1])          // hole - Bohrloch
                  linear_extrude(height = w+2)
                    circle(2.2/2,$fn=32);
                translate([ix*20-h+10,iy*20+5,2.0])
                  linear_extrude(height = w+0.1, scale=2.9)   // cone - Senkung
                    circle(2.2/2,$fn=32);
              }
            }
          }  
        }
      }
    }
}


//--------------------------------------------------
// 35mm DIN-Rail adapter, if snap-on is needed
//--------------------------------------------------
// thanks to Robert Hunt https://www.thingiverse.com/thing:101024
// for din_clip_01.dxf released under 
// https://creativecommons.org/licenses/by/3.0/
//
module connectionDIN(h=10.0, y=5) {              // Hutschienenadapter
  //y:  shift of dovetail pattern in y-direction
  linear_extrude(height = h)
      union() {
        difference() {
          import("din_clip_01.dxf");
          translate([-10,0,0]) square([10,10]);
          }
        // left interface
        translate([0.2,0*10+y,0]) rotate(90) schwalbenschwanz();
        translate([0.2,1*10+y,0]) rotate(90) schwalbenschwanz();
        translate([0.2,2*10+y,0]) rotate(90) schwalbenschwanz();
        translate([0.2,3*10+y,0]) rotate(90) schwalbenschwanz();
        translate([0.2,4*10+y,0]) rotate(90) schwalbenschwanz();

        translate([0*10+3,50-0.2,0]) rotate(0) schwalbenschwanz();
        translate([1*10+3,50-0.2,0]) rotate(0) schwalbenschwanz();
        
        // screwdriver hook for removal
        translate([13.4,0.2,0]) polygon([[2.5,0],[2.5,-1.2],[0,-1.7],[0,-1.5],[0,-3],[3,-3],[6,0]]);
      }
}


//-------------------------------------------
// enclosure for uBlox GPS module
//-------------------------------------------
module uBloxcase(w=1.0) {
    // w: wall thickness
    c=0.0;     // clearance between ridges
    b=25.8;        // board with
    a=15;        // board thickness with all parts plus space above antenna
    wrl=0.8-c;   // left ridge height
    hb=1.0;      // bottom
    hc=15;       // height of cable fix
    h=37+hb+3;     // overall height, including bottom wall
    difference() {
      union() {
        linear_extrude(height = h)    // box walls
          union() {
            difference() {
              polygon( points=[[0,0],[a+2*w,0],[a+2*w,b+2*w],[0,b+2*w]]);  // outer rectangle
              polygon( points=[[w,w],[a+w,w],[a+w,b+w],[w,b+w]]);          // inner rectangle
            }
            translate([0,w+7,0]) square([w+wrl, w]);  // left ridge
            translate([0,b-7,0]) square([w+wrl, w]);  // left ridge 
            translate([w+wrl+8.4+c,w,0]) square([w, 1.6]);  // right ridge holding antenna down
            translate([w+wrl+8.4+c,b,0]) square([w, 1.6]);  // right ridge holding antenna down 
            // right interface
            //translate([a+2*w,0*10+9,0]) rotate(-90) schwalbenschwanz();
            //translate([a+2*w,1*10+9,0]) rotate(-90) schwalbenschwanz();
            // left interface
            translate([0,0*10+4,0]) rotate(90) schwalbenschwanz();
            //translate([0,1*10+4,0]) rotate(90) schwalbenschwanz();
            translate([0,2*10+4,0]) rotate(90) schwalbenschwanz();
            // bottom interface
            translate([(a+w)/2,0,0]) rotate(180) schwalbenschwanz();
            // top interface
            translate([(a+w)/2,b+2*w,h]) rotate(  0) schwalbenschwanz();
          }
        linear_extrude(height = hb)       // bottom plate
          polygon( points=[[0,0],[a+2*w,0],[a+2*w,b+2*w],[0,b+2*w]]);     
      }
      
      union() {
          translate([0,b/2+w,h-3])    // breakout for cable 
            linear_extrude(height = h) 
              square( [5, 10], center=true);
      }
    }
}

module cableClipA(w=1.0, h=10, l=29) {
    // w: wall thickness
    linear_extrude(height = h)
      difference() {
        union() {
          translate([0,30/2-l/2]) square([w,l]);
          // right interface
          translate([w,0*10-0,0]) rotate(-90) schwalbenschwanz();
          translate([w,1*10-0,0]) rotate(-90) schwalbenschwanz();
          translate([w,2*10-0,0]) rotate(-90) schwalbenschwanz();
          translate([w,3*10-0,0]) rotate(-90) schwalbenschwanz();
          // left interface
          translate([0,0*10+5,0]) rotate(90) schwalbenschwanz();
          translate([0,2*10+5,0]) rotate(90) schwalbenschwanz();
        }
        union() {
            translate([w+2,-5+(30-l)/2,0])    // cut at end
                square( [4,10], center=true);
            translate([w+2,15,0])    // breakout for cable 
                square( [4, 8], center=true);
            translate([w+2,35-(30-l)/2,0])    // cut at end
                square( [4,10], center=true);
        }
      }
}

// Mounting pins
module clipB(h=4, shape=3) {
    // h: overall height
    opt_slot  =(shape%2 >=1); // bit 0: screwdriver slot at bottom
    opt_shave =(shape%4 >=2); // bit 1: narrow in x-direction
    opt_recb  =(shape%8 >=4); // bit 2: square shape bottom
    opt_rect  =(shape%16>=8); // bit 3: square shape top
    c=0.1;                   // clearance
    difference() {
      union() {
        translate([0 ,0, 0])              // bottom cone
          if( opt_recb ) {
            linear_extrude(height = (h-c)/2, scale=(4-c)/(6-c))
               circle((6*sqrt(2)-c)/2,$fn=4);
          } else {
            linear_extrude(height = (h-c)/2, scale=(4-c)/(6-c))
               circle((6-c)/2,$fn=32);
          }
        translate([0 ,0, 1])              // spacer 
          linear_extrude(height = 2)
             circle(4/2,$fn=32);
        translate([0 ,0, 2-c])            // top cone
          if( opt_rect ) {
            linear_extrude(height = (h-c)/2, scale=(6-c)/(4-c))
               circle((4*sqrt(2)-c)/2,$fn=4);
          } else {
            linear_extrude(height = (h-c)/2, scale=(6-c)/(4-c))
               circle((4-c)/2,$fn=32);
          }
      }
      union() {
        if( opt_shave) {
        translate([-4.15 ,0, 2])            // right shave
          linear_extrude(height = 3)
             square([4,6], center=true);
        translate([4.15 ,0, 2])            // left shave
          linear_extrude(height = 3)
             square([4,6], center=true);
        }
        if( opt_slot) {
          translate([0 ,0, 0])              // screwdriver slot
            linear_extrude(height = 1.5, scale=0.8)
               square([1,3.5], center=true);
        }
      }
    }
}


//------------- Instances --------------------
translate([0,0,0]) connectionDIN();


/*
translate([-26,0,0]) rj45case(PiVersion=3);

translate([-82,0,0]) wallmount2();
*/



/*
wallmount();

translate([60,0,0]) connection();

translate([  0,-36,0]) uBloxcase();
translate([-10,-36,0]) cableClipA();


translate([30, 40,0]) connectionH(h=60, l=30);

// print all the small clipB parts close together to avoid rip-off
if(true) {
  translate([-30, -15,0])
    union() {
      translate(6*[ 1,  1, 0]) rotate(45) clipB(shape=13);
      translate(6*[ 1,  0, 0]) rotate(90) clipB();
      translate(6*[ 1, -1, 0]) rotate(45) clipB(shape=13);

      translate(6*[ 0,  1, 0]) clipB(shape=1);
      translate(6*[ 0,  0, 0]) clipB();
      translate(6*[ 0, -1, 0]) clipB(shape=1);

      translate(6*[-1, -1, 0]) rotate(45) clipB(shape=7);
      translate(6*[-1,  0, 0]) rotate(45) clipB(shape=8);
      translate(6*[-1,  1, 0]) rotate(45) clipB(shape=7);

      translate(6*[-2, -1raspi_RJ45fix.scad, 0]) rotate(45) clipB(shape=11);
      translate(6*[-2,  0, 0]) rotate(45) clipB(shape=5);
      translate(6*[-2,  1, 0]) rotate(45) clipB(shape=9);

    }
  }

translate([ 30, -60, 0]) connectionDIN();
*/
