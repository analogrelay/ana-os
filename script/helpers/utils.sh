declare -a colors
color_black="$(echo -e "\033[30m")"
color_red="$(echo -e "\033[31m")"
color_green="$(echo -e "\033[32m")"
color_yellow="$(echo -e "\033[33m")"
color_blue="$(echo -e "\033[34m")"
color_magenta="$(echo -e "\033[35m")"
color_cyan="$(echo -e "\033[36m")"
color_white="$(echo -e "\033[37m")"
color_reset="$(echo -e "\033[0m")"

required_config_generation=1

if ! type gum 2>&1 >/dev/null; then
    echo "Install 'gum' from https://github.com/charmbracelet/gum before continuing"
    exit 1
fi

if ! type jq 2>&1 >/dev/null; then
    echo "Install 'jq' before continuing"
    exit 1
fi

info() {
    echo "$(gum style --foreground 2 "info"): $@"
}

error() {
    echo "$(gum style --foreground 1 "error"): $@"
}

fatal() {
    error "$@"
    exit 1
}

spin() {
    title="$1"
    shift
    gum spin -s dot --show-output --title "$title" -- "$@"
}

debug() {
    if [ "$DEBUG" = "1" ] || [ "$ANAOS_BUILD_DEBUG" = 1 ]; then
        echo "$(gum style --foreground 5 "debug"): $@"
    fi
}

load_config() {
    [ ! -f ".config/activate" ] && fatal "Please run 'script/bootstrap' before continuing"
    [ -f ".config/activate" ] && source ".config/activate"

    if [ "$config_generation" != "$required_config_generation" ]; then
        fatal "Config is out of date, re-run 'script/bootstrap' to update"
    fi
}

save_config() {
    case "$target_arch" in
        aarch64)
            uefi_image_name="bootaa64.efi"
            ;;
        x86_64)
            uefi_image_name="bootx64.efi"
            ;;
        *)
            fatal "Unsupported architecture '$target_arch'"
            ;;
    esac

    kernel_target=$target_arch-ana_os

    echo "config_generation=$required_config_generation" >> ".config/activate"
    echo "configuration=$configuration" >> ".config/activate"
    echo "target_arch=$target_arch" >> ".config/activate"
    echo "target_machine=$target_machine" >> ".config/activate"
    echo "kernel_target=$kernel_target" >> ".config/activate"
    echo "kernel_target_path=\"$root/targets/$kernel_target.json\"" >> ".config/activate"
    echo "qemu_system=qemu-system-$target_arch" >> ".config/activate"
    echo "uefi_image_name=$uefi_image_name" >> ".config/activate"
}

pick_default_machine() {
    arch="$1"
    case "$arch" in
        aarch64)
            echo "virt"
            ;;
        x86_64)
            echo "pc"
            ;;
        *)
            fatal "Unsupported architecture $arch"
            ;;
    esac
}