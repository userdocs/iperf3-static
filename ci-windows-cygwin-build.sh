#!/usr/bin/env bash

HOME="$(pwd)"
with_openssl="${1:-no}"
if [[ ${2} =~ ^/ ]]; then
	cygwin_path="${2}"
else
	cygwin_path="${HOME}/${2:-cygwin}"
fi
source_repo="${3:-https://github.com/esnet/iperf.git}"
source_branch="${4:-master}"

printf '\n%b\n' " \e[93m\U25cf\e[0m With openssl = ${with_openssl}"
printf '%b\n' " \e[93m\U25cf\e[0m Build path = ${HOME}"
printf '%b\n' " \e[93m\U25cf\e[0m Cygwin path = ${cygwin_path}"

printf '\n%b\n' " \e[93m\U25cf\e[0m parameters = ${*}"

printf '\n%b\n' " \e[93m\U25cf\e[0m with_openssl = ${with_openssl}"
printf '\n%b\n' " \e[93m\U25cf\e[0m cygwin_path = ${cygwin_path}"
printf '\n%b\n' " \e[93m\U25cf\e[0m source_repo = ${source_repo}"
printf '\n%b\n' " \e[93m\U25cf\e[0m source_branch = ${source_branch}"

if [[ ${with_openssl} == 'yes' ]]; then
	printf '\n%b\n' " \e[94m\U25cf\e[0m Downloading zlib"
	curl -sLO "https://github.com/userdocs/qbt-workflow-files/releases/latest/download/zlib.tar.xz"

	# Version 3.0 will be supported until 2026-09-07 (LTS). 3.1 is EOL https://openssl-library.org/policies/releasestrat/index.html
	openssl_version="$(git ls-remote -q -t --refs "https://github.com/openssl/openssl.git" | awk '/openssl-3\.0\./{sub("refs/tags/", "");sub("(.*)(v6|rc|alpha|beta)(.*)", ""); print $2 }' | awk '!/^$/' | sort -rV | head -n1)"

	printf '\n%b\n' " \e[94m\U25cf\e[0m Downloading openssl ${openssl_version}"
	curl -sLO "https://github.com/openssl/openssl/releases/download/${openssl_version}/${openssl_version}.tar.gz"

	printf '\n%b\n' " \e[94m\U25cf\e[0m Extracting zlib"
	rm -rf "zlib" && mkdir -p "zlib"
	tar xf "zlib.tar.xz" --strip-components=1 -C "zlib"

	printf '\n%b\n' " \e[94m\U25cf\e[0m Extracting openssl"
	rm -rf "openssl" && mkdir -p "openssl"
	tar xf "${openssl_version}.tar.gz" --strip-components=1 -C "openssl"

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m Configuring zlib"
	pushd "zlib" || exit 1
	./configure --prefix="${cygwin_path}" --static --zlib-compat

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m Building with zlib"
	make -j"$(nproc)"
	make install

	popd || exit 1

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m Configuring openssl"
	pushd "${HOME}/openssl" || exit 1
	./config --prefix="${cygwin_path}" --libdir=lib threads no-shared no-dso no-comp

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m Building openssl"
	make -j"$(nproc)"
	make install_sw

	popd || exit 1
fi

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Cloning iperf3 git repo"

[[ -d "$HOME/iperf3_build" ]] && rm -rf "$HOME/iperf3_build"
printf '%b\n\n' " \e[94m\U25cf\e[0m git clone --no-tags --single-branch --branch ${source_branch} --shallow-submodules --recurse-submodules -j$(nproc) --depth 1 ${source_repo} $HOME/iperf3_build"
git clone --no-tags --single-branch --branch "${source_branch}" --shallow-submodules --recurse-submodules -j"$(nproc)" --depth 1 "${source_repo}" "$HOME/iperf3_build"
cd "$HOME/iperf3_build" || exit 1

printf '%b\n\n' " \e[94m\U25cf\e[0m Repo Info"

git remote show origin

printf '\n%b\n' " \e[92m\U25cf\e[0m Setting iperf3 version to file iperf3_version"
sed -rn 's|(.*)\[(.*)],\[https://github.com/esnet/iperf],(.*)|\2|p' configure.ac > "$HOME/iperf3_version"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Bootstrapping iperf3"

./bootstrap.sh

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Configuring iperf3"
./configure --disable-shared --enable-static --enable-static-bin --prefix="$HOME/iperf3"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m make"
make -j"$(nproc)"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m make install"
[[ -d "$HOME/iperf3" ]] && rm -rf "$HOME/iperf3"
make install

if [[ -d "$HOME/iperf3/bin" ]]; then
	printf '\n%b\n' " \e[94m\U25cf\e[0m Copy dll dependencies"
	[[ -f "${cygwin_path}/bin/cygwin1.dll" ]] && cp -f "${cygwin_path}/bin/cygwin1.dll" "$HOME/iperf3/bin"
	printf '\n%b\n' " \e[92m\U25cf\e[0m Copied the dll dependencies"
fi
