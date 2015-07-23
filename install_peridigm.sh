#!/bin/bash

# Author:  Ryan Murphy, June 2015
# 
# This script was built to install Peridigm and its dependencies locally.

# If any command fails, exit the script
set -e

export CC=mpicc
export CXX=mpicxx
export FC=mpif90
export F77=mpif77
export LIBS=-ldl

# The directory that the script was run in -- the base directory that we will 
# install everything to
ROOT_DIR=${PWD}
# The directory to output reports to
R_DIR=${ROOT_DIR}/reports
# The directory full of source tar files
T_DIR=${ROOT_DIR}/tarfiles

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
TRININOS_URL="http://trilinos.csbsju.edu/download/files/trilinos-12.0.1-Source.tar.gz"
CLOOR_URL="ftp://ftp.irisa.fr/pub/mirrors/gcc.gnu.org/gcc/infrastructure/cloog-0.18.0.tar.gz"

# Check to see if we own the install directory
if [[ ! -O ${PWD} ]] ; then
	echo "Please check the permission on ${PWD}"
	exit 1
fi

# Make the tarfiles directory
if [[ ! -d ${T_DIR} ]] ; then
	mkdir -v ${T_DIR}
fi

# Make the reports directory
if [[ ! -d ${R_DIR} ]] ; then
	mkdir -v ${R_DIR}
fi

# Here we download all of the tar files we will need

[[ ! -e ${T_DIR}/gcc.tar.gz ]] && \
	wget -v -O ${T_DIR}/gcc.tar.gz ${GCC_URL} | tee ${R_DIR}/gcc_download_report.txt && \
	tar -xzvf ${T_DIR}/gcc.tar.gz
[[ ! -e ${T_DIR}/boost.tar.gz ]] && \
	wget -v -O ${T_DIR}/boost.tar.gz ${BOOST_URL} | tee ${R_DIR}/boost_download_report.txt && \
	tar -xzvf ${T_DIR}/boost.tar.gz
[[ ! -e ${T_DIR}/openmpi.tar.gz ]] && \
	wget -v -O ${T_DIR}/openmpi.tar.gz ${OPENMPI_URL} | tee ${R_DIR}/openmpi_download_report.txt && \
	tar -xzvf ${T_DIR}/openmpi.tar.gz
[[ ! -e ${T_DIR}/hdf5.tar ]] && \
	wget -v -O ${T_DIR}/hdf5.tar ${HDF5_URL} | tee ${R_DIR}/hdf5_download_report.txt && \
	tar -xf tarfiles/hdf5.tar
[[ ! -e ${T_DIR}/netcdf.tar.gz ]] && \
	wget -v -O ${T_DIR}/netcdf.tar.gz ${NETCDF_URL} | tee ${R_DIR}/netcdf_download_report.txt && \
	tar -xzf ${T_DIR}/netcdf.tar.gz
[[ ! -e ${T_DIR}/mpc.tar.gz ]] && \
	wget -v -O ${T_DIR}/mpc.tar.gz ${MPC_URL} | tee ${R_DIR}/mpc_download_report.txt && \
	tar -xzvf ${T_DIR}/mpc.tar.gz
[[ ! -e ${T_DIR}/mpfr.tar.gz ]] && \
	wget -v -O ${T_DIR}/mpfr.tar.gz ${MPFR_URL} | tee ${R_DIR}/mpfr_download_report.txt && \
	tar -xzvf ${T_DIR}/mpfr.tar.gz
[[ ! -e ${T_DIR}/gmp.tar.bz ]] && \
	wget -v -O ${T_DIR}/gmp.tar.bz ${GMP_URL} | tee ${R_DIR}/gmp_download_report.txt && \
	tar -xjvf ${T_DIR}/gmp.tar.bz
[[ ! -e ${T_DIR}/isl.tar.bz ]] && \
	wget -v -O ${T_DIR}/isl.tar.bz ${ISL_URL} | tee ${R_DIR}/isl_download_report.txt && \
	tar -xjvf ${T_DIR}/isl.tar.bz
#[[ ! -e ${T_DIR}/cloog.tar.gz ]] && \
	#wget -v -O ${T_DIR}/cloog.tar.gz ${CLOOR_URL} | tee ${R_DIR}/cloog_download_report.txt && \
	#tar -xzvf ${T_DIR}/cloog.tar.gz
#[[ ! -e ${T_DIR}/libelf.tar.gz ]] && \
	#wget -v -O ${T_DIR}/libelf.tar.gz ${ELF_URL} | tee ${R_DIR}/gmp_download_report.txt && \
	#tar -xzvf ${T_DIR}/libelf.tar.gz

