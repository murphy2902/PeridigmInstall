#!/bin/bash

# Authors:  Ryan Murphy 
#           Dr. Guven
#           Zachary
#           Rachel
#
# Updated:  7-22-15
# 
# This script was built to install Peridigm and its dependencies locally and statically.

# If any command fails, exit the script
set -e

# Redirect all of STDERR to STDOUT
exec 2>&1

# These are the links to the source files we need
GMP_URL="https://ftp.gnu.org/gnu/gmp/gmp-6.0.0a.tar.bz2"
MPFR_URL="http://www.mpfr.org/mpfr-current/mpfr-3.1.3.tar.gz"
MPC_URL="ftp://ftp.gnu.org/gnu/mpc/mpc-1.0.3.tar.gz"
ISL_URL="ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.14.tar.bz2"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-5.1.0/gcc-5.1.0.tar.gz"
OPENMPI_URL="http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.6.tar.gz"
BOOST_URL="http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz/download"
HDF5_URL="http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.15-patch1.tar"
NETCDF_URL="ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.1.tar.gz"
TRILINOS_URL="http://trilinos.csbsju.edu/download/files/trilinos-12.0.1-Source.tar.gz"

# The directory that the script was run in -- the base directory that we will 
# install everything to
ROOT_DIR=${PWD}

# Check to see if we own the install directory
if [[ ! -O ${PWD} ]] ; then
	echo "Please check the permission on ${PWD}"
	exit 1
fi

echo "Using ${ROOT_DIR} as root directory"

# The directory to output reports to
REPORT_DIR=${ROOT_DIR}/reports

# Make the reports directory
if [[ ! -d ${REPORT_DIR} ]] ; then
	mkdir -v ${REPORT_DIR}
fi

if [[ -d /dev/shm ]] ; then
   BUILD_DIR=/dev/shm/`whoami`
elif test -d /tmp ; then
   BUILD_DIR=/tmp/`whoami`
else
   BUILD_DIR=${ROOT_DIR}
fi

echo "Using ${BUILD_DIR} as build directory"
mkdir -vp ${BUILD_DIR}

# The directory full of source tar files
T_DIR=${BUILD_DIR}/tarfiles

# Make the tarfiles directory
if [[ ! -d ${T_DIR} ]] ; then
	mkdir -v ${T_DIR}
fi

# Here we download all of the tar files we will need
# The script checks to see if the tarfile already exists.  If it doesn't, it 
# downloads and extracts it.  This makes it so that we don't have to repeatedly
# download tarfiles if the script is run more than once.
# TODO:  Version control for each of the dependencies
[[ ! -e ${T_DIR}/boost.tar.gz ]] && \
	wget -v -O ${T_DIR}/boost.tar.gz ${BOOST_URL} | tee ${REPORT_DIR}/boost_download_report.log && \
	tar -xzf ${T_DIR}/boost.tar.gz -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/hdf5.tar ]] && \
	wget -v -O ${T_DIR}/hdf5.tar ${HDF5_URL} | tee ${REPORT_DIR}/hdf5_download_report.log && \
	tar -xf ${T_DIR}/hdf5.tar -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/netcdf.tar.gz ]] && \
	wget -v -O ${T_DIR}/netcdf.tar.gz ${NETCDF_URL} | tee ${REPORT_DIR}/netcdf_download_report.log && \
	tar -xzf ${T_DIR}/netcdf.tar.gz -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/mpc.tar.gz ]] && \
	wget -v -O ${T_DIR}/mpc.tar.gz ${MPC_URL} | tee ${REPORT_DIR}/mpc_download_report.log && \
	tar -xzf ${T_DIR}/mpc.tar.gz -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/mpfr.tar.gz ]] && \
	wget -v -O ${T_DIR}/mpfr.tar.gz ${MPFR_URL} | tee ${REPORT_DIR}/mpfr_download_report.log && \
	tar -xzf ${T_DIR}/mpfr.tar.gz -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/gmp.tar.bz ]] && \
	wget -v -O ${T_DIR}/gmp.tar.bz ${GMP_URL} | tee ${REPORT_DIR}/gmp_download_report.log && \
	tar -xjf ${T_DIR}/gmp.tar.bz -C ${BUILD_DIR} 
