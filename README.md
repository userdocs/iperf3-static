
Built on [Alpine linux](https://alpinelinux.org) edge

Static binaries are available here: https://github.com/userdocs/iperf3-static/releases/latest

### Build Platforms

Alpine linux as the host OS.

Builds are created using https://github.com/multiarch/qemu-user-static and arch specific docker images detailed in the table below.

| Alpine Arch | Docker platform arch |  Docker hub image   |
| :---------: | :------------------: | :-----------------: |
|    armhf    |     linux/arm/v6     | arm32v6/alpine:edge |
|    armv7    |     linux/arm/v7     | arm32v7/alpine:edge |
|   aarch64   |     linux/arm64      | arm64v8/alpine:edge |
|   ppc64le   |    linux/ppc64le     | ppc64le/alpine:edge |
|    s390x    |     linux/s390x      |  s390x/alpine:edge  |
|     x86     |      linux/i386      |  i386/alpine:edge   |
|   x86_64    |     linux/amd64      |  amd64/alpine:edge  |

### Generic Build dependencies

~~~
apk add build-base pkgconf autoconf automake curl libtool git perl openssl-libs-static openssl-dev linux-headers
~~~

Debian linux (Cygwin packages will be similar)

~~~
apt install -y build-essential pkg-config automake libtool libssl-dev git perl
~~~

### Generic Build Instructions

Clone the git repo - linux + Cygwin

```bash
git clone https://github.com/esnet/iperf.git ~/iperf3 && cd ~/iperf3
```

Bootstrap - Cygwin only

```bash
./bootstrap.sh
./configure --prefix=$HOME
```

Configure - linux + Cygwin

```bash
./configure --disable-shared --enable-static-bin --prefix=$HOME
```

Build - linux + Cygwin

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
iperf 3.10.1 (cJSON 1.7.13)
Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm setting, sendfile / zerocopy, socket pacing, authentication, bind to device, support IPv4 don't fragment
~~~

### Use the static binaries from this repo

Download and install to the bin directory of your local user (for root this may not be in the `$PATH`)

Pick the platform URL you need:

i386 / x86

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-i386
chmod 700 ~/bin/iperf3
```

amd64

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-amd64
chmod 700 ~/bin/iperf3
```

arm32v6

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-arm32v6
chmod 700 ~/bin/iperf3
```

arm32v7

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-arm32v7
chmod 700 ~/bin/iperf3
```

aarch64 / arm64

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-arm64v8
chmod 700 ~/bin/iperf3
```

ppc64le

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-ppc64le
chmod 700 ~/bin/iperf3
```

s390x

```bash
mkdir -p ~/bin && source ~/.profile
wget -qO ~/bin/iperf3 https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-s390x
chmod 700 ~/bin/iperf3
```

Check the version:

~~~
~/bin/iperf3 -v
~~~