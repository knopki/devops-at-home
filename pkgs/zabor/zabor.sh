#!/usr/bin/env bash
#
# zabor - Safe sandbox runner for dangerous tools.
# Like a fence for an angry dog.
#

set -euo pipefail

VERSION="0.1.0"

prog_name="${0##*/}"

usage() {
  cat <<EOF
Usage:
  $prog_name [OPTIONS] -- COMMAND [ARG...]
  $prog_name [OPTIONS] COMMAND [ARG...]

Run an arbitrary command inside a bubblewrap sandbox, optionally enhanced with:

Options:
  -h, --help
      Show this help and exit.

  -V, --version
      Show version and exit.

  --dry-run
      Print command that would be executed without actually running them.

  --debug
      Enable debug logging.

  --no-landrun
      Do not use landrun even if it is available.

  --env NAME
      Environment variable to pass to the sandbox.
      May be specified multiple times.

  --rw PATH
      Bind-mount PATH read-write into sandbox.
      May be specified multiple times.

  --ro PATH
      Bind-mount PATH read-only into sandbox.
      May be specified multiple times.

  --cwd PATH
      Working directory inside sandbox.
      Default: current directory.

  --project-ro, --project-rw
      Set mode for current directory.
      Default: RW for git projects, RO otherwise.

  --no-net
      Restrict access to any network.

  --profile name
      Enable predefined profile.
      Available profiles:
       * default - preset with wide permissions (enabled if profile not set).
       * default-gui - preset with ultra wide permissions.
       * empty - empty profile (if you need to disable default profile).
       * gpu - expose GPU device nodes.
       * gui - expose Wayland/X11 sockets and environment variables.
       * helix - Helix paths.
       * opencode - add OpenCode paths and allow bash autoapprove.
       * zed - Zed Editor paths + gpu + gui.
      May be specified multiple times.

Notes:
  * bubblewrap is required.
  * landrun is optional and only used if found.

Examples:
  $prog_name --ro /home -- rg TODO /home
  $prog_name --no-landrun --no-net -- bash
EOF
}

die() {
  printf '%s: %s\n' "$prog_name" "$*" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

uid="$(id -u)"
home="${HOME:?HOME is required}"

xdg_cache_home="${XDG_CACHE_HOME:-$home/.cache}"
xdg_config_home="${XDG_CONFIG_HOME:-$home/.config}"
xdg_data_home="${XDG_DATA_HOME:-$home/.local/share}"
xdg_runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$uid}"
xdg_state_home="${XDG_STATE_HOME:-$home/.local/state}"

