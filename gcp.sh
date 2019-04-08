#!/bin/bash
#
# gcp.sh
#
# Purpose: 
#   patch, mount, copy g-file to sdcard, unmount
#
# Usage examples:
#
#  gcp.sh      # copy latest g-file in local directory
#
#  gcp.sh -h   # show help
#  gcp.sh -t   # test run, do not copy but show what will be done
#  gcp.sh *.g  # copy all g-files to SD-card, print the first
#
#  gcp.sh temp=215 *.g  # patch g-files, set temperature, and copy
#
# Background:
#   - frequently plugging, mounting, copying, unmounting is boring...
#   - optional patching of g-code files
#   - used for my Dagoma DiscoEasy200 printer which prints by default
#     the file dagoma0.g from the SD-card
#   - https://reprap.org/wiki/G-code/de#M109:_Set_Extruder_Temperature_and_Wait
#
# $Header: gcp.sh, v0.2, Andreas Merz, 2019-01-27 $
# GPLv3 or later, see http://www.gnu.org/licenses

hc=cat

#--- default settings ---
gext=dagoma0.g      # g-file file name extension for SD-card print target
gfile=$(ls -1tr *.g | tail -n 1)  # take latest g-file in actual directory
mountpoint=/mnt/mnt               # where to mount the SD-card
sdev=/dev/sdd1                    # SD-card device
header=";$USER@$HOSTNAME $(date  '+%F %T')"     # add a header to gcode file
fixfan="M106 S81"                 # patch for M107 fan off bug in dagoma.g
cooldown="M109 R90/M109 R150"     # change M109 max temp Range in dagoma.g
temp=""                           # patch extruder temperature

#--- process arguments ---
cmdline="$0 $@"
narg=$#
echo=echo
cnt=0

while [ "$1" != "" ] ; do
  case "$1" in
   -h)       sed -n '2,/^#.*Header: /p' $0 | cut -c 2- ; exit ;;   # help
   -t)       t=echo ; echo="echo -ne \\c" ;;  # dry run, test
   -w)       action=watch ;;    # dummy
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

if [ "$gfiles" == "" ] ; then
  gfiles=$gfile
fi

#-------------------------------------------------
# patch g-code loop
#-------------------------------------------------
for ii in $gfiles ; do
  if [ "$fixfan$header$temp" ] ; then 
    $t cp -pi $ii $ii.orig
  fi
  if [ "$header" ] ; then
    echo "# $ii  - adding header in $ii"
    $t sed -i -e "2,2s#^;#$header $ii\n;$cmdline\n;#" $ii
  fi
  if [ "$fixfan" ] ; then
    echo "# $ii  - patching M107 statement to $fixfan"
    $t sed -i -e "/;LAYER:0/,/;TYPE:SKIRT/s/^M107/$fixfan ; M107 patched by gcp.sh /" $ii
  fi
  if [ "$temp" ] ; then
    echo "# $ii  - changing temperature to $temp"
    $t sed -i -e "s/^\(M104 S[1-9].*\)/M104 S$temp ; \1 - patched by gcp.sh /" $ii
  fi
  if [ "$cooldown" ] ; then
    echo "# $ii  - changing wait for cooldown max temp $cooldown"
    $t sed -i -e "s/^$cooldown ; patched by gcp.sh /" $ii
  fi
done

#-------------------------------------------------
# copy loop
#-------------------------------------------------
if ! sudo mount | grep $mountpoint ; then
  $t sudo mount $sdev $mountpoint
  sleep 1
fi
echo "# copying $gfiles to SD-Card"
echo "# $gfile -> $gext"
$t sudo cp --preserve=timestamps $gfiles $mountpoint
$t sudo cp --preserve=timestamps $gfile $mountpoint/$gext
if $t sudo umount $mountpoint ; then
  echo "# SDcard unmounted."
fi

