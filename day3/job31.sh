#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=40
#SBATCH --time=00:15:00
#SBATCH --job-name='LFPy Circuit'
#SBATCH --mail-type=ALL
#SBATCH --mail-user=frank.mazza@mail.utoronto.ca
#SBATCH -o o%j.out
#SBATCH -e e%j.out

module load intel/2018.2
module load intelmpi/2018.2
module load anaconda3/2018.12

conda activate LFPy2

unset DISPLAY

srun python 3_1.py

