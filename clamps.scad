// clamps for various purposes
//
//
// Background:
//   - Greenhouse clamp - Weinranken am Gewaechshaus befestigen
//   - CAD manual: http://www.openscad.org/documentation.html
//
// Andreas Merz 2019-03-10, v0.1 
// GPLv3 or later, see http://www.gnu.org/licenses


module clampshape1half(s1=3.7, y1=17.5) {
             // y1        // clamp length
             // s1        // clamp width at bottom
             c=0.3;       // clearance / spiel in mm
             w=2;         // wall thickness
             s2=(s1+c)/2;     // width at bottom
             polygon(points=[[0,0],[s2-0.3,0],[s2-0.1,0.1],[s2,0.3],[s2,0.5],[s2,1],
                [s1/2-c,3.5],[s2,5], 
                [min(0.5,s1/2-1),y1-3],[min(0.5,s1/2-1),y1-2.5],[min(0.5,s1/2)+0.2,y1-2.1],
                [(s1+2)/2,y1],      
                [(s1+2)/2+0.3,y1-0.3],[min(0.5,s1/2-1)+w-0.6,y1-3],
                [s2+w,5],
                [s2+w+c,-w],
                [0,-w]]);
}

module clampshape1(clampwidth=3.7, clamplength=17.5, cz=20) {
     linear_extrude(height=cz)
       union() {
         mirror() 
         clampshape1half(s1=clampwidth, y1=clamplength);
         clampshape1half(s1=clampwidth, y1=clamplength);
       }
}

//---------------- Instances ---------------------

clampshape1();
