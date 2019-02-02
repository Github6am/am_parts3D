
# https://reprap.org/wiki/G-code/de#G0_.26_G1:_Move

#echo '
#;LAYER:1
#M117 Nb = 2 / 2    ; Display Message
#M106 S96
#G0 F6000 X102.377 Y100.301 Z0.460
#;TYPE:WALL-OUTER
#G1 F1140 X102.623 Y100.301 E7.93287
#G1 X102.623 Y104.569 E8.07483
#G1 X104.271 Y104.569 E8.12964
#G1 X104.271 Y104.699 E8.13397
#G1 X100.729 Y104.699 E8.25177
#G1 X100.729 Y104.569 E8.25610
#G1 X102.377 Y104.569 E8.31091
#G1 X102.377 Y100.301 E8.45286
#' |

cat T.dagoma0.g |
awk '
           {
             #comment=sprintf("%%%5d %s",FNR,$0);   # add line number of current file
             comment=sprintf("%%%s",$0);
           }
  /LAYER:/ { split($0, val, "LAYER:", key); 
             n=val[2];    # Layer number
             flushmat=1;
           }
  /TYPE:/  { split($0, val, "TYPE:",  key); 
             type=val[2];
             switch(type) {
               case /SKIRT/:      typeshort="sk"; break;
               case /WALL-OUTER/: typeshort="wo"; break;
               case /FILL/:       typeshort="fi"; break;
               default:           typeshort="";   break;
             }
             flushmat=2;
           }
  /M84/    {
             flushmat=3;   # Shut down at end
           }
  /^G[01]/ { split($0, val, " *[XYZEF;]", key);
             #print "%" $0 
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
             xx=sprintf("%s %8.3f", xx, Xnew);
             yy=sprintf("%s %8.3f", yy, Ynew);
             zz=sprintf("%s %8.3f", zz, Znew);
             dd=sprintf("%s %8.3f", dd, dist);
             ff=sprintf("%s %8d",   ff, Fnew);
             ee=sprintf("%s %8.3f", ee, Enew);
             #ee=sprintf("%s %8.3f", ee, rextrusion);
             Xold=Xnew; Yold=Ynew; Zold=Znew; Fold=Fnew;
             comment="";
           }
           { if(comment!="") print comment;
             if(flushmat > 0) {
               v=sprintf("%d%s",n,typeshort);  # variable number + extension
               printf("x%s=[%s];\n",v,xx);
               printf("y%s=[%s];\n",v,yy);
               printf("z%s=[%s];\n",v,zz);
               printf("d%s=[%s];\n",v,dd);
               printf("e%s=[%s];\n",v,ee);
               printf("f%s=[%s];\n",v,ff);
               printf("plot3( x%s,y%s,z%s, %cLineWidth%c, 2); grid on; hold on;\n",v,v,v, 39, 39);
               flushmat=0;
               xx=""; yy=""; zz=""; dd=""; ee=""; ff="";
             }
           }
           '

