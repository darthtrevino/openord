#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/../bin_parallel"
DATA_DIR="$SCRIPT_DIR/data"
OUT_DIR="$SCRIPT_DIR/../output/parallel"

mkdir -p $OUT_DIR

# copy data to working folder
cp $DATA_DIR/yeast.sim $OUT_DIR/yeast.sim

# execute the layout in an output folder
pushd $OUT_DIR

$BIN_DIR/truncate yeast
mpirun -n 4 $BIN/layout yeast
$BIN_DIR/recoord yeast