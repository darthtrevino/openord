#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/../bin"
DATA_DIR="$SCRIPT_DIR/data"
OUT_DIR="$SCRIPT_DIR/../output/realtime"

mkdir -p $OUT_DIR

# copy data to working folder
cp $DATA_DIR/yeast_90.sim $OUT_DIR/yeast_90.sim

# execute the layout in an output folder
pushd $OUT_DIR

#
# The last feature that might be of interest in OpenOrd is the real-time
# clustering option, which allows you to add new points to an existing
# layout. For an example of the real-time option, go to the realtime
# directory. There you will find yeast.sim, and yeast_90.sim, which
# contains the first 90% of yeast.sim.
#
# First you have to create a layout using the yeast_90.sim file:
#
$BIN_DIR/truncate yeast_90
$BIN_DIR/layout yeast_90
$BIN_DIR/recoord yeast_90

#
# Use the 90 layout as a starting point for the entire dataset
#
cp yeast_90.coord yeast.coord

#
# Finally you can use the base layout with the entire yeast.sim file. The
# -r flag in layout specifies the length of time to leave the coordinates
# from the .real file fixed (below we leave them permanently fixed).
#
$BIN_DIR/layout -r 1 yeast
$BIN_DIR/recoord yeast