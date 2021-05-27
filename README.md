
Built on Alpine linux 3.13 amd64

### Dependencies

Alpine linux (recommended)

~~~
apk add build-base pkgconf autoconf automake curl libtool git perl openssl-libs-static openssl-dev linux-headers
~~~

Debian linux (Cygwin packages will be similar)

~~~
apt install -y build-essential pkg-config automake libtool libssl-dev git perl
~~~

### Build Instructions

```bash
git clone https://github.com/esnet/iperf.git ~/iperf3 && cd ~/iperf3
```

Cygiwn

```bash
./bootstrap.sh
./configure --prefix=$HOME
```

linux

```bash
./configure --disable-shared --enable-static-bin --prefix=$HOME
```

Build

```
make -j$(nproc)
make install
```

### Check the linking was done properly

~~~
ldd ~/bin/iperf3
~~~

### Version

Use this command to check the version.

~~~
~/bin/iperf3 -v
~~~

Will show something like this.

~~~
iperf 3.10 (cJSON 1.7.13)
Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm setting, sendfile / zerocopy, socket pacing, authentication, bind to device, support IPv4 don't fragment
~~~

### Use the static binary in this repo

Download and install to the bin directory of your local user (for root this may not be in the `$PATH`)

x86_64

~~~
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/x86_64_iperf3
chmod 700 ~/bin/iperf3
~~~

aarch64

~~~
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/aarch64_iperf3
chmod 700 ~/bin/iperf3
~~~

Check the version:

~~~
~/bin/iperf3 -v
~~~