[[ ! -e ${T_DIR}/isl.tar.bz ]] && \
	wget -v -O ${T_DIR}/isl.tar.bz ${ISL_URL} | tee ${REPORT_DIR}/isl_download_report.log && \
	tar -xjf ${T_DIR}/isl.tar.bz -C ${BUILD_DIR}
[[ ! -e ${T_DIR}/trilinos.tar.gz ]] && \
	wget -v -O ${T_DIR}/trilinos.tar.gz ${TRILINOS_URL} | tee ${REPORT_DIR}/trilinos_download_report.log && \
	tar -xzf ${T_DIR}/trilinos.tar.gz -C ${BUILD_DIR}

# The locations that the source files were extracted to
# In order to match and folder to the correct version, we do a search through
# the directories only for the base library name.  We add this to the root 
# directory to get an absolute path to the library.
GMP=`ls ${BUILD_DIR} | grep -m 1 "gmp"`
MPFR=`ls ${BUILD_DIR} | grep -m 1 "mpfr"`
MPC=`ls ${BUILD_DIR} | grep -m 1 "mpc"`
ISL=`ls ${BUILD_DIR} | grep -m 1 "isl"`
BOOST=`ls ${BUILD_DIR} | grep -m 1 "boost"`
HDF5=`ls ${BUILD_DIR} | grep -m 1 "hdf5"`
NETCDF=`ls ${BUILD_DIR} | grep -m 1 "netcdf"`
TRILINOS=`ls ${BUILD_DIR} | grep -m 1 "trilinos"`

#if false; then
# # # # # # # # # # # # # # # #
# GMP
# # # # # # # # # # # # # # # #


echo "---------- GMP    ----------"

export CC=gcc
export CXX=g++

# For safety reasons, we always watch to attempt a fresh install of the
# binaries.  This logic block will remove any previous install of the software.
# TODO: Prompt to skip install if already installed.
#if [[ -d ${BUILD_DIR}/$GMP-bin ]] ; then
#	rm -rv ${BUILD_DIR}/$GMP-bin
#fi

#mkdir -v ${BUILD_DIR}/$GMP-bin
#cd ${BUILD_DIR}/$GMP-bin

#${BUILD_DIR}/$GMP/configure \
#--enable-static \
#--with-pic \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/gmp_configure_report.log

#make | tee ${REPORT_DIR}/gmp_make_report.log
#make check | tee ${REPORT_DIR}/gmp_check_report.log
#make install | tee ${REPORT_DIR}/gmp_install_report.log


# # # # # # # # # # # # # # # #
# MPFR
# # # # # # # # # # # # # # # #


#echo "---------- MPFR   ----------"


# For safety reasons, we always watch to attempt a fresh install of the
# binaries.  This logic block will remove any previous install of the software.
# TODO: Prompt to skip install if already installed.
#if [[ -d ${BUILD_DIR}/${MPFR}-bin ]] ; then
#	rm -r ${BUILD_DIR}/${MPFR}-bin
#fi

#mkdir -v ${BUILD_DIR}/${MPFR}-bin
#cd ${BUILD_DIR}/${MPFR}-bin

#${BUILD_DIR}/${MPFR}/configure \
#--enable-static \
#--with-gmp=${ROOT_DIR} \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/mpfr_configure_report.log

#make | tee ${REPORT_DIR}/mpfr_make_report.log
#make check | tee ${REPORT_DIR}/mpfr_check_report.log
#make install | tee ${REPORT_DIR}/mpfr_install_report.log


# # # # # # # # # # # # # # # #
# MPC
# # # # # # # # # # # # # # # #


echo "---------- MPC    ----------"

#if [[ -d ${BUILD_DIR}/${MPC}-bin ]] ; then
	#rm -r ${BUILD_DIR}/${MPC}-bin
#fi

#mkdir -v ${BUILD_DIR}/${MPC}-bin
#cd ${BUILD_DIR}/${MPC}-bin
#
#${BUILD_DIR}/${MPC}/configure \
#--prefix=${ROOT_DIR} \
#--with-gmp=${ROOT_DIR} \
#--with-mpfr=${ROOT_DIR} | tee ${REPORT_DIR}/mpc_configure_report.log
#
#make | tee ${REPORT_DIR}/mpc_make_report.log
#make check | tee ${REPORT_DIR}/mpc_check_report.log
#make install | tee ${REPORT_DIR}/mpc_install_report.log
#

