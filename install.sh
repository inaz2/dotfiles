#!/bin/sh

for i in *; do
    if [[ $i == 'install.sh' || $i == 'README' ]]; then
        continue
    fi
    ln -s $PWD/$i ~/.$i
done
