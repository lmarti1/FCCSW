#!/bin/bash

# will download and install FCCSW and GAUDI

echo "Starting setup"

# create FCC directory
mkdir FCC
cd FCC
export FCCBASE=$PWD

# get Gaudi
git clone -b dev/hive  http://cern.ch/gaudi/GaudiMC.git GAUDI/GAUDI_v25r2
export GAUDI=$FCCBASE/GAUDI/GAUDI_v25r2

# get FCC SW
git clone -b fcc_test https://github.com/lmarti1/FCCSW.git FCCSW
#git clone https://github.com/lmarti1/FCCSW.git FCCSW
#git clone git@github.com:HEP-FCC/FCCSW.git FCCSW 
export FCCSW=$FCCBASE/FCCSW

# set environment for FCC
cd $FCCSW
source ./init.sh

# Compile gaudi first
cd $GAUDI
make -j 12 
make install 

# compile FCCSW
cd $FCCSW
make -j 12

echo "Installation complete"

# moving over to tests here
cd $FCCSW/build.$CMTCONFIG

echo "Starting tests"
#ctest -D Nightly
# Local for now
ctest

echo "all done"
