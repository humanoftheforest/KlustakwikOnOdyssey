#!/bin/bash

# Parse the filename and go to the data directory
FULLNAME=SUBSTITUTE_HERE
DIRNAME=${FULLNAME%/*}
FILENAME=${FULLNAME:(-7)} #pull out last 7 characters: TTX.ntt"
MATLABSCRIPT=${FILENAME:0:3}script.m

if ! [ exist -d: $OUTDIR ]; then  # check to make sure the output directory exists
  OUTDIRMOUSE=${OUTDIR:0:${#OUTDIR}-19} #output folder for the mouse 
  if ! [ exist -d: $OUTDIRMOUSE ]; then
    mkdir $OUTDIRMOUSE
  fi
  mkdir $OUTDIR 
  mkdir $OUTDIR/FD
fi

# if necessary, make the FD directory
pushd $DIRNAME
if [ ! -d ./FD ]; then
    mkdir FD
fi

# Build the matlab script
pushd FD
echo "addpath(genpath('/n/uchida_lab/Users/vinodrao/matlab'));" > $MATLABSCRIPT
echo "rmpath('/n/home06/vinodrao/matlab');" >> $MATLABSCRIPT
echo "writeFDandFET('"$FILENAME"');" >> $MATLABSCRIPT
echo "exit;" >> $MATLABSCRIPT

# Load matlab and execute the script
popd
module load centos6/matlab-R2013a  
matlab -nojvm -nosplash -nodesktop < FD/$MATLABSCRIPT 

# Run Klustakwik
pushd FD
KlustaKwik ${FILENAME:0:3} 1 -MinClusters 2 -MaxClusters 2 -UseDistributional 0 -PenaltyK 100 > ${FILENAME:0:3}output.txt

# Copy the fd data into the output folder 
#  FYI: may move the final cluster into the above folder but will do so when transferring the data back.
cp -f ${FILENAME:0:3}* $OUTDIR/FD