// mounting aids for scubajet dive scooter
// 
// Background:
//   - https://www.scubajet.com/

//   - my printer settings: layer height 0.15mm, infill 33%
//
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Author: Andreas Merz, 2023-04-09
//  GPLv3 or later, see http://www.gnu.org/licenses 

// see header of this file, when using the libraries, referenced here:
use <plumbing.scad> 

sj_do       = 80;    // scubajet outer diameter
sj_mount_x  = 16;    // mounting rail width
sj_mount_y  = 5.5;   // mounting rail height
sj_ridge_x  = 4.0;   // mounting rail ridge depth
sj_ridge_y1 = 2.2;   // mounting rail ridge start
sj_ridge_y2 = 2.2;   // mounting rail ridge height



// basic scubajet cross section

module sj_shape_2D(
     dd      = sj_do,       // diameter
     mnt_x   = sj_mount_x,
     mnt_y   = sj_mount_y,
     mnt_n   = 2            // number of mounting rails
     ) {
         union() {
           circle(d=dd, $fn=90);
           
           // mounting rail cutout
           for (i = [0 : mnt_n]) {
             rotate([0,0,i*360/mnt_n]) translate([0,(mnt_y + dd/2)/2])  square([mnt_x, mnt_y + dd/2], center=true);
           }
         }
}

module sj_fixture(
     dd      = sj_do,       // diameter
     ww      = 4,           // wall thickness
     c       = 0.4,         // clearance
     z       = 14,           // height/thickness of fixture
     mnt_x   = sj_mount_x,
     mnt_y   = sj_mount_y,
     mnt_n   = 2            // number of mounting rails
     ) {
         linear_extrude( height = z)
         difference() {
           offset(r=-ww, $fn=45)         
           sj_shape_2D( dd = dd + 2*ww +ww, mnt_x = mnt_x + 2*ww +ww, mnt_y = mnt_y , mnt_n = mnt_n);
           sj_shape_2D( dd = dd + 0*ww +c,  mnt_x = mnt_x + 0*ww +c,  mnt_y = mnt_y , mnt_n = mnt_n);
         }
}

// --- test components

//sj_shape_2D();
sj_fixture();

//polygon(  G1_thread_profile());
//G1_thread();
//G1_thread_nut();
//adapter_clip();

//adapterA_G1();


//---------------- Instances ---------------------


