#!/bin/bash

# A very simple script to cross-compile iperf3 with openssl for variety of targets using ghcr.io/userdocs/qbt-musl-cross-make docker images
#
# Example - to cross-compile iperf3 for aarch64-linux-musl save the script in ~/iperf3 then use the following command:
#
# docker run -it -w /home/gh -v ~/iperf3:/home/gh ghcr.io/userdocs/qbt-musl-cross-make:aarch64-linux-musl /bin/bash crossbuild.sh

github_repo="${1:-"https://github.com/esnet/iperf.git"}"
github_branch="${2:-"master"}"
crossbuild_target="${3:-${CC/-gcc/}}"
arch="${4:-x86_64}"

printf '\n%s\n' "Building iperf3 for $crossbuild_target"
printf '%s\n\n' "repo: $github_repo branch:$github_branch"

sudo apk update

export CPPFLAGS: "-I/home/gh/local/include -I/usr/include/fortify -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3"
export LDFLAGS: "-static --static -L/home/gh/local/lib -Wl,-O1,--as-needed,--sort-common,-z,nodlopen,-z,noexecstack,-z,now,-z,relro,-z,--no-copy-dt-needed-entries,--build-id"

cd || exit
mkdir -p /home/gh/local

repo="$(cat /etc/apk/repositories | sed -rn 's|https://dl-cdn.alpinelinux.org/alpine/(.*)/(.*)|\1|p' | head -1)"
openssl_libs_static="$(apk info openssl-libs-static | head -1 | awk '{ print $1 }')"
openssl_dev="$(apk info openssl-dev | head -1 | awk '{ print $1 }')"

curl -sLO "https://dl-cdn.alpinelinux.org/alpine/${repo}/main/${arch}/${openssl_dev}.apk"
curl -sLO "https://dl-cdn.alpinelinux.org/alpine/${repo}/main/${arch}/${openssl_libs_static}.apk"
tar -xzf "${openssl_dev}.apk" --strip-components=1 -C /home/gh/local
tar -xzf "${openssl_libs_static}.apk" --strip-components=1 -C /home/gh/local

rm -rf /home/gh/iperf3
git clone --no-tags --single-branch --branch "${github_branch}" --shallow-submodules --recurse-submodules -j"$(nproc)" --depth 1 "${github_repo}" /home/gh/iperf3
cd /home/gh/iperf3 || exit

./configure --with-openssl="/home/gh/local" --disable-shared --enable-static-bin --prefix="/home/gh/local"
make -j$(nproc)
make install
