echo '
;LAYER:1
M117 Nb = 2 / 2    ; Display Message
M106 S96
G0 F6000 X102.377 Y100.301 Z0.460
;TYPE:WALL-OUTER
G1 F1140 X102.623 Y100.301 E7.93287
G1 X102.623 Y104.569 E8.07483
G1 X104.271 Y104.569 E8.12964
G1 X104.271 Y104.699 E8.13397
G1 X100.729 Y104.699 E8.25177
G1 X100.729 Y104.569 E8.25610
G1 X102.377 Y104.569 E8.31091
G1 X102.377 Y100.301 E8.45286
' |
awk '
  /^ *;/    {  print "%" $0 }
  /LAYER:/  { split($0, val, "LAYER:", key); n=val[2];}
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
           }
       END {
             printf("x%d=[%s];\n",n,xx);
             printf("y%d=[%s];\n",n,yy);
             printf("z%d=[%s];\n",n,zz);
             printf("d%d=[%s];\n",n,dd);
             printf("e%d=[%s];\n",n,ee);
             printf("f%d=[%s];\n",n,ff);
             printf("plot3( x%d,y%d,z%d, %cLineWidth%c, 2);\n",n,n,n,39, 39);
           }'

