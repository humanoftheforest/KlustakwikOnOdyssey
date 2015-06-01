RepBy="_"
RepPatt="/"
for i in `cat TetList.txt`;
do
    # first generate the bash script from the template
    filename="${i//$RepPatt/$RepBy}"  #swap out /'s in filename with _'s
    filename=${filename:37:${#filename}-41} #37 comes from length of '/n/uchi..../RawData/'
    sed "s:SUBSTITUTE_HERE:'$i':g" sortTetrodeTemplate.sh > slurmfiles/scripts/$filename.sh

    # then make the sbatch file
    echo "#!/bin/bash" > slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH -N 1  #number of cores" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH -t 360  #runtime in minutes" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH -p serial_requeue  #number of partions" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH --mem-per-cpu 64000  #memory in MB" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH --mail-type=FAIL #Type of email notification- BEGIN,END,FAIL,ALL" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "#SBATCH --mail-user=vinod3000@gmail.com  #Email to which notifications will be sent" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
    echo "bash slurmfiles/scripts/$filename.sh > slurmfiles/Output/"$filename"_output.txt" >> slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh

    #finally run the sbatch file
#    sbatch slurmfiles/slurmbatch/RUN_SBATCH_$filename.sh
done
