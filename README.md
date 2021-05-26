
Built on Alpine linux 3.13 amd64

### Dependencies

Alpine linux

~~~
apk add build-base pkgconf autoconf automake libtool git perl openssl-dev linux-headers
~~~

Debian linux

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

### Check the linking was done properly.

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
iperf 3.7+ (cJSON 1.5.2)
Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm setting, sendfile / zerocopy, socket pacing
~~~

### Use the static binary in this repo.

Download and install to the bin directory of your local user (for root this may not be in the `$PATH`)

~~~
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/raw/master/bin/iperf3
chmod 700 ~/bin/iperf3
~~~

Check the version:

~~~
~/bin/iperf3 -v
~~~