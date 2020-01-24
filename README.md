
Built on Alpine linux 3.11 amd64

### Dependencies

~~~
apk add build-base pkgconf autoconf automake libtool git perl linux-headers
~~~

### Build Instructions

~~~
git clone https://github.com/esnet/iperf.git ~/iperf3
cd ~/iperf3
./configure --disable-shared --enable-static --prefix=$HOME CXXFLAGS="-std=c++14" CPPFLAGS="--static" LDFLAGS="--static"
make -j$(nproc)
make install
~~~

### Version

~~~
iperf 3.7+ (cJSON 1.5.2)
Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm setting, sendfile / zerocopy, socket pacing
~~~