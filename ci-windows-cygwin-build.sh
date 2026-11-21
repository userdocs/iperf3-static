#!/usr/bin/env bash
set -euo pipefail

HOME="$(pwd)"
with_openssl="${1:-no}"
if [[ ${2:-} =~ ^/ ]]; then
	cygwin_path="${2}"
else
	cygwin_path="${HOME}/${2:-cygwin}"
fi
source_repo="${3:-https://github.com/esnet/iperf.git}"
source_branch="${4:-master}"

only_apps="${5:-}" # simple way to break up script to make github steps more modular.

# Cygwin's GCC specs unconditionally pass -lintl when linking; --static requires libintl.a.
# Newer gettext/libintl-devel packages (e.g. 0.26-1) omit libintl.a, so create a stub archive
# when missing (iperf3 and Cygwin's CRT do not reference any libintl symbols).
ensure_static_libintl() {
	if [[ ! -f /usr/lib/libintl.a ]]; then
		printf '\n%b\n' " \e[93m\U25cf\e[0m /usr/lib/libintl.a missing; creating stub archive for static linking"
		local tmp_dir
		tmp_dir="$(mktemp -d)"
		printf 'typedef int dummy_libintl_t;\n' > "${tmp_dir}/dummy_libintl.c"
		if ! gcc -c "${tmp_dir}/dummy_libintl.c" -o "${tmp_dir}/dummy_libintl.o" ||
			! ar rcs /usr/lib/libintl.a "${tmp_dir}/dummy_libintl.o"; then
			rm -rf "$tmp_dir"
			return 1
		fi
		rm -rf "$tmp_dir"
	fi
}

