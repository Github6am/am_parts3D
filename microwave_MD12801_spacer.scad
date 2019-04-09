// file: microwave_MD12801_spacer.scad
//
// spare part for MEDION Microwave oven MD12801 
// rotating plate support, 3 instances needed
//
// Caution: PLA parts will not survive the grill function!
//
// Andreas Merz 01.01.2019, v0.2, GPL


module microwave_MD12801_spacer(h=3.8, w=5) {
    // h: height of spacer without center pole
    // w: diameter of center pole
    c=0.15;      // clearance - spiel in mm am oberen Ende
    union() {
      linear_extrude(height = h)    // spacer height
        circle(15/2, $fn=64);
      translate([0,0,h])   
        linear_extrude(height = 3, scale=(1-c/5))    // center pole
          circle(5/2, $fn=32);     
    }
}

//------------- Instances --------------------

microwave_MD12801_spacer(h=5);   // make it a bit higher than the original part
