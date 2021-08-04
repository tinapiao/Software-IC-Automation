#!/bin/sh
OS=`uname -s`
#echo "OS : $OS"
#echo "arg1=$1 arg2=$2"
if [ "$1" != "" ] 
then
  fileName=$1
else
  echo "run_tif_tcf.sh <executableName> <configFile>"
  exit 1
fi
if [ "$2" != "" ] 
then
  config=$2
else
  echo "run_tif_tcf.sh <executableName> <configFile>"
  exit 1  
fi
#echo "$fileName"

if [ "$OS" != "SunOS" ] 
then 
  executable="$fileName-32.lnx"
else
  if [ "$OS" != "Linux" ] 
  then
      executable="$fileName-64.sol"
  else
      echo "*** ERROR : Unsupported kernel $OS"
      exit 1
  fi
fi
#echo "$executable $config"
$executable $config
