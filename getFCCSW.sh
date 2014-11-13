#!/bin/bash

# will download and install FCCSW and GAUDI
# git account required with your copy of FCCSW

echo "Starting setup"

# create new folder
DATE=`date +%Y-%m-%d_%H-%M`
f_name="FCC_"$DATE
echo "Creating folder FCC_"$DATE
mkdir $f_name
cd $f_name

# create FCC directory
mkdir FCC
cd FCC
export FCCBASE=$PWD

# get Gaudi
git clone -b dev/hive  http://cern.ch/gaudi/GaudiMC.git GAUDI/GAUDI_v25r2
export GAUDI=$FCCBASE/GAUDI/GAUDI_v25r2

# get FCC SW
git clone https://github.com/lmarti1/FCCSW.git FCCSW
#git clone git@github.com:HEP-FCC/FCCSW.git FCCSW 
export FCCSW=$FCCBASE/FCCSW

# set environment for FCC
cd $FCCSW
source init.sh

# Compile gaudi first
cd $GAUDI
make -j 12 
make install 

# compile FCCSW
cd $FCCSW
make -j 12

echo "Installation complete"

# moving over to tests here
cd $FCCSW/build.x86_64-slc6-gcc48-opt

echo "Starting tests"
# ctest -D Nightly

echo "all done"
