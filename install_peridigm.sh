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
export B_DIR=${PWD}
export H5DIR=${B_DIR}/hdf5/
export CPPFLAGS="-I${H5DIR}/include"
export LDFLAGS=-L${H5DIR}/lib
export LIBS=-ldl

# The directory to output reports to
R_DIR=${B_DIR}/reports
# The directory full of source tar files
T_DIR=${B_DIR}/tarfiles

GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-5.1.0/gcc-5.1.0.tar.gz"
BOOST_URL="http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz/download"
OPENMPI_URL="http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.6.tar.gz"
HDF5_URL="http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.15-patch1.tar"
NETCDF_URL="ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.3.3.1.tar.gz"
TRININOS_URL=""

E_PRINT="Entering directory: "
L_PRINT="Leaving directory: "

# Check to see if we own the install directory
if [[ ! -O ${PWD} ]] ; then
	echo "Please check the permission on ${PWD}"
	exit 1
fi

# Make the reports directory
if [[ ! -d ${T_DIR} ]] ; then
	mkdir -v ${T_DIR}
fi

# Make the tarfiles directory
if [[ ! -d ${R_DIR} ]] ; then
	mkdir -v ${R_DIR}
fi


# # # # # # # # # # # # # # # #
# GCC
# # # # # # # # # # # # # # # #


echo "---------- GCC    ----------"
wget -v -O ${T_DIR}/gcc.tar.gz ${GCC_URL} | tee ${R_DIR}/gcc_download_report.txt
echo "Downloaded"

tar -xzvf ${T_DIR}/gcc.tar.gz
echo "Extracted"

mkdir -v gcc-bin

cd gcc-bin
echo "${E_PRINT}${PWD}"

../gcc-1.5.0/configure --prefix=${B_DIR}/gcc-bin --disable-shared | tee ${R_DIR}/gcc_configure_report.txt
make -j 2 | tee ${R_DIR}/gcc_make_report.txt
echo "Made"
make install | tee ${R_DIR}/gcc_install_report.txt
echo "Installed!"

exit 0


# # # # # # # # # # # # # # # #
# Boost
# # # # # # # # # # # # # # # #


echo "---------- Boost  ----------"
# Check to see if we have the most recent version of boost
if [[ -d `ls | grep boost_` ]] ; then
	echo "Nada"
	# TODO: Check if this is the most recent version of boost
	# TODO: Prompt reconfigure of boost
	# TODO: Prompt redownload of boost
fi

wget -v -o ${R_DIR}/boost_download_report.txt -O ${T_DIR}/boost.tar.gz ${BOOST_URL}
echo "Downloaded"

tar -xzvf ${T_DIR}/boost.tar.gz -C ${B_DIR} > /dev/null
echo "Extracted"

# TODO: Automate this for any version of boost
cd boost_1_58_0 
echo "${E_PRINT}${PWD}"

# Configure boost
./bootstrap.sh > ${R_DIR}/boost_configure_report.txt
echo "Configured"

# Check to see if boost is already installed
if [[ -d ${B_DIR}/boost ]] ; then
	#read -p "Reinstall boost? [y/N]  " BOOST_CONFIRM
	# TODO: Use prompt to decide
	#rm -r ${B_DIR}/boost
	mkdir -v ${B_DIR}/boost
else
	mkdir -v ${B_DIR}/boost
fi


# Install boost
./b2 install --prefix=${B_DIR}/boost > ${R_DIR}/install_report.txt
echo "Installed!\n"


# # # # # # # # # # # # # # # #
# OpenMPI
# # # # # # # # # # # # # # # #


echo "---------- OpenMPI ----------"

echo "${L_PRINT}${PWD}"
cd ${B_DIR}

wget -v -O ${T_DIR}/openmpi.tar.gz ${OPENMPI_URL} | tee ${R_DIR}/openmpi_download_report.txt
echo "Downloaded"

tar -xzvf ${T_DIR}/openmpi.tar.gz
echo "Extracted"

cd openmpi-1.8.6
echo "${E_PRINT}${PWD}"

# Checking to see if openmpi is already installed
if [[ -d ${B_DIR}/openmpi-bin ]] ; then
	# TODO: Prompt to confirm reinstall
	#rm -r ${B_DIR}/openmpi-bin
	mkdir -v ${B_DIR}/openmpi-bin
else
	mkdir -v ${B_DIR}/openmpi-bin
fi

./configure --prefix="${B_DIR}/openmpi-bin" --disable-shared --enable-static | tee ${R_DIR}/openmpi_configure_report.txt
echo "Configured"

