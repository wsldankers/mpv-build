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

# MACOSX_DEPLOYMENT_TARGET affects the system compiler and has system defaults
# if it's unset, but luajit requires that it's set (but doesn't use it...).
# Simply set it to the current OS version if unset (major.minor only - XX.YY)
set_target() {
    case $(uname) in *Darwin*)
        if [ -z "${MACOSX_DEPLOYMENT_TARGET-}" ]; then
            export MACOSX_DEPLOYMENT_TARGET="$(
                v=$(sw_vers -productVersion || echo 10.12)  # arbitrary fallback
                case $v in (*.*.*) v=${v%.*}; esac  # two numbers, not three
                echo "$v"
            )"
            echo "+ export MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET"
        fi
    esac
}

pkg_configure() {
    :
}

pkg_build() {
    set_target
    set -x
    make -C "$PKG_source" install PREFIX="$PREFIX" $OPTIONS "$@"
    pkg_cp_pc "$PREFIX"
}

pkg_clean() {
    set_target
    set -x
    make -C "$PKG_source" clean
}
