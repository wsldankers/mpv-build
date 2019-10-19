# luajit
set -e

PREFIX="$config_local_prefix"/pkg/$PKG

# MULTILIB is only the lib install dir
OPTIONS="
    MULTILIB=lib
    BUILDMODE=static
"

if [ "$config_build_pic" = yes ]; then
    :  # ignore config, leave automatic for now
fi

if [ "$config_build_host" ]; then
    OPTIONS="$OPTIONS CROSS=$config_build_host-"

    if [ "$config_target_windows" = yes ]; then
        OPTIONS="$OPTIONS TARGET_SYS=Windows FILE_T=luajit.exe"
    else
        OPTIONS="$OPTIONS TARGET_SYS=Other"
    fi
fi

pkg_configure() {
    :
}

pkg_build() {
    set -x
    make -C "$PKG_source" install PREFIX="$PREFIX" $OPTIONS "$@"
    pkg_cp_pc "$PREFIX"
}

pkg_clean() {
    set -x
    make -C "$PKG_source" clean
}
