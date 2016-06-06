# seisDD
Double-difference adjoint seismic tomography

YO Yuan, FJ Simons, J Tromp

Geophysical Journal International (2016) accepted for publication

step-to-step instructions:
git clone https://github.com/yanhuay/seisDD
echo '# set seisDD path' >> ~/.bashrc
echo 'export seisDD=/path/of/seisDD' >> ~/.bashrc
source ~/.bashrc
echo $seisDD

cd $seisDD/specfem2d
./configure FC=ifort --with-mpi
make clean
make all

cd $seisDD/seisDD/lib
make -f make_lib clean
make -f make_lib

cd $seisDD/GJI2016/Exp1
./run_this_example.sh
cd submit_job
./submit.sh
python ../../../visualize/plot_bin  ./RESULTS/kernel/Scale0_CC_DD/misfit_kernel/ beta_kernel_smooth 4

