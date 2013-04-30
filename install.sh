#!/bin/bash

script_path="$PWD/$0"
script_dir="${script_path%/*}"
script_name="${script_path##*/}"

cd "$script_dir"
for i in *; do
    case "$i" in
    $script_name|README)
        ;;
    *)
        ln -s "$PWD/$i" "$HOME/.$i"
        ;;
    esac
done
