#!/bin/bash

script_path=$(readlink -e "$0")
script_dir="${script_path%/*}"
script_name="${script_path##*/}"

cd "$script_dir"
for i in *; do
    case "$i" in
    $script_name|README)
        ;;
    *)
        ln -i --backup --suffix .bak -s "$PWD/$i" "$HOME/.$i"
        ;;
    esac
done