# # # # # # # # # # # # # # # #
# ISL
# # # # # # # # # # # # # # # #


echo "---------- ISL    ----------"

#if test -d ${BUILD_DIR}/${ISL}-bin ; then
	#rm -r ${BUILD_DIR}/${ISL}-bin
#fi
#
#mkdir -v ${BUILD_DIR}/${ISL}-bin
#cd ${BUILD_DIR}/${ISL}-bin
#
#${BUILD_DIR}/${ISL}/configure \
#--enable-static \
#--with-gmp-prefix=${ROOT_DIR} \
#--without-piplib \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/isl_configure_report.log
#
#make | tee ${REPORT_DIR}/isl_make_report.log
#make check | tee ${REPORT_DIR}/isl_check_report.log
#make install | tee ${REPORT_DIR}/isl_install_report.log


# # # # # # # # # # # # # # # #
# GCC
# # # # # # # # # # # # # # # #


echo "---------- GCC    ----------"


#[[ ! -e ${T_DIR}/gcc.tar.gz ]] && \
	#wget -v -O ${T_DIR}/gcc.tar.gz ${GCC_URL} | tee ${REPORT_DIR}/gcc_download_report.log && \
	#tar -xzf ${T_DIR}/gcc.tar.gz -C ${BUILD_DIR} 

GCC=`ls ${BUILD_DIR} | grep -m 1 "gcc"`

export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${ROOT_DIR}/lib:${ROOT_DIR}/lib64"
echo ${LD_LIBRARY_PATH}

#if test -d ${BUILD_DIR}/${GCC}-bin ; then
	#rm -r ${BUILD_DIR}/${GCC}-bin
#fi
#
#mkdir -v ${BUILD_DIR}/${GCC}-bin
#cd ${BUILD_DIR}/${GCC}-bin
#
##--with-gmp=${ROOT_DIR} \
##--with-mpfr=${ROOT_DIR} \
##--with-mpc=${ROOT_DIR} \
##--with-isl=${ROOT_DIR} \
#${BUILD_DIR}/${GCC}/configure \
#--disable-multilib \
#--enable-languages=c++,c,fortran \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/gcc_configure_report.log
#make | tee ${REPORT_DIR}/gcc_make_report.log
#make install | tee ${REPORT_DIR}/gcc_install_report.log
#


# # # # # # # # # # # # # # # #
# OpenMPI
# # # # # # # # # # # # # # # #


echo "---------- OpenMPI ----------"

export CC=${ROOT_DIR}/bin/gcc
export CXX=${ROOT_DIR}/bin/g++
export FC=${ROOT_DIR}/bin/gfortran

#[[ ! -e ${T_DIR}/openmpi.tar.gz ]] && \
	#wget -v -O ${T_DIR}/openmpi.tar.gz ${OPENMPI_URL} | tee ${REPORT_DIR}/openmpi_download_report.log && \
	#tar -xzf ${T_DIR}/openmpi.tar.gz -C ${BUILD_DIR} 

OPENMPI=`ls ${BUILD_DIR} | grep -m 1 "openmpi"`

#if test -d ${BUILD_DIR}/${OPENMPI}-bin ; then
	#rm -r ${BUILD_DIR}/${OPENMPI}-bin
#fi

#mkdir -v ${BUILD_DIR}/${OPENMPI}-bin
#cd ${BUILD_DIR}/${OPENMPI}-bin

#../${OPENMPI}/configure \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/openmpi_configure_report.log

#make all | tee ${REPORT_DIR}/openmpi_make_report.log
#make check | tee ${REPORT_DIR}/openmpi_check_report.log
#make install | tee ${REPORT_DIR}/openmpi_install_report.log


# # # # # # # # # # # # # # # #
# Boost
# # # # # # # # # # # # # # # #


echo "---------- Boost  ----------"

export CC=${ROOT_DIR}/bin/mpicc
export CXX=${ROOT_DIR}/bin/mpicxx
export FC=${ROOT_DIR}/bin/mpif90
export F77=${ROOT_DIR}/bin/mpif77

