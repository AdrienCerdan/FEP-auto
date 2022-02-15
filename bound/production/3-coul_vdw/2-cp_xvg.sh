#!/bin/bash

if [ ! -d "dHdl_files" ]; then
  mkdir dHdl_files
fi

for i in $(ls | grep "lambda.*"); do 
  lam="${i##*.}"
  cp ./$i/PROD/dhdl.xvg ./dHdl_files/dhdl.$lam.xvg
done