# The locations that the source files were extracted to
GMP_DIR=${ROOT_DIR}/`ls | grep -m 1 "gmp"`
MPFR_DIR=${ROOT_DIR}/`ls | grep -m 1 "mpfr"`
MPC_DIR=${ROOT_DIR}/`ls | grep -m 1 "mpc"`
ISL_DIR=${ROOT_DIR}/`ls | grep -m 1 "isl"`
GCC_DIR=${ROOT_DIR}/`ls | grep -m 1 "gcc"`
BOOST_DIR=${ROOT_DIR}/`ls | grep -m 1 "boost"`
HDF5_DIR=${ROOT_DIR}/`ls | grep -m 1 "hdf5"`
NETCDF_DIR=${ROOT_DIR}/`ls | grep -m 1 "netcdf"`


#if false ; then
# # # # # # # # # # # # # # # #
# GMP
# # # # # # # # # # # # # # # #


echo "---------- GMP    ----------"
cd ${ROOT_DIR}

if [[ -d $GMP_DIR-bin ]] ; then
	rm -r $GMP_DIR-bin
	mkdir -v ${GMP_DIR}-bin
else
	mkdir -v ${GMP_DIR}-bin
fi

cd ${GMP_DIR}

./configure \
--disable-shared \
--enable-static \
--prefix=${GMP_DIR}-bin | tee ${R_DIR}/gmp_configure_report.txt

make | tee ${R_DIR}/gmp_make_report.txt
make check | tee ${R_DIR}/gmp_check_report.txt
make install | tee ${R_DIR}/gmp_install_report.txt

cd ${ROOT_DIR}


# # # # # # # # # # # # # # # #
# MPFR
# # # # # # # # # # # # # # # #


echo "---------- MPFR   ----------"
cd ${ROOT_DIR}

if [[ -d $MPFR_DIR-bin ]] ; then
	rm -r $MPFR_DIR-bin
	mkdir -v ${MPFR_DIR}-bin
else
	mkdir -v ${MPFR_DIR}-bin
fi

cd ${MPFR_DIR}

./configure \
--disable-shared \
--enable-static \
--with-gmp=${GMP_DIR} \
--prefix=${MPFR_DIR}-bin | tee ${R_DIR}/mpfr_configure_report.txt

make | tee ${R_DIR}/mpfr_make_report.txt
make check | tee ${R_DIR}/mpfr_check_report.txt
make install | tee ${R_DIR}/mpfr_install_report.txt

cd ${ROOT_DIR}


# # # # # # # # # # # # # # # #
# MPC
# # # # # # # # # # # # # # # #


echo "---------- MPC    ----------"
cd ${MPC_DIR}

if [[ -d $MPC_DIR-bin ]] ; then
	rm -r $MPC_DIR-bin
	mkdir -v ${MPC_DIR}-bin
else mkdir -v ${MPC_DIR}-bin
fi

./configure \
--disable-shared \
--enable-static \
--prefix=${MPC_DIR}-bin \
--with-gmp=${GMP_DIR}-bin \
--with-mpfr=${MPFR_DIR}-bin | tee ${R_DIR}/mpc_configure_report.txt

make | tee ${R_DIR}/mpc_make_report.txt
make check | tee ${R_DIR}/mpc_check_report.txt
make install | tee ${R_DIR}/mpc_install_report.txt


# # # # # # # # # # # # # # # #
# ISL
# # # # # # # # # # # # # # # #


echo "---------- ISL    ----------"
cd ${ISL_DIR}

if test -d ${ISL_DIR}-bin ; then
	rm -r ${ISL_DIR}-bin
	mkdir -v ${ISL_DIR}-bin
else
	mkdir -v ${ISL_DIR}-bin
fi

./configure \
--with-gmp-prefix=${GMP_DIR}-bin \
--without-piplib --disable-shared \
--enable-static \
--prefix=${ISL_DIR}-bin | tee ${R_DIR}/isl_configure_report.txt

make | tee ${R_DIR}/isl_make_report.txt
make install | tee ${R_DIR}/isl_install_report.txt

exit 0

#fi


# # # # # # # # # # # # # # # #
# GCC
# # # # # # # # # # # # # # # #


echo "---------- GCC    ----------"
cd ${GCC_DIR}

if test -d ${GCC_DIR}-bin ; then
	rm -r ${GCC_DIR}-bin
	mkdir -v ${GCC_DIR}-bin
else
	mkdir -v ${GCC_DIR}-bin
fi

./configure \
--disable-shared \
--disable-multilib \
--enable-static \
--with-gmp=${GMP_DIR}-bin \
--with-mpfr=${MPFR_DIR}-bin \
--with-mpc=${MPC_DIR}-bin \
--with-isl=${ISL_DIR}-bin \
--prefix=${GCC_DIR}-bin | tee ${R_DIR}/gcc_configure_report.txt


cp -R ${GCC_DIR} ../tarfiles/

make | tee ${R_DIR}/gcc_make_report.txt
make install | tee ${R_DIR}/gcc_install_report.txt

echo "Success!"
exit 0


# # # # # # # # # # # # # # # #
# Boost
# # # # # # # # # # # # # # # #


echo "---------- Boost  ----------"
cd ${BOOST_DIR}

if test -d ${BOOST_DIR}-bin ; then
	rm -r ${BOOST_DIR}-bin
	mkdir -v ${BOOST_DIR}-bin
