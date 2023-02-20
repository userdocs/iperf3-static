#!/usr/bin/env bash

# The matrix will pass this as yes or no to the build script - defaults to no but the build will fail if you have libssl-devel installed.
with_openssl="${1:-no}"
printf '\n%b\n' " \e[93m\U25cf\e[0m Building with openssl = ${with_openssl}"
HOME="$(pwd)"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Cloning iperf3 git repo"

[[ -d "$HOME/iperf3_build" ]] && rm -rf "$HOME/iperf3_build"
git clone "https://github.com/esnet/iperf.git" "$HOME/iperf3_build"
cd "$HOME/iperf3_build" || exit 1

printf '\n%b\n' " \e[92m\U25cf\e[0m Setting iperf3 version to file iperf3_version"
sed -rn 's|(.*)\[(.*)],\[https://github.com/esnet/iperf],(.*)|\2|p' configure.ac > "$HOME/iperf3_version"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Bootstrapping iperf3"

./bootstrap.sh

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Configuring iperf3"

if [[ "${with_openssl}" = 'yes' ]]; then
	# fix openssl linking - We want this sed replace using a literal match
	# shellcheck disable=SC2016
	sed -ri 's|OPENSSL_LIBS="-lssl -lcrypto"|OPENSSL_LIBS="${OPENSSL_LIBS}"|g' "$HOME/iperf3_build/configure"
	./configure --with-openssl=/usr OPENSSL_LIBS="-l:libssl.dll.a -l:libcrypto.dll.a" --disable-shared --enable-static-bin --prefix="$HOME/iperf3"
else
	./configure --disable-shared --enable-static-bin --prefix="$HOME/iperf3"
fi

printf '\n%b\n\n' " \e[94m\U25cf\e[0m make"
make -j"$(nproc)"

printf '\n%b\n\n' " \e[94m\U25cf\e[0m make install"
[[ -d "$HOME/iperf3" ]] && rm -rf "$HOME/iperf3"
make install

printf '\n%b\n\n' " \e[94m\U25cf\e[0m Copy dll dependencies"

if [[ -d "$HOME/iperf3/bin" ]]; then
	# default requirements
	# cmd
	[[ -f "$HOME/system/bin/cygwin1.dll" ]] && cp -f "$HOME/system/bin/cygwin1.dll" "$HOME/iperf3/bin"
	# action
	[[ -f "/cygdrive/c/cygwin/bin/cygwin1.dll" ]] && cp -f "/cygdrive/c/cygwin/bin/cygwin1.dll" "$HOME/iperf3/bin"

	if [[ "${with_openssl}" == 'yes' ]]; then
		# openssl requirements
		# cmd
		[[ -f "$HOME/system/bin/cygcrypto-1.1.dll" ]] && cp -f "$HOME/system/bin/cygcrypto-1.1.dll" "$HOME/iperf3/bin"
		[[ -f "$HOME/system/bin/cygz.dll" ]] && cp -f "$HOME/system/bin/cygz.dll" "$HOME/iperf3/bin"
		# action
		[[ -f "/cygdrive/c/cygwin/bin/cygcrypto-1.1.dll" ]] && cp -f "/cygdrive/c/cygwin/bin/cygcrypto-1.1.dll" "$HOME/iperf3/bin"
		[[ -f "/cygdrive/c/cygwin/bin/cygz.dll" ]] && cp -f "/cygdrive/c/cygwin/bin/cygz.dll" "$HOME/iperf3/bin"
	fi
	printf '\n%b\n\n' " \e[92m\U25cf\e[0m Copied the dll dependencies"
fi
