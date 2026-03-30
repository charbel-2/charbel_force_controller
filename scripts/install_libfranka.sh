git clone --recursive https://github.com/frankarobotics/libfranka.git
cd libfranka
git checkout 0.13.3
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo make install
sudo ldconfig
