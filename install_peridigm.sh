#!/bin/bash

# Author:  Ryan Murphy, June 2015
# 
# This script was built to install Peridigm and its dependencies locally.

export CC=mpicc && echo "export CC=mpicc"
export CXX=mpicxx && echo "export CXX=mpicxx"
export FC=mpif90 && echo "export FC=mpif90"
export F77=mpif77 && echo "export F77=mpif77"
export B_DIR=${PWD} && echo "export B_DIR=${PWD}"
export H5DIR=${B_DIR}/hdf5/ && echo "export H5DIR=${B_DIR}/hdf5/"
export CPPFLAGS="-I${H5DIR}/include" && echo "export CPPFLAGS="-I${H5DIR}/include""
export LDFLAGS=-L${H5DIR}/lib && echo "export LDFLAGS=-L${H5DIR}/lib"
export LIBS=-ldl && echo "export LIBS=-ldl"

E_PRINT="Entering directory: "

# # # # # # # # # # # # #
# Boost
# # # # # # # # # # # # #

# Check to see if we own the install directory
if [[ ! -O ${PWD} ]] ; then
	echo "Please check the permission on ${PWD}"
	exit 1
fi

# Check to see if we have the most recent version of boost
if [[ -d `ls | grep boost_` ]] ; then
	echo "Success!"
	# TODO: Check if this is the most recent version of boost
	# TODO: Prompt reconfigure of boost
	# TODO: Prompt redownload of boost
fi

# Configure boost
cd boost_1_58_0 && \
echo "${E_PRINT}boost_1_58_0/"
./bootstrap.sh > configure_report.txt || exit 1
echo "Boost configured!"

# Check to see if boost is already installed
if [[ -d boost ]] ; then
	read -p "Reinstall boost? [y/N]  " INPUT
	# TODO: Use prompt to decide
	rm -r boost/*
else
	mkdir -v boost
fi

# Install boost
./b2 install --prefix=${B_DIR}/boost > install_report.txt || exit 1
echo "Boost installed!"

# TODO: Get links for downloads for tarfiles
cp tarfiles/hdf5-1.8.15-patch1.tar .
tar -xvf hdf5-1.8.15-patch1.tar

cd hdf5-1.8.15-patch1
echo "${E_PRINT}${PWD}"

echo "Configuring hdf5"
./configure --prefix=${H5DIR} --enable-parallel > configure_report.txt || exit 1
echo "hdf5 Configured!"

echo "Installing hdf5"
make > make_report.txt && make install > install_report.txt || exit 1
echo "hdf5 installed!"

echo "${L_PRINT}${PWD}"
cd ..

cd netcdf-4.3.3.1
echo "${E_PRINT}${PWD}"

echo "Configuring netcdf"
./configure --prefix=${B_DIR}/netcdf/ -disable-netcdf-4 --disable-shared --disable-dap --enable-parallel-tests > configure_report.txt || exit 1
echo "Netcdf configured!"

echo "Making netcdf"
make && > make_report.txt || exit 1
make check > check_report.txt || exit 1

echo "Installing Netcdf"
make install > install_report.txt || exit 1
echo "NetCDF Installed!"

echo "${L_PRINT}${PWD}"
cd ..

cd trilinos-12.0.1
echo "${E_PRINT}${PWD}"

echo "Configuring Trilinos"

rm -f CMakeCache.txt

cmake -D CMAKE_INSTALL_PREFIX:PATH=${B_DIR}/trilinos-12.0.1 \
-D MPI_BASE_DIR:PATH="/usr/local/openmpi/" \
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
> configure_report.txt && \
make > make_report.txt && \
make install > install_report.txt && \
echo "Trilinos Installed!"

cd ..
echo "${L_PRINT} peridigm_2"

exit 0