if test ! -n ${BOOST} ; then
   echo "uh oh"
   exit 1
fi

cd ${BUILD_DIR}/${BOOST}

# Configure boost
#./bootstrap.sh | tee ${REPORT_DIR}/boost_configure_report.log

#echo asdf
# Check to see if boost is already installed
#./b2 install \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/boost_install_report.log


# # # # # # # # # # # # # # # #
# HDF5
# # # # # # # # # # # # # # # #


echo "---------- HDF5    ----------"

if [[ -d ${BUILD_DIR}/${HDF5}-bin ]] ; then
	rm -r ${BUILD_DIR}/${HDF5}-bin
fi

mkdir -v ${BUILD_DIR}/${HDF5}-bin
cd ${BUILD_DIR}/${HDF5}-bin

#../${HDF5}/configure \
#--enable-parallel \
#--enable-static \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/hdf5_configure_report.log

#make | tee ${REPORT_DIR}/hdf5_make_report.log 
#make check | tee ${REPORT_DIR}/hdf_check_report.log
#make install | tee ${REPORT_DIR}/hdf5_install_report.log


# # # # # # # # # # # # # # # #
#  NetCDF
# # # # # # # # # # # # # # # #


echo "---------- NetCDF  ----------"

export CPPFLAGS="${CPPFLAGS} -I${ROOT_DIR}/include"
export CXXFLAGS=" -std=c++11 -Wall -g"
export LDFLAGS="${LDFLAGS} -L${ROOT_DIR}/lib"


# For safety reasons, we always watch to attempt a fresh install of the
# binaries.  This logic block will remove any previous install of the software.
# TODO: Prompt to skip install if already installed.
if test -d ${BUILD_DIR}/${NETCDF}-bin ; then
	rm -r ${BUILD_DIR}/${NETCDF}-bin
fi

mkdir -v ${BUILD_DIR}/${NETCDF}-bin
cd ${BUILD_DIR}/${NETCDF}-bin

echo "Don't forget to edit the files!"
# TODO: Edit files with script


#../${NETCDF}/configure \
#--disable-netcdf-4 \
##--disable-dap \
#--enable-static \
#--prefix=${ROOT_DIR} | tee ${REPORT_DIR}/netcdf_configure_report.log

#make | tee ${REPORT_DIR}/netcdf_make_report.log
#make check | tee ${REPORT_DIR}/netcdf_check_report.log
#make install | tee ${REPORT_DIR}/netcdf_install_report.log


# # # # # # # # # # # # # # # #
#  matio
# # # # # # # # # # # # # # # #


MATIO=`ls ${BUILD_DIR} | grep -m 1 "matio"`

if [[ -d ${BUILD_DIR}/${MATIO}-bin ]] ; then
   rm -r ${BUILD_DIR}/${MATIO}-bin
fi

mkdir -vp ${BUILD_DIR}/${MATIO}-bin
cd ${BUILD_DIR}/${MATIO}-bin

#../${MATIO}/configure \
#--prefix=${ROOT_DIR}
#
#make
#make check
#make install



# # # # # # # # # # # # # # # #
#  Trilinos
# # # # # # # # # # # # # # # #


# For safety reasons, we always watch to attempt a fresh install of the
# binaries.  This logic block will remove any previous install of the software.
# TODO: Prompt to skip install if already installed.

export CC=${ROOT_DIR}/${OPENMPI}/bin/mpicc
export CXX=${ROOT_DIR}/${OPENMPI}/bin/mpicxx
export FC=${ROOT_DIR}/${OPENMPI}/bin/mpif90
export F77=${ROOT_DIR}/${OPENMPI}/bin/mpif77
export CPPFLAGS="${CPPFLAGS} -I${ROOT_DIR}/include"
export CXXFLAGS=" -std=gnu++0x -Wall -g"
export LDFLAGS="${LDFLAGS} -L${ROOT_DIR}/lib"

if test -d ${BUILD_DIR}/${TRILINOS}-bin ; then
   rm  -vr ${BUILD_DIR}/${TRILINOS}-bin
fi

mkdir -v ${BUILD_DIR}/${TRILINOS}-bin
cd ${BUILD_DIR}/${TRILINOS}-bin

