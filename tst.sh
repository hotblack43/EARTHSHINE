#!/bin/bash

path="OUTPUT/IDEAL/AUGMENTED/FOLDED/NOISY"

find "${path}" -maxdepth 1 -name 'folded_*' -type f -exec basename {} \; | while read -r file; do
  echo "${path}/${file}"
done > filesREMOVEME

