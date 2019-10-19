# lua
set -e

BLD_DIR="$config_local_prefix"/tmp/${PKG}_build
PREFIX="$config_local_prefix"/pkg/$PKG

OPTIONS=

if [ "$config_build_pic" = yes ]; then
    # untested, see https://stackoverflow.com/questions/38296756/what-is-the-idiomatic-way-in-cmake-to-add-the-fpic-compiler-option
    OPTIONS="$OPTIONS -DCMAKE_POSITION_INDEPENDENT_CODE=ON"
fi
if [ "$config_build_host" ]; then
    # cross is handled from the host-specific "cmake" which is setup globally
    :
fi

pkg_configure() {
    set -x
    mkdir -p "$BLD_DIR"
    cd "$BLD_DIR"
    pkg_cmake \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DLIB_INSTALL_DIR="$PREFIX"/lib \
        $OPTIONS "$@" "$PKG_source"
}

pkg_build() {
    set -x
    make -C "$BLD_DIR" install $OPTIONS "$@"

    # and create a .pc file
    mkdir -p "$PREFIX"/lib/pkgconfig
    cat > "$PREFIX"/lib/pkgconfig/lua.pc <<EOF
prefix=$PREFIX
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: lua
Description: Lua
Version: $(cd "$config_lua_source" && git describe --tags)
Libs: -L\${libdir} -llua
Libs.private: -lm
Cflags: -I\${includedir}
EOF

    pkg_cp_pc "$PREFIX"
}

pkg_clean() {
    set -x
    rm -rf "$BLD_DIR"
}
