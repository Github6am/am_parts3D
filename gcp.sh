#!/bin/bash
#
# gcp.sh
#
# Purpose: 
#   mount, copy g-file to sdcard, unmount
#
# Usage examples:
#
#  gcp.sh      # copy latest g-file in local directory
#
#  gcp.sh -h   # show help
#  gcp.sh -t   # test run, do not copy but show what will be done
#  gcp.sh *.g  # copy all g-files to SD-card, print the first
#
# Background:
#   - frequently plugging, mounting, copying, unmounting is boring...
#   - used for my Dagoma DiscoEasy200 printer wich prints by default
#     the file dagoma0.g on the SD-card

# $Header: gcp.sh, v0.1, Andreas Merz, 2019-01-06 $
# GPLv3 or later, see http://www.gnu.org/licenses

hc=cat

#--- default settings ---
gext=dagoma0.g      # g-file file name extension for SD-card print target
gfile=$(ls -1tr *.g | tail -n 1)  # take latest g-file in actual directory
mountpoint=/mnt/mnt
sdev=/dev/sdd1

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
$t sudo umount $mountpoint


# todo: add original filename as comment in g-file