cwd="$PWD"
use_landrun=auto
enable_debug=0
dry_run=""
# Pass environment variables to sandbox
# It is intended to pass many devenv-specific variables
pass_env_names=(
  HOME
  USER
  LOGNAME
  SHELL
  TERM
  COLORTERM
  LANG
  LC_ALL
  LC_CTYPE
  LC_MESSAGES
  LC_NUMERIC
  TZ
  PATH
  TMPDIR

  XDG_CACHE_HOME
  XDG_CONFIG_HOME
  XDG_DATA_DIRS
  XDG_DATA_HOME
  XDG_RUNTIME_DIR
  XDG_STATE_HOME
  XDG_SEAT
  XDG_SESSION_ID
  XDG_SESSION_TYPE
  XDG_VTNR

  EDITOR
  VISUAL
  PAGER
  GIT_EDITOR
  GIT_PAGER
  GIT_CONFIG_GLOBAL

  NIX_PATH
  NIX_SSL_CERT_FILE
  SSL_CERT_FILE
  SSL_CERT_DIR

  http_proxy
  https_proxy
  HTTP_PROXY
  HTTPS_PROXY
  no_proxy
  NO_PROXY

  AR
  AS
  CC
  cmakeFlags
  CONFIG_SHELL
  configureFlags
  CXX
  DETERMINISTIC_BUILD
  DEVENV_CMDLINE
  DEVENV_DOTFILE
  DEVENV_PROFILE
  DEVENV_ROOT
  DEVENV_RUNTIME
  DEVENV_STATE
  DEVENV_TASK_FILE
  DEVENV_TASKS
  DIRENV_CONFIG
  fish_history
  GDK_BACKEND
  GETTEXTDATADIRS_FOR_BUILD
  GIO_EXTRA_MODULES
  INFOPATH
  IN_NIX_SHELL
  LD
  LD_LIBRARY_PATH
  LESSKEYIN_SYSTEM
  LIBEXEC_PATH
  LOCALE_ARCHIVE
  mesonFlags
  name
  NH_FLAKE
  NIX_BINTOOLS
  NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu
  NIX_CFLAGS_COMPILE
  NIX_ENFORCE_NO_NATIVE
  NIX_HARDENING_ENABLE
  NIX_LDFLAGS
  NIX_LD_LIBRARY_PATH
  NIX_LD
  NIX_PKG_CONFIG_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu
  NIXPKGS_CONFIG
  NIX_PROFILES
  NIX_STORE
  NIX_USER_PROFILE_DIR
  NM
  OBJCOPY
  OBJDUMP
  OLDPWN
  PAGE
  PKG_CONFIG_PATH
  PKG_CONFIG
  PREK_HOME
  PYTHONHASHSEED
  _PYTHON_HOST_PLATFORM
  PYTHONNOUSERSITE
  PYTHONPATH
  _PYTHON_SYSCONFIGDATA_NAME
  QML2_IMPORT_PATH
  RANLIB
  READELF
  SANE_CONFIG_DIR
  SIZE
  SOURCE_DATE_EPOCH
  SSH_ASKPASS
  STRINGS
  STRIP
  system
  TERMINFO_DIRS
  TERM_PROGRAM
  TERM_PROGRAM_VERSION
  TZDIR

  UV_LINK_MODE
  OPENCODE_PERMISSION
)
allow_network=1
paths_ro=(
  /etc
  /proc/mounts
  /run/systemd/resolve
  "$home/.ssh/config"
  "$xdg_config_home/fish"
  "$xdg_config_home/git"
)
paths_rw=(
  "$xdg_cache_home/npm"
  "$xdg_cache_home/uv"
  "$xdg_cache_home/yarn"
  "$home/.ssh/known_hosts"
)
paths_rox=(
  /bin
  /run/current-system
  /nix
  /usr
  /lib
  /lib64
)
paths_rwx=()
gpu_devs=(
  /dev/dri
  /dev/hugepages
  /dev/nvidia0
  /dev/nvidia1
  /dev/nvidiactl
  /dev/nvidia-modeset
  /dev/nvidia-uvm
  /dev/nvidia-uvm-tools
)
extra_paths_rw=()
extra_paths_ro=()
project_ro=0
project_rw=0
profile_default=1
profile_codex=0
profile_gpu=0
profile_gui=0
profile_helix=0
profile_hermes=0
profile_opencode=0
profile_zed=0

while (($#)); do
  case "$1" in
  -h | --help)
    usage
    exit 0
    ;;
  -V | --version)
    printf '%s %s\n' "$prog_name" "$VERSION"
    exit 0
    ;;
  --debug)
    enable_debug=1
    shift
    ;;
  --dry-run)
    dry_run="echo"
    shift
    ;;
  --no-landrun)
    use_landrun=never
    shift
    ;;
  --no-net)
    allow_network=0
    shift
    ;;
  --env)
    (($# >= 2)) || die "--env requires an argument"
    pass_env_names+=("$2")
    shift 2
    ;;
  --rw)
    (($# >= 2)) || die "--rw requires a path"
    extra_paths_rw+=("$2")
    shift 2
    ;;
  --ro)
    (($# >= 2)) || die "--ro requires a path"
    extra_paths_ro+=("$2")
    shift 2
    ;;
  --cwd)
    (($# >= 2)) || die "--cwd requires a path"
    cwd="$2"
    shift 2
    ;;
  --project-ro)
    project_ro=1
    shift 1
    ;;
  --project-rw)
    project_rw=1
    shift 1
    ;;
  --profile)
    (($# >= 2)) || die "--profile requires a name"
    case "$2" in
    codex)
      profile_codex=1
      ;;
    gpu)
      profile_gpu=1
      ;;
    gui)
      profile_gpu=1
      profile_gui=1
      ;;
    helix)
      profile_helix=1
      ;;
    hermes)
      profile_hermes=1
      ;;
    opencode)
      profile_opencode=1
      ;;
    zed)
      profile_gpu=1
      profile_gui=1
      profile_zed=1
      ;;
    default)
      profile_default=1
      ;;
    default-gui)
      profile_gpu=1
      profile_gui=1
      profile_helix=1
      profile_opencode=1
      profile_zed=1
      ;;
    empty)
      profile_default=0
      ;;
    *)
      die "unknown profile: $2"
      ;;
    esac
    shift 2
    ;;
  --)
    shift
    break
    ;;
  -*)
    die "unknown option: $1"
    ;;
  *)
    break
    ;;
  esac
done