else
	mkdir -v ${BOOST_DIR}-bin
fi

# Configure boost
./bootstrap.sh | tee ${R_DIR}/boost_configure_report.txt

# Check to see if boost is already installed
./b2 install \
--prefix=${BOOST_DIR}-bin | tee ${R_DIR}/install_report.txt


# # # # # # # # # # # # # # # #
# OpenMPI
# # # # # # # # # # # # # # # #


echo "---------- OpenMPI ----------"
cd ${OPENMPI_DIR}

if test -d ${OPENMPI_DIR}-bin ; then
	rm -r ${OPENMPI_DIR}-bin
	mkdir -v ${OPENMPI_DIR}-bin
else
	mkdir -v ${OPENMPI_DIR}-bin
fi

./configure \
--disable-shared \
--enable-static \
--prefix=${OPENMPI_DIR}-bin | tee ${R_DIR}/openmpi_configure_report.txt

make all | tee ${R_DIR}/openmpi_make_report.txt
make install | tee ${R_DIR}/openmpi_install_report.txt

export CC=${ROOT_DIR}/openmpi-bin/bin/mpicc
export CXX=${ROOT_DIR}/openmpi-bin/bin/mpicxx
export FC=${ROOT_DIR}/openmpi-bin/bin/mpif90
export F77=${ROOT_DIR}/openmpi-bin/bin/mpif77


# # # # # # # # # # # # # # # #
# HDF5
# # # # # # # # # # # # # # # #


echo "---------- HDF5    ----------"
cd ${HDF5_DIR}

if [[ -d ${HDF5_DIR}-bin ]] ; then
	rm -r ${HDF5_DIR}-bin
	mkdir -v ${HDF5_DIR}-bin
else
	mkdir -v ${HDF5_DIR}-bin
fi

./configure \
--disable-shared \
--enable-parallel \
--prefix=${HDF5_DIR}-bin | tee ${R_DIR}/hdf5_configure_report.txt

make | tee $R_DIR/hdf5_make_report.txt 
make install | tee $R_DIR/hdf5_install_report.txt

export CPPFLAGS=-I$HDF5_DIR-bin/include
export LDFLAGS=-L$HDF5_DIR-bin/lib


# # # # # # # # # # # # # # # #
#  NetCDF
# # # # # # # # # # # # # # # #


echo "---------- NetCDF  ----------"
cd ${ROOT_DIR}

if test -d ${NETCDF_DIR}-bin ; then
	rm -r ${NETCDF_DIR}-bin
	mkdir -v ${NETCDF_DIR}-bin
else
	mkdir -v ${NETCDF_DIR}-bin
fi

echo "Don't forget to edit the files!"
exit 0
# TODO: Edit files with script
cd ${NETCDF_DIR}

./configure \
-disable-netcdf-4 \
--disable-shared \
--enable-static \
--disable-dap \
--enable-parallel-test \
--prefix=${ROOT_DIR}/netcdf/ | tee ${R_DIR}/netcdf_configure_report.txt

make | tee ${R_DIR}/netcdf_make_report.txt
make check | tee ${R_DIR}/netcdf_check_report.txt
make install | tee ${R_DIR}/netcdf_install_report.txt

cd ${ROOT_DIR}
exit 0


# # # # # # # # # # # # # # # #
#  Trilinos
# # # # # # # # # # # # # # # #


cd ${TRILINOS_DIR}

rm -f CMakeCache.txt

cmake -D CMAKE_INSTALL_PREFIX:PATH=${ROOT_DIR}/trilinos-12.0.1 \
-D MPI_BASE_DIR:PATH="${OPENMPI_DIR}-bin/" \
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
-D HDF5_INCLUDE_DIRS:PATH="${HDF5_DIR}-bin/include" \
-D HDF5_LIBRARY_DIRS:PATH="${HDF5_DIR}-bin/lib" \
-D TPL_ENABLE_Netcdf:BOOL=ON \
-D Netcdf_INCLUDE_DIRS:PATH=${NETCDF_DIR}-bin/include \
-D Netcdf_LIBRARY_DIRS:PATH=${NETCDF_DIR}-bin/lib \
-D TPL_ENABLE_MPI:BOOL=ON \
-D TPL_ENABLE_BLAS:BOOL=ON \
-D TPL_ENABLE_LAPACK:BOOL=ON \
-D TPL_ENABLE_Boost:BOOL=ON \
-D Boost_INCLUDE_DIRS:PATH=${BOOST_DIR}-bin/include \
-D Boost_LIBRARY_DIRS:PATH=${BOOST_DIR}-bin/lib \
-D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
-D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
-D DH5_USE_16_API:BOOL=ON \
${ROOT_DIR}/trilinos-12.0.1-Source \
| tee configure_report.txt
make | tee make_report.txt
make install | tee install_report.txt
echo "Trilinos Installed!"

cd ..
echo "${L_PRINT}${PWD}"

exit 0