cmake -D CMAKE_INSTALL_PREFIX:PATH=${ROOT_DIR} \
-D MPI_BASE_DIR:PATH="${ROOT_DIR}" \
-D MPI_C_COMPILER:FILEPATH=${ROOT_DIR}/bin/mpicc \
-D MPI_CXX_COMPILER:FILEPATH=${ROOT_DIR}/bin/mpicxx \
-D MPI_Fortran_COMPILER:FILEPATH=${ROOT_DIR}/bin/mpif77 \
-D CMAKE_CXX_FLAGS:STRING="-O2 -ansi -pedantic -ftrapv -Wall -Wno-long-long" \
-D CMAKE_BUILD_TYPE:STRING=RELEASE \
-D Trilinos_WARNINGS_AS_ERRORS_FLAGS:STRING="" \
-D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
-D Trilinos_ENABLE_Teuchos:BOOL=ON \
-D Trilinos_ENABLE_Shards:BOOL=ON \
-D Trilinos_ENABLE_Sacado:BOOL=ON \
-D Trilinos_ENABLE_Epetra:BOOL=ON \
-D Trilinos_ENABLE_EpetraExt:BOOL=ON \
-D Trilinos_ENABLE_Ifpack:BOOL=ON \
-D Trilinos_ENABLE_AztecOO:BOOL=ON \
-D Trilinos_ENABLE_Amesos:BOOL=ON \
-D Trilinos_ENABLE_Anasazi:BOOL=ON \
-D Trilinos_ENABLE_Belos:BOOL=ON \
-D Trilinos_ENABLE_ML:BOOL=ON \
-D Trilinos_ENABLE_Phalanx:BOOL=ON \
-D Trilinos_ENABLE_Intrepid:BOOL=ON \
-D Trilinos_ENABLE_NOX:BOOL=ON \
-D Trilinos_ENABLE_Stratimikos:BOOL=ON \
-D Trilinos_ENABLE_Thyra:BOOL=ON \
-D Trilinos_ENABLE_Rythmos:BOOL=ON \
-D Trilinos_ENABLE_MOOCHO:BOOL=ON \
-D Trilinos_ENABLE_TriKota:BOOL=OFF \
-D Trilinos_ENABLE_Stokhos:BOOL=ON \
-D Trilinos_ENABLE_Zoltan:BOOL=ON \
-D Trilinos_ENABLE_Piro:BOOL=ON \
-D Trilinos_ENABLE_Teko:BOOL=ON \
-D Trilinos_ENABLE_SEACASIoss:BOOL=ON \
-D Trilinos_ENABLE_SEACAS:BOOL=ON \
-D Trilinos_ENABLE_SEACASBlot:BOOL=ON \
-D Trilinos_ENABLE_Pamgen:BOOL=ON \
-D Trilinos_ENABLE_EXAMPLES:BOOL=OFF \
-D Trilinos_ENABLE_TESTS:BOOL=ON \
-D TPL_ENABLE_HDF5:BOOL=ON \
-D HDF5_INCLUDE_DIRS:PATH="${ROOT_DIR}/include" \
-D HDF5_LIBRARY_DIRS:PATH="${ROOT_DIR}/lib" \
-D TPL_ENABLE_Netcdf:BOOL=ON \
-D Netcdf_INCLUDE_DIRS:PATH=${ROOT_DIR}/include \
-D Netcdf_LIBRARY_DIRS:PATH=${ROOT_DIR}/lib \
-D TPL_ENABLE_MPI:BOOL=ON \
-D TPL_ENABLE_BLAS:BOOL=ON \
-D TPL_ENABLE_LAPACK:BOOL=ON \
-D TPL_ENABLE_Boost:BOOL=ON \
-D Boost_INCLUDE_DIRS:PATH=${ROOT_DIR}/include \
-D Boost_LIBRARY_DIRS:PATH=${ROOT_DIR}/lib \
-D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
-D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
-D DH5_USE_16_API:BOOL=ON \
${BUILD_DIR}/${TRILINOS} \
| tee ${REPORT_DIR}/trilinos_configure_report.log
make | tee ${REPORT_DIR}/trilinos_make_report.log
make check | tee ${REPORT_DIR}/trilinos_check_report.log
make install | tee ${REPORT_DIR}/trilinos_install_report.log
echo "Trilinos Installed!"
