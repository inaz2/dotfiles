#!/bin/bash

shopt -s extglob
for i in !($0|README); do
    ln -s "$PWD/$i" "$HOME/.$i"
done
