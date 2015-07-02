export CC=mpicc
echo "export CC=mpicc"
export CXX=mpicxx
echo "export CXX=mpicxx"
export FC=mpif90
echo "export FC=mpif90"
export F77=mpif77
echo "export F77=mpif77"
export PERIDIGM_DIRECTORY=/home2/ratliff2/try1/peridigm_2
echo "export PERIDIGM_DIRECTORY=/home2/ratliff2/try1/peridigm_2"
export H5DIR=${PERIDIGM_DIRECTORY}/hdf5/
echo "export H5DIR=${PERIDIGM_DIRECTORY}/hdf5/"
export CPPFLAGS="-I${H5DIR}/include"
echo "export CPPFLAGS="-I${H5DIR}/include""
export LDFLAGS=-L${H5DIR}/lib
echo "export LDFLAGS=-L${H5DIR}/lib"
export LIBS=-ldl
echo "export LIBS=-ldl"

mkdir -v hdf5
mkdir -v netcdf

cp tarfiles/hdf5-1.8.15-patch1.tar .
tar -xvf hdf5-1.8.15-patch1.tar

cd hdf5-1.8.15-patch1
echo "Changing Directory: hdf5-1.8.15-patch1"
echo "Configuring hdf5"
./configure --prefix=${H5DIR} --enable-parallel > configure_report.txt || echo "hdf5 failed to configure"
echo "Installing hdf5"
make > make_report.txt && make install > install_report.txt && echo "hdf5 installed!"
cd ..
echo "Changing Directory: peridigm_2"

cd netcdf-4.3.3.1
echo "Changing Directory: netcdf-4.3.3.1"

echo "Configuring netcdf"
./configure --prefix=${PERIDIGM_DIRECTORY}/netcdf/ -disable-netcdf-4 --disable-shared --disable-dap --enable-parallel-tests > configure_report.txt || echo "Peridigm failed to configure"

echo "Installing Netcdf"
make && > make_report.txt && make check > check_report.txt && make install > install_report.txt && echo "NetCDF Installed!"

cd ..
echo "Changing Directory: peridigm_2"

cd trilinos-12.0.1
echo "Changing Directory: trilinos-12.0.1"

echo "Configuring Trilinos"

rm -f CMakeCache.txt

cmake -D CMAKE_INSTALL_PREFIX:PATH=${PERIDIGM_DIRECTORY}/trilinos-12.0.1 \
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
-D HDF5_INCLUDE_DIRS:PATH="${PERIDIGM_DIRECTORY}/hdf5/include" \
-D HDF5_LIBRARY_DIRS:PATH="${PERIDIGM_DIRECTORY}/hdf5/lib" \
-D TPL_ENABLE_Netcdf:BOOL=ON \
-D Netcdf_INCLUDE_DIRS:PATH=${PERIDIGM_DIRECTORY}/netcdf/include \
-D Netcdf_LIBRARY_DIRS:PATH=${PERIDIGM_DIRECTORY}/netcdf/lib \
-D TPL_ENABLE_MPI:BOOL=ON \
-D TPL_ENABLE_BLAS:BOOL=ON \
-D TPL_ENABLE_LAPACK:BOOL=ON \
-D TPL_ENABLE_Boost:BOOL=ON \
-D Boost_INCLUDE_DIRS:PATH=${PERIDIGM_DIRECTORY}/boost_1_58_0-bin/include \
-D Boost_LIBRARY_DIRS:PATH=${PERIDIGM_DIRECTORY}/boost_1_58_0-bin/lib \
-D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
-D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
-D DH5_USE_16_API:BOOL=ON \
${PERIDIGM_DIRECTORY}/trilinos-12.0.1-Source \
> configure_report.txt && \
make > make_report.txt && \
make install > install_report.txt && \
echo "Trilinos Installed!"

cd ..
echo "Changing Directory: peridigm_2"
