#!/bin/bash

#SBATCH -n 1 #number of cores
#SBATCH -t 360 #runtime in minutes
#SBATCH -p serial_requeue #partition
#SBATCH --mem-per-cpu 4000 #Memory per cpu in MB
#SBATCH --mail-type=ALL      #Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=vinod3000@gmail.com  #Email to which notifications will be sent

bash makeSBatch.sh > FULLBatchOutput.txt