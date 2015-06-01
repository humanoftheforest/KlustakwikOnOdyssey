# Parse the filename and go to the data directory
FULLNAME="/n/uchida_lab/Users/vinodrao/Rawdata/PrayingMantis/2014-03-14_10-01-32/TT1.ntt"
DIRNAME=${FULLNAME%/*}
FILENAME=${FULLNAME:(-7)} #pull out last 7 characters: TTX.ntt"
MATLABSCRIPT=${FILENAME:0:3}script.m
OUTDIR=/n/uchida_lab/Users/vinodrao/Output/${DIRNAME:37}
PK=1

if ! [ exist -d: $OUTDIR ]; then  # check to make sure the output directory exists
  OUTDIRMOUSE=${OUTDIR:0:${#OUTDIR}-19} #output folder for the mouse 
  if ! [ exist -d: $OUTDIRMOUSE ]; then
    mkdir $OUTDIRMOUSE
  fi
  mkdir $OUTDIR 
fi

pushd $DIRNAME
mkdir FD$PK
pushd FD$PK

# Build the matlab script
echo "addpath(genpath('/n/uchida_lab/Users/vinodrao/matlab'));" > $MATLABSCRIPT
echo "rmpath('/n/home06/vinodrao/matlab');" >> $MATLABSCRIPT
echo "writeFDandFET('"$FILENAME"');" >> $MATLABSCRIPT
echo "exit;" >> $MATLABSCRIPT

# Load matlab and execute the script
popd
module load centos6/matlab-R2013a  
matlab -nojvm -nosplash -nodesktop < FD$PK/$MATLABSCRIPT 

# Run Klustakwik
pushd FD$PK
KlustaKwik ${FILENAME:0:3} 1 -MinClusters 2 -MaxClusters 2 -UseDistributional 0 -penaltyK $PK > ${FILENAME:0:3}output.txt

# Copy the fd folder into an output folder
mkdir $OUTDIR/FD$PK
cp -f * $OUTDIR/FD$PK