# Fallback to the Cygwin mirror source tarball when cygwin.com git returns HTTP 429 on CI runners.
fetch_cygwin_openssl_src() {
	local dest_dir="$1"
	local mirror="https://www.mirrorservice.org/sites/sourceware.org/pub/cygwin"
	if [[ -f /etc/setup/setup.rc ]]; then
		local configured_mirror
		configured_mirror="$(awk '/^last-mirror/{getline; gsub(/^[ \t\r]+|[ \t\r]+$/, ""); print; exit}' /etc/setup/setup.rc)"
		if [[ -n "$configured_mirror" ]]; then
			mirror="${configured_mirror%/}"
		fi
	fi

	local tmp_dir
	tmp_dir="$(mktemp -d)"
	if ! curl -fsSL "${mirror}/x86_64/setup.xz" -o "${tmp_dir}/setup.xz"; then
		rm -rf "$tmp_dir"
		return 1
	fi

	local src_rel
	src_rel="$(xz -dc "${tmp_dir}/setup.xz" | awk '
		$0 == "@ openssl" { in_pkg = 1; next }
		in_pkg && (/^\[/ || /^@ /) { exit }
		in_pkg && /^source: / { print $2; exit }
	')"
	if [[ -z "$src_rel" ]]; then
		echo "Failed to find openssl source package in ${mirror}/x86_64/setup.xz" >&2
		rm -rf "$tmp_dir"
		return 1
	fi

	local src_archive="${tmp_dir}/${src_rel##*/}"
	echo "==> Downloading ${mirror}/${src_rel}..."
	if ! curl -fsSL "${mirror}/${src_rel}" -o "$src_archive"; then
		rm -rf "$tmp_dir"
		return 1
	fi

	mkdir -p "$dest_dir"
	if ! tar --strip-components=1 -xf "$src_archive" -C "$dest_dir"; then
		rm -rf "$tmp_dir"
		return 1
	fi
	rm -rf "$tmp_dir"
}

printf '\n%b\n' " \e[93m\U25cf\e[0m With openssl = ${with_openssl}"
printf '%b\n' " \e[93m\U25cf\e[0m Build path = ${HOME}"
printf '%b\n' " \e[93m\U25cf\e[0m Cygwin path = ${cygwin_path}"

printf '\n%b\n' " \e[93m\U25cf\e[0m parameters = ${*}"

printf '\n%b\n' " \e[93m\U25cf\e[0m cygwin_path = ${cygwin_path}"
printf '\n%b\n' " \e[93m\U25cf\e[0m source_repo = ${source_repo}"
printf '\n%b\n' " \e[93m\U25cf\e[0m source_branch = ${source_branch}"

if [[ ${with_openssl} == 'yes' && ${only_apps} == "only_openssl" ]]; then
	ensure_static_libintl

	# openssl via cygport
	REPO_DIR="$HOME/openssl"

	echo "==> Cloning Cygwin OpenSSL repository (with submodules)..."
	if [[ ! -d "$REPO_DIR" ]]; then
		if ! git clone --recurse-submodules https://cygwin.com/git/cygwin-packages/openssl.git "$REPO_DIR"; then
			echo "==> Git clone failed; falling back to Cygwin mirror source package..."
			rm -rf "$REPO_DIR"
			fetch_cygwin_openssl_src "$REPO_DIR"
		fi
		pushd "$REPO_DIR" || exit 1
	elif [[ -d "$REPO_DIR/.git" ]]; then
		echo "Directory $REPO_DIR already exists. Pulling latest changes..."
		pushd "$REPO_DIR" || exit 1
		git checkout -- .
		git pull
		git submodule update --init --recursive
	else
		echo "Directory $REPO_DIR already exists (source archive). Reusing..."
		pushd "$REPO_DIR" || exit 1
	fi

	echo "==> Cleaning any previous builds..."

	# 1. Bootstrapping
	cygport openssl.cygport clean || true

	echo "==> Modifying openssl.cygport (Fully Static Build)..."

	# 2. Adjust MAKEOPTS for available cores
	CPU_CORES=$(nproc)
	sed -i "s|.*MAKEOPTS+=.*|MAKEOPTS=\"-j$CPU_CORES\"|g" openssl.cygport

	# 3. Switch configuration to fully static
	sed -i 's/shared Cygwin/no-shared no-dso no-comp Cygwin/' openssl.cygport

	# 4. Remove logic for dynamic libraries and static library deletion
	# shellcheck disable=SC2016
	sed -i '/rm \${D}\/usr\/lib\/lib{crypto,ssl}\.a/d' openssl.cygport

	# 5. Skip doc/man page generation (cyginstall runs full make install)
	# shellcheck disable=SC2016
	sed -i 's|^\s*cyginstall\s*$|    make DESTDIR="${D}" install_sw install_ssldirs|' openssl.cygport

	echo "==> Starting cygport static build pipeline with $CPU_CORES cores..."
	cygport openssl.cygport fetch prep compile install

	echo "==> Automatically installing files to /..."
	cp -a openssl-*/inst/* /

	echo "==> Success! OpenSSL built and installed locally."

	popd || exit 1
fi

if [[ ${only_apps} == "only_iperf3" ]]; then
	ensure_static_libintl

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m Cloning iperf3 git repo"

	if [[ -d "$HOME/iperf3_build" ]]; then
		rm -rf "$HOME/iperf3_build"
	fi
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
	if [[ ${with_openssl} == 'yes' ]]; then
		# AX_CHECK_OPENSSL prefers pkg-config over the OPENSSL_LIBS env var, dropping any
		# override, so the extra lib has to ride in via LIBS instead (it gets appended
		# after OPENSSL_LIBS by the macro: LIBS="$OPENSSL_LIBS $LIBS").
		# static openssl 3.5+ pulls in the windows cert store (winstore_store.c), which needs crypt32
		# static openssl was built with zlib support, so the static libz.a needs to ride along too
		LIBS="-lcrypt32 -lz" ./configure --disable-shared --enable-static --enable-static-bin --prefix="$HOME/iperf3"
	else
		./configure --disable-shared --enable-static --enable-static-bin --prefix="$HOME/iperf3"
	fi

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m make"
	make -j"$(nproc)"

	printf '\n%b\n\n' " \e[94m\U25cf\e[0m make install"
	if [[ -d "$HOME/iperf3" ]]; then
		rm -rf "$HOME/iperf3"
	fi
	make install

	if [[ -d "$HOME/iperf3/bin" ]]; then
		printf '\n%b\n' " \e[94m\U25cf\e[0m Copy dll dependencies"
		if [[ -f "${cygwin_path}/bin/cygwin1.dll" ]]; then
			cp -f "${cygwin_path}/bin/cygwin1.dll" "$HOME/iperf3/bin"
		fi
		printf '\n%b\n' " \e[92m\U25cf\e[0m Copied the dll dependencies"
	fi
fi
