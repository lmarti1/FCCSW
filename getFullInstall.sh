#!/bin/bash

echo "Starting setup. Will get the full stack of the software"

export ROOT_INSTALL_DIR=$PWD

# for more info on LCG see 
# https://ph-dep-sft.web.cern.ch/document/using-lcgcmake
export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/2.8.12.2/Linux-i386/bin:${PATH}
svn co svn+ssh://svn.cern.ch/reps/lcgsoft/trunk/lcgcmake
mkdir lcgcmake-build
cd lcgcmake-build
export BUILD_HOME=$PWD

# get compiler
source /afs/cern.ch/sw/lcg/external/gcc/4.8/x86_64-slc6-gcc48-opt/setup.sh
# make sure it is used
export CC=/afs/cern.ch/sw/lcg/contrib/gcc/4.8.1/x86_64-slc6-gcc48-opt/bin/gcc
export CXX=/afs/cern.ch/sw/lcg/contrib/gcc/4.8.1/x86_64-slc6-gcc48-opt/bin/g++

# use FCC-2 toolchain
cmake -DCMAKE_INSTALL_PREFIX=../lcgcmake-install -DLCG_VERSION=FCC-2 ../lcgcmake

# install a set of packages
make -j 4 Boost
make -j 4 ROOT
make -j 4 Geant4
make -j 4 DD4hep

# get and use cmt v1r20p20090520
make -j 4 cmt
export CMTCONFIG=x86_64-slc6-gcc48-opt
export INSTALL_HOME=$PWD/../lcgcmake-install
export PYTHONPATH=/afs/cern.ch/lhcb/software/releases/LBSCRIPTS/LBSCRIPTS_v8r0/InstallArea/python/
export PATH=/afs/cern.ch/lhcb/software/releases/LBSCRIPTS/LBSCRIPTS_v8r0/InstallArea/scripts:$PATH
export CMTROOT=$INSTALL_HOME/cmt/v1r20p20090520/$CMTCONFIG/CMT/v1r20p20090520
cd $CMTROOT
source ./src/setup.sh
export PATH=$CMTROOT/$CMTBIN:$PATH
#paths set?
which cmt

# flex and bison for doxygen. 
cd $INSTALL_HOME
wget http://prdownloads.sourceforge.net/flex/flex-2.5.33.tar.gz
tar -xvzf flex-2.5.33.tar.gz
cd flex-2.5.33
./configure --prefix=$INSTALL_HOME/flex/
make
export PATH=$INSTALL_HOME/flex-2.5.33:$PATH
cd $INSTALL_HOME
mkdir bison
cd bison
wget http://ftp.gnu.org/gnu/bison/bison-2.3.tar.gz
tar -xvzf bison-2.3.tar.gz
cd bison-2.3
./configure --prefix=$INSTALL_HOME/bison --with-libiconv-prefix=$INSTALL_HOME/libiconv/
make 
make install
export PATH=$INSTALL_HOME/bison/bin:$PATH

# more packages
cd $BUILD_HOME
make -j 4 doxygen
export DOXYVERSION=$(getExtVersion doxygen)
export PATH=$INSTALL_HOME/doxygen/$DOXYVERSION/x86_64-slc6-gcc48-opt/bin:$PATH
make -j 4 CppUnit
make -j 4 QMtest
make -j 4 HepPDT

# This is some patchwork to be able to compile CLHEP and gaudi.
# add CLHEP 1.9 if not there already
export TOOLCHAIN_FCC2=$INSTALL_HOME/../lcgcmake/cmake/toolchain/heptools-FCC-2.cmake
grep "CLHEP" $TOOLCHAIN_FCC2 | grep -q "1.9"
if ! [ $? -eq 0 ]; then 
  echo "Adding CLHEP 1.9"
  sed 's/.*LCG_external_package(CLHEP*/LCG_external_package(CLHEP             1.9.4.7                   clhep          )\n&/' $TOOLCHAIN_FCC2 >> outf.txt
  cp outf.txt $TOOLCHAIN_FCC2
  rm outf.txt
  echo "Added CLHEP 1.9"
  cmake -DCMAKE_INSTALL_PREFIX=../lcgcmake-install -DLCG_VERSION=FCC-2 ../lcgcmake
  make -j 4 CLHEP-1.9.4.7
  # use 1.9 for RELAX
  export PATH=$INSTALL_HOME/clhep/1.9.4.7/x86_64-slc6-gcc48-opt/bin:$PATH
  export LD_LIBRARY_PATH=$INSTALL_HOME/clhep/1.9.4.7/x86_64-slc6-gcc48-opt/lib:$LD_LIBRARY_PATH
  source $INSTALL_HOME/ROOT/5.34.19/$CMTCONFIG/bin/thisroot.sh 
  export CMAKE_INCLUDE_PATH=$INSTALL_HOME/clhep/1.9.4.7/$CMTCONFIG/include
  export CMAKE_LIBRARY_PATH=$INSTALL_HOME/clhep/1.9.4.7/$CMTCONFIG/lib
  cmake -DCMAKE_INSTALL_PREFIX=../lcgcmake-install -DLCG_VERSION=FCC-2 ../lcgcmake
fi
unset TOOLCHAIN_FCC2

# Can now complie RELAX and rest of packages
make -j 4 RELAX
make -j 4 tcmalloc
make -j 4 libunwind
make -j 4 tbb
make -j 4 AIDA
make -j 4 fastjet
cd $INSTALL_HOME

# create summary files LCG_* for usage with FCC software
python ../lcgcmake/cdash/extract_LCG_summary.py . $LCGPLAT dev2 RELEASE

# need a symbolic link to complete the LCG structure
# as the text file is expected in LCG_$HEPTOOLS_VERSION
cd ..
ln -s lcgcmake-install LCG_dev2

# stack should be ready now. 
# get and compile FCCSW and gaudi
mkdir FCC
cd FCC
export FCCBASE=$PWD
git clone -b dev/hive  http://cern.ch/gaudi/GaudiMC.git GAUDI/GAUDI_v25r2
export GAUDI=$FCCBASE/GAUDI/GAUDI_v25r2
git clone -b fcc_test https://github.com/lmarti1/FCCSW.git FCCSW
export FCCSW=$FCCBASE/FCCSW
cd $FCCSW

# TODO: did not upload init script yet. copy one from old build
cp /mnt/build/testbuild/init_own_stack.sh init.sh
source ./init.sh
cd $GAUDI
make -j 12
make install 
cd $FCCSW
make -j 12

echo "Installation complete"

# moving over to tests here
cd $FCCSW/build.$CMTCONFIG
echo "Starting tests"
#ctest -D Experimental
echo "all done"

# cleanup variables
unset BUILD_HOME INSTALL_HOME ROOT_INSTALL_DIR

echo "all done"

