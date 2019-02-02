
# https://reprap.org/wiki/G-code/de#G0_.26_G1:_Move

## T.scad
# txt="T";
# fontname = "Liberation Sans";
# fontsize = 5;
# color("red")
#   translate([0,0,0]) linear_extrude(height = 0.4) 
#   text(txt, size = fontsize, font = fontname, halign = "center", valign = "center", $fn = 16);

## Q.scad
# cube(size = [10, 12, 5]);

cat Q.dagoma0.g |
awk '
           {
             #comment=sprintf("%%%5d %s",FNR,$0);   # add line number of current file
             comment=sprintf("%%%s",$0);
           }

  /LAYER:/ { split($0, val, "LAYER:", key);
             nold=n;
             typeshortold=typeshort;
             typeshort="";
             n=val[2];    # Layer number
             flushmat++;
           }

  /TYPE:/  { split($0, val, "TYPE:",  key); 
             typeshortold=typeshort;  # FIFO 2
             nold=n; 
             type=val[2];
             switch(type) {
               case /SKIN/:       typeshort="sn"; break;
               case /SKIRT/:      typeshort="st"; break;
               case /WALL-INNER/: typeshort="wi"; break;
               case /WALL-OUTER/: typeshort="wo"; break;
               case /FILL/:       typeshort="fi"; break;
               default:           typeshort="";   break;
             }
             flushmat=2;
           }

  /M84/    { flushmat=3;   # Shut down at end
             typeshortold=typeshort;
           }

  /^G[01]/ { split($0, val, " *[XYZEF;]", key);
             #print "%" $0 
             
             # parse arguments of G1 and G0 message
             for(i=1; key[i]!="" ; i++) { 
               #print "%" key[i] "=" val[i+1];  # debug output
               switch( key[i] ) {
                 case /X/: Xnew=val[i+1]; break;
                 case /Y/: Ynew=val[i+1]; break;
                 case /Z/: Znew=val[i+1]; break;
                 case /E/: Enew=val[i+1]; break;
                 case /F/: Fnew=val[i+1]; break;
                 case /;/: Cnew=val[i+1]; key[i+1]=""; break;
                 default: print "syntax error: unknown" key[i];
               }
             }
             dist=sqrt((Xnew-Xold)^2 + (Ynew-Yold)^2 + (Znew-Zold)^2);
             if(dist>0) rextrusion=Enew/dist;
             else rextrusion=0;
             
             # append new values to vectors:
             xx=sprintf("%s %8.3f", xx, Xnew);
             yy=sprintf("%s %8.3f", yy, Ynew);
             zz=sprintf("%s %8.3f", zz, Znew);
             dd=sprintf("%s %8.3f", dd, dist);
             ff=sprintf("%s %8d",   ff, Fnew);
             ee=sprintf("%s %8.3f", ee, Enew);
             #ee=sprintf("%s %8.3f", ee, rextrusion);
             Xold=Xnew; Yold=Ynew; Zold=Znew; Fold=Fnew; # FIFO 2 for distance calculation
             comment="";  # omit comments for the normal moves
           }
           
           { 
             if(flushmat >= 2 && (typeshortold != "" || n==0) ) {
               # matlab variable number + extension
               v=sprintf("%d%s",nold,typeshortold);

               # output matlab code
               printf("x%s=[%s];\n",v,xx);
               printf("y%s=[%s];\n",v,yy);
               printf("z%s=[%s];\n",v,zz);
               printf("d%s=[%s];\n",v,dd);
               printf("e%s=[%s];\n",v,ee);
               printf("f%s=[%s];\n",v,ff);
               printf("plot3( x%s,y%s,z%s, %cLineWidth%c, 2); grid on; hold on;\n",v,v,v, 39, 39);
               
               # clear vectors, init with last value
               xx=sprintf("%8.3f", Xnew);
               yy=sprintf("%8.3f", Ynew);
               zz=sprintf("%8.3f", Znew);
               dd=sprintf("%8.3f", 0);
               ff=sprintf("%8d",   Fnew);
               ee=sprintf("%8.3f", Enew);

               flushmat=1;  # flag flushing done
             }
             if(comment!="") print comment;
           }
           '

