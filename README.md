# iperf3 static builds

Built on:

- [Alpine linux](https://alpinelinux.org) edge via arch emulation
- Windows via Github Actions runners for x86_64

Static binaries are available here: https://github.com/userdocs/iperf3-static/releases/latest

## Build Platforms

- Alpine - all supported architectures
- Windows - x86_64

### Alpine linux as the host OS

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

### Windows

Static Cygwin builds created via cygwin64 using this action

https://github.com/cygwin/cygwin-install-action

### Credits and acknowledgements

Some awesome people's contributions have helped inspire the creation of a Github action for Windows build and release. It would not have happened withouth the contributions of these users in providing iperf3 builds for Windows. So thank you, to you both.

They are available for x86_64 in two versions.

- basic (without openssl)
- openssl

[www.neowin.net](https://www.neowin.net/forum/topic/1234695-iperf-313-windows-build) via [budman](https://www.neowin.net/forum/profile/14624-budman/)

https://github.com/ar51an/iperf3-win-builds via [cryptanalyst](https://www.neowin.net/forum/profile/170754-cryptanalyst/)

I used the [budman](https://www.neowin.net/forum/profile/14624-budman/) builds originally before making my own for another project.

### Generic Build dependencies

```
apk add build-base pkgconf autoconf automake curl libtool git perl openssl-libs-static openssl-dev linux-headers
```

#### Debian linux

```
apt install -y build-essential pkg-config automake libtool libssl-dev git perl
```

#### Cygwin packages

Without openssl

```bash
automake,gcc-core,gcc-g++,git,libtool,make,pkg-config
```

With openssl

```bash
automake,gcc-core,gcc-g++,git,libtool,make,pkg-config,libssl-devel,zlib-devel
```

### Generic Build Instructions

Clone the git repo - linux + Cygwin

```bash
git clone https://github.com/esnet/iperf.git ~/iperf3 && cd ~/iperf3
```

Bootstrap - If you cloned the repo

```bash
./bootstrap.sh
```

Configure - linux + Cygwin

Note: Cygwin requires requires compiling openssl and zlib static libs to link statically. Otherwise you compile dynamically

Static

```bash
./configure --disable-shared --enable-static-bin --prefix=$HOME
```

Dynamic

```bash
./configure --prefix=$HOME
```

Cygwin openssl requires compiling openssl and zlib

Build - linux + Cygwin

```
make -j$(nproc)
make install
```

### Check the linking was done properly

```
ldd ~/bin/iperf3
```

### Version

Use this command to check the version.

```
~/bin/iperf3 -v
```

Will show something like this.

```
iperf 3.10.1 (cJSON 1.7.13)
Optional features available: CPU affinity setting, IPv6 flow label, TCP congestion algorithm setting, sendfile / zerocopy, socket pacing, authentication, bind to device, support IPv4 don't fragment
```

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

Windows builds required being bundled with Cygwin dlls to work so these are not single static binaries. They have a directory structure like this.

```
iperf3
    |___bin
    |___include
    |___lib
    |___share
```

Windows x64 no openssl

https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-amd64-win.zip

Windows x64 with openssl

https://github.com/userdocs/iperf3-static/releases/latest/download/iperf3-amd64-openssl-win.zip

Check the version:

```
~/bin/iperf3 -v
```
