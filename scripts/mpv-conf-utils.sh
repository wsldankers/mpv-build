# mpv cross setup, feel free to replace config_build_cross_pre with your own

# Generic cross build setup. Note: mpv/ffmpeg also need additional OS[/arch]
mpv_cross_base() {
   local host="$config_build_host"
   local host_var="$(echo $host | sed s/[-.]/_/g)"
   local extra_bin="$config_local_prefix/bin/$host"
   local pcpath="$config_local_prefix/lib/pkgconfig"
   local cmd=

   # some scripts use "pkg-config" and "cmake", try to use host-specific ones
   mkdir -p "$extra_bin"
   for cmd in pkg-config cmake; do
      if which "$host-$cmd" > /dev/null; then  # ln -s doesn't work everywhere
         printf '#!/bin/sh\nexec '$host-$cmd' "$@"' > "$extra_bin/$cmd"
         chmod +x "$extra_bin/$cmd"
      fi
   done

   export PATH="$extra_bin:${PATH-}"
   export PKG_CONFIG_PATH_${host_var}="$pcpath"  # MXE
   export PKG_CONFIG_PATH_CUSTOM="$pcpath"     # arch
}

# --arch=$1 --target-os=$2 for ffmpeg, DEST_OS=$3 for mpv. empty arg to skip.
mpv_cross_set_extra() {
   [ -z "$1" ] || conf_prepend ffmpeg_opts_config  "--arch=$1"
   [ -z "$2" ] || conf_prepend ffmpeg_opts_config  "--target-os=$2"
   [ -z "$3" ] || conf_prepend mpv_opts_config     "DEST_OS=$3"
}

# $1: host (only called if not empty)
mpv_cross_guess_opts() {
   local host="$config_build_host"
   local triplet="$($host-gcc -dumpmachine)"
   local arch="${triplet%%-*}"

   # TODO: untested except mingw
   case "$triplet" in
        *mingw*) conf_prepend shaderc_opts_config -DENABLE_GLSLANG_BINARIES=OFF
                 mpv_cross_set_extra "$arch" mingw32 win32
                 ;;
      *freebsd*) mpv_cross_set_extra "$arch" freebsd freebsd;;
      *openbsd*) mpv_cross_set_extra "$arch" openbsd openbsd;;
              *) mpv_cross_set_extra "$arch" linux   linux;;
   esac
}

mpv_pic_auto() {
    case "$config_mpv_opts_config" in
        *--enable-libmpv*) config_build_pic=yes;;
                        *) config_build_pic=no;;
    esac
}
