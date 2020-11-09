# luajit
set -e

PREFIX="$config_local_prefix"/pkg/$PKG

OPTIONS="
    --prefix=$PREFIX
    --enable-static
    --disable-shared
"

if [ "$config_build_pic" = yes ]; then
    OPTION="$OPTIONS --with-pic"
fi

if [ "$config_build_host" ]; then
    OPTIONS="$OPTIONS --host=$config_build_host"
fi

pkg_configure() {
    set -x
    cd "$PKG_source" \
    && NOCONFIGURE=1 ./autogen.sh \
    && ./configure $OPTIONS "$@"
}

pkg_build() {
    set -x
    make -C "$PKG_source" "$@" install
    pkg_cp_pc "$PREFIX"
}

pkg_clean() {
    set -x
    make -C "$PKG_source" clean
}
