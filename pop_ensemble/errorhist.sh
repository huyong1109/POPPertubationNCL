#!/bin/bash

usage() {
  echo 'USAGE: $0 -casesuf PERT -filesuf MONTH -varname VARIABLE'
  echo ''
  echo "Required flags:"
  echo "-casesuf       Name of file to create with this script"
  echo "-filesuf        Archive storing pop output file from any of the ensemble runs "
  echo "-varname       Prefix name of ensemble cases "
}

# Default values for optional arguments
CASESUF=14.21
FILESUF=01
VARNAME=SSH
DIRECTION=surf
VAL=1

while [ $# -gt 0 ]; do
  case $1 in
    -casesuf )
      CASESUF=$2
      shift
    ;;
    -filesuf )
      FILESUF=$2
      shift
    ;;
    -varname )
      VARNAME=$2
      shift
    ;;
    -h )
      usage
      exit 0
    ;;
    * )
      echo "ERROR: invalid argument $1"
      echo ''
      usage
      exit 1
    ;;
  esac
  shift
done

# Make sure all required values are provided

# Check for size issues
COMPROOT=$SCR/archive
CONTRLNAME=perturb.g40.T.year.np
CASENAME=perturb.g40.T.year.${CASESUF}
MIDFIX=ocn/hist
FILE1=${COMPROOT}/${CASENAME}/$MIDFIX/${CASENAME}.pop.h.0001-${FILESUF}.nc
FILE2=${COMPROOT}/${CONTRLNAME}/$MIDFIX/${CONTRLNAME}.pop.h.0001-${FILESUF}.nc
OUTFILE=COMP_${VARNAME}_${CASESUF}_${FILESUF}


ThisDir=$( cd `dirname $0`; pwd -P )
NCLSCRIPT=$ThisDir/ncl_library/errorhist.ncl

export NCL_VALID_LIB_DIR=$( cd $ThisDir/ncl_library; pwd -P )
COMMAND="ncl $NCLSCRIPT testfile=\"${FILE1}\" cntrlfile=\"$FILE2\" varname=\"$VARNAME\" outfile=\"$OUTFILE\" "
echo "$COMMAND"
$COMMAND
