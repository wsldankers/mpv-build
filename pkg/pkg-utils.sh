
pkg_has() {
    [ -e pkg/$1.sh ]
}

# this and following pkg procedure should be used in a subshell
pkg_load() {
    PKG=$1
    eval PKG_source=\$config_$1_source
    . pkg/$1.sh
}

# native windows cmake (including MINGW mode of MSYS2) can default to
# visual studio or borland - not good for us.
# Set -G on MSYS2/mingw if we're not cross building and -G is not used
pkg_cmake() {(
    if [ "$config_target_windows" = yes ] && [ -z "config_build_host" ]; then
        case " $* " in *" -G"*)  # generator (most likely) already set
            cmake "$@"; exit
        esac

        # slow: if cmake --system-information | grep 'CMAKE_GENERATOR "' | grep -qi 'visual studio\|borland'; then
        case ${MSYSTEM-} in MINGW*)
            cmake "-GMSYS Makefiles" "$@"; exit
        esac
    fi

    cmake "$@"
)}

# $1: prefix to copy .pc files from into $config_local_prefix
pkg_cp_pc() {
    mkdir -p "$config_local_prefix"/lib/pkgconfig
    cp "$1"/lib/pkgconfig/*.pc "$config_local_prefix"/lib/pkgconfig/
}