(($# >= 1)) || die "missing command (see --help)"

have_cmd bwrap || die "bubblewrap (bwrap) is required"

if [[ $use_landrun == auto ]] && have_cmd landrun; then
  use_landrun=yes
elif [[ $use_landrun == auto ]]; then
  use_landrun=no
fi

if ((project_ro)); then
  paths_rox+=("$cwd")
fi

if ((project_rw)); then
  paths_rwx+=("$cwd")
fi

# autodetect
if ((project_ro == 0 && project_rw == 0)); then
  # CWD: rw for git projects
  if [[ -d "$cwd/.git" ]]; then
    paths_rwx+=("$cwd")
  else
    paths_rox+=("$cwd")
  fi
fi

for p in "${extra_paths_ro[@]}"; do
  [[ -e $p ]] || die "--ro path does not exist: $p"
  paths_rox+=("$p")
done

for p in "${extra_paths_rw[@]}"; do
  [[ -e $p ]] || die "--rw path does not exist: $p"
  paths_rwx+=("$p")
done

if ((profile_hermes)); then
  profile_codex=1
  profile_opencode=1
  paths_ro+=(
    "$xdg_runtime_dir/pipewire-0"
    "$home/.config/pulse/cookie"
  )
  paths_rw+=(
    "$xdg_cache_home/.huggingface"
  )
  paths_rwx+=(
    "$home/.hermes"
  )
fi

if ((profile_default)); then
  profile_codex=1
  profile_helix=1
  profile_opencode=1
fi

if ((profile_codex)); then
  use_landrun=0
  paths_rw+=(
    "$home/.codex"
  )
fi

if ((profile_gpu)); then
  pass_env_names+=(
    __GLX_VENDOR_LIBRARY_NAME
    __NV_PRIME_RENDER_OFFLOAD
  )
  paths_ro+=(
    /run/opengl-driver
    /run/opengl-driver-32
    /usr/lib
    /usr/lib32
    /sys/dev/char
    /sys/devices/pci0000:00
    /sys/bus/pci
  )
fi

if ((profile_gui)); then
  if [[ -v WAYLAND_DISPLAY ]]; then
    pass_env_names+=(
      WAYLAND_DISPLAY
      WAYLAND_SOCKET
    )
    paths_ro+=("$xdg_runtime_dir/$WAYLAND_DISPLAY")
  fi
  if [[ -v DISPLAY ]]; then
    pass_env_names+=(
      DISPLAY
      X11_BASE_RULES_XML
      X11_EXTRA_RULES_XML
      XCURSOR_PATH
    )
    paths_ro+=(
      /tmp/.ICE-unix
      /tmp/.X11-unix
    )
  fi
  pass_env_names+=(
    DBUS_SESSION_BUS_ADDRESS
    GTK_PATH
    NIXOS_OZONE_WL
    NIX_XDG_DESKTOP_PORTAL
    QT_AUTO_SCREEN_SCALE_FACTOR
    QT_ENABLE_HIGHDPI_SCALING
    QT_PLUGIN_PATH
    QT_QPA_PLATFORMTHEME
    QT_QPA_PLATFORM
    QT_STYLE_OVERRIDE
    QTWEBKIT_PLUGIN_PATH
    XDG_CURRENT_DESKTOP
    XDG_SESSION_DESKTOP
  )
  paths_ro+=(
    /etc/xdg
    /var/cache/fontconfig
    /run/dbus
    /sys
    "$xdg_runtime_dir/at-spi/bus_1"
    "$xdg_runtime_dir/bus"
    "$xdg_runtime_dir/pulse/native"
    "$xdg_runtime_dir/pipewire-0"
    "$xdg_runtime_dir/xdg-dbus-proxy"
    "$home/.config/pulse/cookie"
  )
  paths_rw+=(
    "$xdg_cache_home/fontconfig"
    "$xdg_cache_home/mesa_shader_cache"
    "$xdg_cache_home/mesa_shader_cache_db"
    "$xdg_cache_home/nv"
    "$xdg_cache_home/nvidia"
    "$xdg_cache_home/radv_builtin_shaders"
    "$xdg_cache_home/radv_builtin_shaders64"
  )
fi

if ((profile_helix)); then
  paths_rw+=(
    "$xdg_cache_home/helix"
    "$xdg_config_home/helix"
  )
fi

if ((profile_opencode)); then
  paths_ro+=(
    "$xdg_config_home/openspec"
  )
  paths_rw+=(
    /etc/nixos
    "$xdg_cache_home/opencode"
    "$xdg_config_home/opencode"
    "$xdg_data_home/opencode"
    "$xdg_data_home/opentui"
    "$xdg_state_home/opencode"
  )
  mkdir -p \
    "$xdg_cache_home/opencode" \
    "$xdg_config_home/opencode" \
    "$xdg_data_home/opencode" \
    "$xdg_data_home/opentui" \
    "$xdg_state_home/opencode"
  # yolo
  opencode_yolo_permissions='{"bash": "allow"}'
  OPENCODE_PERMISSION="${OPENCODE_PERMISSION:-$opencode_yolo_permissions}"
fi

if ((profile_zed)); then
  use_landrun=0
  paths_rw+=(
    "$xdg_cache_home/zed"
    "$xdg_config_home/zed"
    "$xdg_data_home/zed"
  )
fi

bwrap_env_args=(
  --clearenv
  --setenv HOME "$home"
  --setenv USER "${USER:-user}"
  --setenv LOGNAME "${LOGNAME:-${USER:-user}}"
  --setenv SHELL "${SHELL:-/bin/sh}"
  --setenv TERM "${TERM:-xterm-256color}"
  --setenv LANG "${LANG:-C.UTF-8}"
  --setenv TMPDIR /tmp
  --setenv XDG_CACHE_HOME "$xdg_cache_home"
  --setenv XDG_CONFIG_HOME "$xdg_config_home"
  --setenv XDG_DATA_HOME "$xdg_data_home"
  --setenv XDG_RUNTIME_DIR "$xdg_runtime_dir"
  --setenv XDG_STATE_HOME "$xdg_state_home"
  --setenv UV_LINK_MODE copy
)

for name in "${pass_env_names[@]}"; do
  if [[ -v $name ]]; then
    bwrap_env_args+=(--setenv "$name" "${!name}")
  fi
done

#
# bubblewrap mounts
#

bwrap_args=(
  --unshare-all
  --new-session
  --die-with-parent

  --dev /dev
  --proc /proc

  --tmpfs /tmp
  --tmpfs /var/tmp
  --tmpfs /run
  --tmpfs /sys
  --dir "$xdg_runtime_dir"
  --dir "$HOME"

  # --cap-drop ALL
  # --cap-add CAP_SYS_NICE
  --chdir "$cwd"
)

if ((allow_network)); then
  bwrap_args+=(--share-net)
fi

if ((profile_gpu)); then
  for p in "${gpu_devs[@]}"; do
    bwrap_args+=(--dev-bind-try "$p" "$p")
  done
fi

if ((profile_gui)); then
  bwrap_args+=(--dev-bind-try "/dev/input" "/dev/input")
fi

for p in "${paths_ro[@]}"; do
  bwrap_args+=(--ro-bind-try "$p" "$p")
done

for p in "${paths_rox[@]}"; do
  bwrap_args+=(--ro-bind-try "$p" "$p")
done

for p in "${paths_rw[@]}"; do
  bwrap_args+=(--bind-try "$p" "$p")
done

for p in "${paths_rwx[@]}"; do
  bwrap_args+=(--bind-try "$p" "$p")
done

#
# Optional landrun policy
#

inner_cmd=("$@")

if [[ $use_landrun == yes ]]; then
  landrun_args=(
    --best-effort

    --ro /etc

    --rw /dev  # internal bwrap's devices or binded devices
    --rw /proc # internal bwrap's procfs
    --rw /sys  # emptry tmpfs + binds
    --rw /tmp
    --rw /var/tmp
    --rw "$xdg_runtime_dir"
  )

  if ((enable_debug)); then
    landrun_args+=(--log-level debug)
  fi

  if ((allow_network)); then
    landrun_args+=(--unrestricted-network)
  fi

  for p in "${paths_ro[@]}"; do
    [[ -e $p ]] && landrun_args+=(--ro "$p")
  done

  for p in "${paths_rox[@]}"; do
    [[ -e $p ]] && landrun_args+=(--rox "$p")
  done

  for p in "${paths_rw[@]}"; do
    [[ -e $p ]] && landrun_args+=(--rw "$p")
  done

  for p in "${paths_rwx[@]}"; do
    [[ -e $p ]] && landrun_args+=(--rwx "$p")
  done

  for name in "${pass_env_names[@]}"; do
    landrun_args+=(--env "$name")
  done

  inner_cmd=(landrun "${landrun_args[@]}" -- "${inner_cmd[@]}")
fi

if [[ -t 0 && -t 1 ]]; then
  printf -v inner_cmd_str '%q ' "${inner_cmd[@]}"
  inner_cmd=(script -qefc "$inner_cmd_str" /dev/null)
fi

sandbox_cmd=(
  bwrap
  "${bwrap_args[@]}"
  "${bwrap_env_args[@]}"
  --
  "${inner_cmd[@]}"
)

$dry_run exec "${sandbox_cmd[@]}"
