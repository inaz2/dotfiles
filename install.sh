#!/bin/bash

shopt -s extglob

script_path="$PWD/$0"
script_dir="${script_path%/*}"
script_name="${script_path##*/}"

cd "$script_dir"
for i in !($script_name|README); do
    ln -s "$PWD/$i" "$HOME/.$i"
done
