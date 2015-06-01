#!/bin/bash

# Parse the filename and go to the data directory
FULLNAME=$1
DIRNAME="${FULLNAME%/*}"
FILENAME="${FULLNAME:(-7)}" #pull out last 7 characters: TTX.ntt"
MATLABSCRIPT=${FILENAME:0:3}"script.m"

# if necessary, make the FD directory
pushd $DIRNAME
if [ ! -d ./FD ]; then
    mkdir FD
fi

# Build the matlab script
pushd FD
echo "addpath(genpath('/n/home06/vinodrao/matlab'));" > $MATLABSCRIPT
echo "writeFDandFET('"$FILENAME"');" >> $MATLABSCRIPT
echo "exit;" >> $MATLABSCRIPT

# Load matlab and execute the script
popd 
module load centos6/matlab-R2013a  
matlab -nojvm -nosplash -nodesktop < FD/$MATLABSCRIPT 

# Run Klustakwik
pushd FD
KlustaKwik ${FILENAME:0:3} 1 -MinClusters 10 -MaxClusters 20 -UseDistributionl 0 > ${FILENAME:0:3}output.txt

# Send an email and return to original directory
#mailx -s"Finished batch" vinod3000@gmail.com < ${FILENAME:0:3}output.txt
popd
popd
