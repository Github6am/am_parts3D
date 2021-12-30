#!/bin/bash
#
# am_catalogue.sh
#
# Purpose: 
#   create a gallery of my scad-designs in markdown and html
#
# Usage examples:
#   ./am_catalogue.sh                       # make all
#   ./am_catalogue.sh filter="am_box"
#   ./am_catalogue.sh action="makemd,html"  # just markdown and html
#   ./am_catalogue.sh action="makepng,makemd,html" filter="ring\|Festo"
#   ./am_catalogue.sh action="makestl"      # create stl files in ./img
#
# Background:
#   - prerequisites: the following packages need to be installed:
#     openscad, meld, pandoc
#     this script assumes, that each scad file has an "-- Instances --" 
#     section and performs the following processing steps:
#       0. evaluate command-line arguments
#  	1. create a list of potential object candidates: catalogue.raw
#  	2. manual merge of: catalogue.raw  with git controlled catalogue.use
#  	3. extract enabled objects from catalogue.use to a amtmp.scad
#  	4. call openscad to create a png picture for the enabled objects
#  	5. create a catalogue.md which lists scad-source, object and png
#  	6. convert catalogue.md to catalogue.html
#
#   - Github markdown:
#     https://github.github.com/gfm/#images
#     ![Imgur](https://i.imgur.com/TuwFYTs.png  "test")
#     ![foo bar](/path/to/train.jpg  "title"   )
#
#   - create a html file from markdown
#     pandoc -f gfm -o catalogue.html catalogue.md  # create local HTML file
#     dillo readme.html &			    # view with any web browser

# $Header: am_catalogue.sh, v0.2, Andreas Merz, 2021-05-02 $
# GPLv3 or later, see http://www.gnu.org/licenses

hc=cat

#--- default settings ---

filter=""
action="newcatalogue,mergetool,makemd,makepng,html"
catalogue=catalogue
cwd=$(pwd)

#--- process arguments ---
cmdline="$0 $@"
narg=$#
echo=echo
cnt=0

while [ "$1" != "" ] ; do
  case "$1" in
   -h)       sed -n '2,/^#.*Header: /p' $0 | cut -c 2- ; exit ;;   # help
   -t)       t=echo ; echo="echo -ne \\c" ;;  # dry run, test
   -f)       filter="$2" ; shift ;;
   -*)       echo "warning: unknown option $1" ;  sleep 2 ;;
   *=*)      echo $1 | $hc ; eval $1 ;;
   *)        par="$1" ; cnt=`expr $cnt + 1` ; echo "arg[$cnt]=$par" | $hc ;;
  esac
  shift

  # compatibility to enumerated parameter interface  - no mixing, only appending of new will work!
  case "$cnt" in 
   0)  ;; 
   1)  gfile="$par" ; gfiles="$gfile" ;;
   *)  gfiles="$gfiles $par" ;;             # append all further arguments
  esac 
done


# show settings
varlist="$(sed -ne "/^#--- default settings ---/,/^#--- process arguments ---/p" $0 | grep "=" | grep -v "^if " | grep -v "^ *echo "  | sed -e 's/=.*//' -e 's/^ *//' | grep -v "#" | sort -u )"
#echo $varlist
echo                    | $hc
echo "# command line:"  | $hc
echo "$cmdline"         | $hc
echo                    | $hc
echo "# settings:"      | $hc
for vv in $varlist ; do
  echo "$vv=\"${!vv}\"" | $hc
done                    
echo                    | $hc


#-------------------------------------------------

cd $cwd

# new raw catalogue
if echo $action | grep newcatalogue > /dev/null ; then
  rm -f amtmp.scad
  for scadfile in *.scad ; do
    if ! git ls-files | grep "^$scadfile" > /dev/null ; then
       gg=""
       if echo $action | grep gitonly > /dev/null ; then
         continue;
       fi
    else
       gg="git"
    fi
    echo "# ${gg}scadfile=$scadfile"
    sed -n '/Instances --/,$ p' $scadfile | grep "^[A-Za-z]\|^//[A-Za-z]"
    echo
  done > $catalogue.raw
fi

# edit raw catalogue by uncommenting all objects of interest
if echo $action | grep mergetool > /dev/null ; then
  echo "# please select or deselect objects to your need..."
  meld $catalogue.raw $catalogue.use
fi

# create img directory to store png output
if [ ! -d img ] ; then
  mkdir  img
fi

if echo $action | grep make > /dev/null ; then
  cat $catalogue.use | awk -v filter="$filter" -v action="$action" '
   /#.*scadfile=/      { if( $0 ~ filter ) 
                            select=1;       # process new scad file
                         else 
                            select=0;
			 instcnt=0;            # reset scad-file instance-counter
                         split($2, scf, "=", seps);
                         scadfile=scf[2];
                         split(scadfile, basenam, ".", seps);
                         scadbase=basenam[1];
                         if(select>0 ) {
                           printf("\n#%s %s\n", $1, scadfile);  # md chapter output
			   if( $0 ~ /gitscadfile/)
                             printf("https://github.com/Github6am/am_parts3D/blob/master/%s\n\n", scadfile);
                           cmd0=sprintf("grep https://www.thingiverse %s\necho\n", scadfile);
			   system(cmd0);    # output hyperlinks to thingiverse, if present
			   
			 }
			 
                       }

   /^ *[A-Za-z].*);/   { select*=2;  # new object
                       }
		       
                       { q=0x27;     # single quote
                         d="  ";
                         if(select>1 ) {
                           # select instance object: e.g translate(..) mypart();
			   # and create suitable filenames out of it
                           oldobjname=objname;
			   object=$0;
                           objname=object;
                           gsub(/.*\) +/, "", objname);  # strip transformation
                           gsub(/\(.*/,  "", objname);   # strip brackets
                           # print d object d objname d oldobjname
                           pngname=sprintf("img/%s.%s.png",scadbase, objname);
			   if( objname == oldobjname)
                             pngname=sprintf("img/%s.%s.%02d.png",scadbase, objname, ++instcnt);
			   
			   stlname=pngname;
			   gsub(/\.png$/, ".stl", stlname);
			   
                           # generate a openscad tmp file and a command to create png or stl file
                           cmd1=sprintf("sed -n %c1,/Instances --/ p%c %s > amtmp.scad", q, q, scadfile);
                           cmd2=sprintf("echo %c%s%c >> amtmp.scad", q, object, q);
                           cmd3=sprintf("openscad  -o %s --render --imgsize 320,240  --view \"axes,scales\" amtmp.scad\n", pngname);
                           cmd4=sprintf("openscad  -o %s amtmp.scad\n", stlname);   # generate stl output
                           #print d cmd1
                           #print d cmd2
                           #print d cmd3
                           #print d cmd4
			   if( action ~ "makepng" ) {
                             system(cmd1);
                             system(cmd2);
                             system(cmd3);
                             #system(cmd4);
                           }
			   if( action ~ "makestl" ) {
                             system(cmd1);
                             system(cmd2);
                             system(cmd4);
                           }
			   
                           # print a markdown link
                           cnt++;
                           #printf("  %s: ", objname);
                           printf("![obj%02d](%s \"%s\" ) ", cnt, pngname, objname);
                           printf("%s\n", objname);
                           
                           select=1;
                         }
                       }'  | tee $catalogue.md
fi

# create html from github flavoured markdown
if echo $action | grep html > /dev/null ; then
  pandoc -f gfm -o $catalogue.html $catalogue.md
  echo
  echo "# created html file:"
  echo "file:$(pwd)/$catalogue.html"
fi

