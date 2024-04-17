// tools - stuff for the workshop
//
// Background:
//   - tools_wrench_holder:
//     clip several wrenches together for storage
//   - hosted on:
//     git@github.com:Github6am/am_parts3D.git
//
// Author: Andreas Merz, 2023-07-16
//   GPLv3 or later, see http://www.gnu.org/licenses 


w  =  2.2;    // wall thickness

module shape_2D() {
    include <meander.scad>  // generated genShape2D('meander.scad', 'meander')
}

module wrench_holder() {
  linear_extrude( height = 5)
    minkowski() {
      shape_2D();
      // ellipse 
      scale([1,1.6]) circle(d=w, $fn=14);
    }
}


//------------- Instances --------------------
wrench_holder();

