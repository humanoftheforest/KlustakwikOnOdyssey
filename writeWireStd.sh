FULLNAME="/n/uchida_lab/Users/vinodrao/Rawdata/PrayingMantis/2014-02-20_09-00-25/TT1.ntt"
DIRNAME=${FULLNAME%/*}
FILENAME=${FULLNAME:(-7)} #pull out last 7 characters: TTX.ntt"
MATLABSCRIPT=${FILENAME:0:3}wirescript.m
pushd $DIRNAME
mkdir FD
cd FD
echo "addpath(genpath('/n/uchida_lab/Users/vinodrao/matlab'));" > $MATLABSCRIPT
echo "gatherTraces('"$FILENAME"');" >> $MATLABSCRIPT
echo "exit;" >> $MATLABSCRIPT

module load centos6/matlab-R2013a  
matlab -nojvm -nosplash -nodesktop < $MATLABSCRIPT 
