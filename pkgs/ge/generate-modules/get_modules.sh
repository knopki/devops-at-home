# shellcheck shell=bash

upfind() {
    if ls -d "$1/$2" 2>/dev/null 1>&2; then
        dirname "$1"
    else
        upfind "../$1" "$2"
    fi
}

gen_modules() {
    paths=$(
        (
            find "$1" -name "default.nix" | sed "s|/default.nix\$||"
            # shellcheck disable=SC2185
            find "$1" -type d '!' -exec test -e "{}/default.nix" \; -print0 |
                find -files0-from - -maxdepth 1 \
                    \( -name "*.nix" -and -not -name "module-attrset.nix" \)
        ) | sort
    )
    content=$(echo "$paths" | sed "s|$1/||" | (
        echo "{"
        while read -r path; do
            key=$(echo "$path" | sed "s|.nix$||" | sed "s|/|-|g")
            printf "%s = %s;\n" "$key" "./$path"
        done
        echo "}"
    ))
    filename="$1/module-attrset.nix"
    echo "$content" >"$filename.tmp.nix"
    nix fmt "$filename.tmp.nix"
    mv "$filename.tmp.nix" "$filename"
}

ROOT=$(upfind . flake.nix)

gen_modules "$ROOT/modules/home"
gen_modules "$ROOT/modules/nixos"
