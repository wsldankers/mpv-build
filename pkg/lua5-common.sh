
# $PKG is lua51 or lua52
# the cmake build creates liblua.a, we change it to lib$PKG.a
# the pkg-config file name is similar - created as $PKG.pc
set -e

BLD_DIR="$config_local_prefix"/tmp/${PKG}_build
PREFIX="$config_local_prefix"/pkg/$PKG

# RELATIVE_LOADLIB is no-good cmake-build extension (expand ! in non-win paths).
# USE_ANSI is mainline lua, only avoids hacks for "faster" cast to int.
OPTIONS="
    -DBUILD_SHARED_LIBS=OFF
    -DLUA_USE_RELATIVE_LOADLIB=OFF
    -DLUA_USE_ANSI=ON
"

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
    make -C "$BLD_DIR" install "$@"

    # and create a .pc file
    mkdir -p "$PREFIX"/lib/pkgconfig
    cat > "$PREFIX"/lib/pkgconfig/$PKG.pc <<EOF
prefix=$PREFIX
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: lua
Description: Lua
Version: $(grep version <"$PKG_source/dist.info" | sed 's/.*"\(.*\)".*/\1/')
Libs: -L\${libdir} -l$PKG
Libs.private: -lm
Cflags: -I\${includedir}
EOF

    pkg_cp_pc "$PREFIX"

    # rename to liblua5x.a
    mv "$PREFIX"/lib/liblua.a "$PREFIX/lib/lib$PKG.a"
}

pkg_clean() {
    set -x
    rm -rf "$BLD_DIR"
}