make all | tee ${R_DIR}/openmpi_make_report.txt
echo "Made"
make install | tee ${R_DIR}/openmpi_install_report.txt
echo "Installed!\n"

export CC=${B_DIR}/openmpi-bin/bin/mpicc
export CXX=${B_DIR}/openmpi-bin/bin/mpicxx
export FC=${B_DIR}/openmpi-bin/bin/mpif90
export F77=${B_DIR}/openmpi-bin/bin/mpif77

exit 0
# # # # # # # # # # # # # # # #
# HDF5
# # # # # # # # # # # # # # # #


echo "---------- HDF5    ----------"

echo "${L_PRINT}${PWD}"
cd ${B_DIR}

wget -v -o ${R_DIR}/hdf5_download_report.txt -O ${T_DIR}/hdf5.tar ${HDF5_URL}
echo "Downloaded"

tar -xf tarfiles/hdf5.tar
echo "Extracted"

cd hdf5-1.8.15-patch1
echo "${E_PRINT}${PWD}"

# TODO: Why am I using a var for this?
if [[ -d ${H5DIR} ]] ; then
	rm -r ${H5DIR}
	mkdir -v ${H5DIR}
else
	mkdir -v ${H5DIR}
fi

./configure --prefix=${H5DIR} --enable-parallel > configure_report.txt
echo "Configured"

make > make_report.txt 
make install > install_report.txt
echo "Installed!"


# # # # # # # # # # # # # # # #
#  NetCDF
# # # # # # # # # # # # # # # #


echo "---------- NetCDF  ----------"

echo "${L_PRINT}${PWD}"
cd ${B_DIR}

wget -v -o ${B_DIR}/netcdf_download_report.txt -O ${T_DIR}/netcdf.tar.gz ${NETCDF_URL}
echo "Downloaded"

tar -xzf ${T_DIR}/netcdf.tar.gz
echo "Extracted"

echo "Don't forget to edit the files!"
# TODO: Edit files with script
exit 0
cd netcdf-4.3.3.1
echo "${E_PRINT}${PWD}"

if [[ -d ${B_DIR}/netcdf ]] ; then
	rm -r ${B_DIR}/netcdf
	mkdir -v ${B_DIR}/netcdf
else
	mkdir -v ${B_DIR}/netcdf
fi

./configure --prefix=${B_DIR}/netcdf/ -disable-netcdf-4 --disable-shared --disable-dap --enable-parallel-tests > ${R_DIR}/netcdf_configure_report.txt
echo "Netcdf configured!"

echo "Making netcdf"
make > ${R_DIR}/netcdf_make_report.txt
make check > ${R_DIR}/netcdf_check_report.txt

make install > ${R_DIR}/netcdf_install_report.txt
echo "Installed!"

echo "${L_PRINT}${PWD}"
cd ${B_DIR}


# # # # # # # # # # # # # # # #
#  Trilinos
# # # # # # # # # # # # # # # #


echo "${L_PRINT}${PWD}"
cd ${B_DIR}

cd trilinos-12.0.1
echo "${E_PRINT}${PWD}"

echo "Configuring Trilinos"

rm -f CMakeCache.txt

cmake -D CMAKE_INSTALL_PREFIX:PATH=${B_DIR}/trilinos-12.0.1 \
-D MPI_BASE_DIR:PATH="${B_DIR}/openmpi-bin/" \
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
-D HDF5_INCLUDE_DIRS:PATH="${B_DIR}/hdf5/include" \
-D HDF5_LIBRARY_DIRS:PATH="${B_DIR}/hdf5/lib" \
-D TPL_ENABLE_Netcdf:BOOL=ON \
-D Netcdf_INCLUDE_DIRS:PATH=${B_DIR}/netcdf/include \
-D Netcdf_LIBRARY_DIRS:PATH=${B_DIR}/netcdf/lib \
-D TPL_ENABLE_MPI:BOOL=ON \
-D TPL_ENABLE_BLAS:BOOL=ON \
-D TPL_ENABLE_LAPACK:BOOL=ON \
-D TPL_ENABLE_Boost:BOOL=ON \
-D Boost_INCLUDE_DIRS:PATH=${B_DIR}/boost_1_58_0-bin/include \
-D Boost_LIBRARY_DIRS:PATH=${B_DIR}/boost_1_58_0-bin/lib \
-D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
-D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
-D DH5_USE_16_API:BOOL=ON \
${B_DIR}/trilinos-12.0.1-Source \
> configure_report.txt
make > make_report.txt
make install > install_report.txt
echo "Trilinos Installed!"

cd ..
echo "${L_PRINT}${PWD}"

exit 0
