#!/bin/bash

usage() {
  echo 'USAGE: create_ensemble.sh -out_file ENS_FILE_NAME -pop_out DIRNAME/CASE.###.pop.h0... [-n N_ENS] [-double]'
  echo ''
  echo "Required flags:"
  echo "-out_file       Name of file to create with this script"
  echo "-pop_out        Archive storing pop output file from any of the ensemble runs "
  echo "-casename       Prefix name of ensemble cases "
  echo "-casesuffix       Suffix name of files to be analyzed "
  echo ''
  echo "Optional flags:"
  echo "-n              Number of ensemble members, default = 101"
  echo "-tag            Tag name (used in metadata), default = cesm1_2_0"
  echo "-compset        Compset (used in metadata), default = BC5"
  echo "-res            Resolution (used in metadata), default = ne30_g16"
}

# Default values for optional arguments
NENS=7
TAG=cesm1_2_0
COMPSET=G_NORMAL_YEAR
RES=ne30_g16_rx1
MACH=yellowstone

while [ $# -gt 0 ]; do
  case $1 in
    -out_file )
      arg_in=$2
      OUT_DIR=$(cd `dirname $arg_in`; pwd -P )
      OUT_FILE=$(basename $arg_in)
      shift
    ;;
    -pop_out )
      ROOT_DIR=$2
      shift
    ;;
    -casename )
      CASENAME=$2
      shift
    ;;
    -casesuffix )
      CASESUFFIX=$2
      shift
    ;;
    -compset )
      COMPSET=$2
      shift
    ;;
    -res )
      RES=$2
      shift
    ;;
    -mach )
      MACH=$2
      shift
    ;;
    -tag )
      TAG=$2
      shift
    ;;
    -n )
      NENS=$2
      shift
    ;;
    -month | -monthly )
      MONTHLY='monthly=True'
    ;;
    -verbose )
      VERBOSE='verbose=True'
    ;;
    -defvar )
      DEFVAR='defvar=True'
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
if [ -z $OUT_FILE ]; then
  echo "ERROR: you must provide a name for the output file."
  usage
  exit 1
fi
if [ -z $ROOT_DIR ] || [ -z $CASENAME ] || [ -z $CASESUFFIX ]; then
  echo "ERROR: you must provide the root case name and suffix."
  usage
  exit 1
fi

# Check for size issues
NFILES=`find $ROOT_DIR |grep "$CASENAME.*.$CASESUFFIX" | wc -l`
if [ $NFILES -lt $NENS ]; then
  echo "ERROR: can not create ensemble of size $NENS out of $NFILES files!"
  exit 1
fi

ThisDir=$( cd `dirname $0`; pwd -P )
NCLSCRIPT=$ThisDir/generate_validation_avgs.ncl

export NCL_VALID_LIB_DIR=$( cd $ThisDir/ncl_library; pwd -P )
COMMAND="ncl $NCLSCRIPT ensemble_file=\"${OUT_DIR}/${OUT_FILE}\" pop_out_pre=\"$ROOT_DIR\" casename=\"$CASENAME\" pop_out_suf=\"$CASESUFFIX\" tag=\"$TAG\" nfile_opts=$NENS res=\"$RES\" compset=\"$COMPSET\" mach=\"$MACH\" $MONTHLY $VERBOSE $DEFVAR"
echo "$COMMAND"
$COMMAND
