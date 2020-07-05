#!/bin/bash

+x

echo "Cloning the kcni-school-lessons repository"
mkdir $SCRATCH/kcni-school-data
cd $SCRATCH/kcni-school-data
git clone --recurse-submodules https://github.com/krembilneuroinformatics/kcni-school-lessons.git

echo "Moving larger data into the repository"
cp /scinet/course/ss2020/5_neuroimaging/kcni_data/day1_workdir.zip $SCRATCH/kcni-school-data/kcni-school-lessons/day1/
scp -r /scinet/course/ss2020/5_neuroimaging/kcni_data/allen_brain $SCRATCH/kcni-school-data/kcni-school-lessons/day2/kcni_summer/
