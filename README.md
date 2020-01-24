
Built on ALpine linux.

~~~
apk add build-base pkgconf autoconf automake libtool git perl linux-headers
~~~

~~~
git clone https://github.com/esnet/iperf.git ~/iperf3
cd ~/iperf3
./configure --disable-shared --enable-static --prefix=$HOME CXXFLAGS="-std=c++14" CPPFLAGS="--static" LDFLAGS="--static"
make -j$(nproc)
make install
~~~