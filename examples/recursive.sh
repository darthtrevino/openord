#!/bin/bash

# This is a shell script to run the recursive version of DrL.
#
# S. Martin
# 5/9/06

# the following files must be copied into the dataset directory
# and altered if necessary

# coarsen.parms	-- parameters for coarsening (usually default.parms)
# coarsest.parms -- parameters for the coarsest drawing (usually default.parms)
# refine.parms -- parameters for refining (usually refine.parms)
# final.parms -- parameters for final drawing (usually final.parms)

# the following variables must be changed to match the problem at hand

# parallel version information
MPI=0								# use mpiexec
MPIBIN=/home/smartin/recursive_layout/bin			# mpi bin
MPIDATA=/home/smartin/recursive_layout/datasets/yeast_gs	# mpi data

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$SCRIPT_DIR/../bin"				# regular bin directory
OUT_DIR="$SCRIPT_DIR/../output/recursive"
DATA_DIR="$SCRIPT_DIR/data"

# general inputs
ROOTNAME=yeast				# root name of project
MEMORY=1				# use multiple scans to conserve memory

# initial layout & clustering
TRUNCATE_LINKS=10	# initial truncation number of edges
INIT_CUT=1		# initial edge cutting parameter
INIT_NORM=0		# normalize during initial layout

# coarsening information
STARTLEVEL=1		# initial level (to avoid re-coarsening)
MAXLEVEL=2		# max level to coarsen
NORMALIZE=1		# normalize during coarsening
COARSE_CUT=1		# cutting level during coarsening

# coarsest layout information
LAST_CUT=.8		# cutting level for last layout

# refining information
SCALE=450		# scale coarsest layout up
REFINE_CUT=.5		# refining edge cut
FINAL_CUT=.5		# final edge cut

#### Set up the workspace
# prepare working directory
mkdir -p $OUT_DIR
# copy data to working folder
cp $DATA_DIR/yeast.sim $OUT_DIR/yeast.sim
# copy parms to working folder
cp $SCRIPT_DIR/recursive/*.parms $OUT_DIR
pushd $OUT_DIR

# calls start here:

if [ $STARTLEVEL -eq 1 ]
then

  echo "Cleaning old files ..."
  rm *coord
  rm *edges
  rm *int
  rm *.full
  rm *.real
  rm *.ind
  rm *.clust

  # first we truncate the original dataset and prepare the .int file
  echo "----- INITIAL TRUNCATION -----"
  if [ $INIT_NORM -eq 0 ]
  then
    echo $BIN_DIR"/truncate -t" $TRUNCATE_LINKS "-m" $MEMORY $ROOTNAME
    $BIN_DIR/truncate -t $TRUNCATE_LINKS -m $MEMORY $ROOTNAME
  else
    echo $BIN_DIR"truncate -n -t" $TRUNCATE_LINKS "-m" $MEMORY $ROOTNAME
    $BIN_DIR/truncate -n -t $TRUNCATE_LINKS -m $MEMORY $ROOTNAME
  fi

  # copy the .int file to .coarse_int
  echo "cp" $ROOTNAME".int" $ROOTNAME".coarse_int"
  cp $ROOTNAME".int" $ROOTNAME".coarse_int"

  # next we use layout to ordinate and output cut edges
  echo "----- INITIAL LAYOUT -----"

  # use coarsen parms
  echo "cp coarsen.parms" $ROOTNAME".parms"
  cp coarsen.parms $ROOTNAME".parms"

  if [ $MPI -eq 1 ]
  then
    echo "mpiexec" $MPIBIN"/layout -p -e -c" $INIT_CUT $MPIDATA"/"$ROOTNAME
    mpiexec $MPIBIN/layout -p -e -c $INIT_CUT $MPIDATA/$ROOTNAME
  else
    echo $BIN_DIR"/layout -p -e -c" $INIT_CUT $ROOTNAME
    $BIN_DIR/layout -p -e -c $INIT_CUT $ROOTNAME
  fi

else # end initial file creation

  echo "----- RESTARTING AT LEVEL" $STARTLEVEL "-----"
  let STARTLEVEL-=1

  # recover starting position
  if [ $STARTLEVEL -eq 1 ]
  then
    echo "mv" $ROOTNAME".coarse_icoord" $ROOTNAME".icoord"
    echo "mv" $ROOTNAME".coarse_iedges" $ROOTNAME".iedges"
    mv $ROOTNAME".coarse_icoord" $ROOTNAME".icoord"
    mv $ROOTNAME".coarse_iedges" $ROOTNAME".iedges"
  else
    echo "mv" $ROOTNAME"_"$STARTLEVEL".coarse_icoord" $ROOTNAME"_"$STARTLEVEL".icoord"
    echo "mv" $ROOTNAME"_"$STARTLEVEL".coarse_iedges" $ROOTNAME"_"$STARTLEVEL".iedges"
    mv $ROOTNAME"_"$STARTLEVEL".coarse_icoord" $ROOTNAME"_"$STARTLEVEL".icoord"
    mv $ROOTNAME"_"$STARTLEVEL".coarse_iedges" $ROOTNAME"_"$STARTLEVEL".iedges"
  fi

fi

# now we coarsen until MAXLEVEL is reached
LEVEL=$STARTLEVEL
while [ $LEVEL -lt $MAXLEVEL ]
do

  let LEVEL+=1

  echo "----- COARSENING AT LEVEL" $LEVEL "-----"

  let LEVEL-=1

  # now we use the average link clustering algorithm
  if [ $LEVEL -eq 1 ]
  then
    echo $BIN_DIR"/average_link" $ROOTNAME
    $BIN_DIR/average_link $ROOTNAME
    echo "mv" $ROOTNAME".icoord" $ROOTNAME".coarse_icoord"
    echo "mv" $ROOTNAME".iedges" $ROOTNAME".coarse_iedges"
    mv $ROOTNAME".icoord" $ROOTNAME".coarse_icoord"
    mv $ROOTNAME".iedges" $ROOTNAME".coarse_iedges"
  else
    echo $BIN_DIR"/average_link" $ROOTNAME"_"$LEVEL
    $BIN_DIR/average_link $ROOTNAME"_"$LEVEL
    echo "mv" $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".coarse_icoord"
    echo "mv" $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".coarse_iedges"
    mv $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".coarse_icoord"
    mv $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".coarse_iedges"
  fi

  let LEVEL+=1

  # now we coarsen
  if [ $NORMALIZE -eq 0 ]
  then
    echo $BIN_DIR"/coarsen -l" $LEVEL "-m" $MEMORY $ROOTNAME
    $BIN_DIR/coarsen -l $LEVEL -m $MEMORY $ROOTNAME
  else
    echo $BIN_DIR"/coarsen -l" $LEVEL "-n -m" $MEMORY $ROOTNAME
    $BIN_DIR/coarsen -l $LEVEL -n -m $MEMORY $ROOTNAME
  fi

  # save .int files to .coarse_int for later
  echo "cp" $ROOTNAME"_"$LEVEL".int" $ROOTNAME"_"$LEVEL".coarse_int"
  cp $ROOTNAME"_"$LEVEL".int" $ROOTNAME"_"$LEVEL".coarse_int"

  # and finally re-ordinate -- different for final layout
  if [ $LEVEL -eq $MAXLEVEL ]
  then

     # set parameters for coarsening
     echo "cp coarsest.parms" $ROOTNAME"_"$LEVEL".parms"
     cp coarsest.parms $ROOTNAME"_"$LEVEL".parms"

     if [ $MPI -eq 1 ]
     then
       echo "mpiexec" $MPIBIN"/layout -p -e -c" $LAST_CUT $MPIDATA"/"$ROOTNAME"_"$LEVEL
       mpiexec $MPIBIN/layout -p -e -c $LAST_CUT $MPIDATA/$ROOTNAME"_"$LEVEL
     else
       echo $BIN_DIR"/layout -p -e -c" $LAST_CUT $ROOTNAME"_"$LEVEL
       $BIN_DIR/layout -p -e -c $LAST_CUT $ROOTNAME"_"$LEVEL
     fi

  else 	

     # set parameters for coarsening
     echo "cp coarsen.parms" $ROOTNAME"_"$LEVEL".parms"
     cp coarsen.parms $ROOTNAME"_"$LEVEL".parms"

     if [ $MPI -eq 1 ]
     then
       echo "mpiexec" $MPIBIN"/layout -p -e -c" $COARSE_CUT $MPIDATA"/"$ROOTNAME"_"$LEVEL
       mpiexec $MPIBIN/layout -p -e -c $COARSE_CUT $MPIDATA/$ROOTNAME"_"$LEVEL
     else
       echo $BIN_DIR"/layout -p -e -c" $COARSE_CUT $ROOTNAME"_"$LEVEL
       $BIN_DIR/layout -p -e -c $COARSE_CUT $ROOTNAME"_"$LEVEL
     fi

  fi

done

# copy .icoord to .coarse_icoord for last ordination
if [ $LEVEL -gt 1 ]
then
  echo "cp" $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".coarse_iccord"
  echo "cp" $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".coarse_iedges"
  cp $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".coarse_icoord"
  cp $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".coarse_iedges"
else
  echo "cp" $ROOTNAME".icoord" $ROOTNAME".coarse_icoord"
  echo "cp" $ROOTNAME".iedges" $ROOTNAME".coarse_iedges"
  cp $ROOTNAME".icoord" $ROOTNAME".coarse_icoord"
  cp $ROOTNAME".iedges" $ROOTNAME".coarse_iedges"
fi

# now we refine until original level is reached
while [ $LEVEL -gt 1 ]
do

  echo "----- REFINING AT LEVEL" $LEVEL "-----"

  # refine
  echo $BIN_DIR"/refine -r -s" $SCALE "-l" $LEVEL $ROOTNAME
  $BIN_DIR/refine -r -s $SCALE -l $LEVEL $ROOTNAME

  let LEVEL-=1

  # and re-ordinate
  if [ $LEVEL -eq 1 ]
  then	# final layout

     echo "cp final.parms" $ROOTNAME".parms"
     cp final.parms $ROOTNAME".parms"

     echo "cp" $ROOTNAME".refine_int" $ROOTNAME".int"
     cp $ROOTNAME".refine_int" $ROOTNAME".int"

     if [ $MPI -eq 1 ]
     then
       echo "mpiexec" $MPIBIN"/layout -r 0 -p -e -c" $FINAL_CUT $MPIDATA"/"$ROOTNAME
       mpiexec $MPIBIN/layout -r 0 -p -e -c $FINAL_CUT $MPIDATA/$ROOTNAME
     else
       echo $BIN_DIR"/layout -r 0 -p -e -c" $FINAL_CUT $ROOTNAME
       $BIN_DIR/layout -r 0 -p -e -c $FINAL_CUT $ROOTNAME
     fi

     # now copy final coords and edges files
     echo "cp" $ROOTNAME".icoord" $ROOTNAME".refine_icoord"
     echo "cp" $ROOTNAME".iedges" $ROOTNAME".refine_iedges"
     cp $ROOTNAME".icoord" $ROOTNAME".refine_icoord"
     cp $ROOTNAME".iedges" $ROOTNAME".refine_iedges"

  else

     echo "cp refine.parms" $ROOTNAME"_"$LEVEL".parms"
     cp refine.parms $ROOTNAME"_"$LEVEL".parms"

     echo "cp" $ROOTNAME"_"$LEVEL".refine_int" $ROOTNAME"_"$LEVEL".int"
     cp $ROOTNAME"_"$LEVEL".refine_int" $ROOTNAME"_"$LEVEL".int"

     if [ $MPI -eq 1 ]
     then
       echo "mpiexec" $MPIBIN"/layout -r 0 -p -e -c" $REFINE_CUT $MPIDATA"/"$ROOTNAME"_"$LEVEL
       mpiexec $MPIBIN/layout -r 0 -p -e -c $REFINE_CUT $MPIDATA/$ROOTNAME"_"$LEVEL
     else
       echo $BIN_DIR"/layout -r 0 -p -e -c" $REFINE_CUT $ROOTNAME"_"$LEVEL
       $BIN_DIR/layout -r 0 -p -e -c $REFINE_CUT $ROOTNAME"_"$LEVEL
     fi

     echo "cp" $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".refine_iccord"
     echo "cp" $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".refine_iedges"
     cp $ROOTNAME"_"$LEVEL".icoord" $ROOTNAME"_"$LEVEL".refine_icoord"
     cp $ROOTNAME"_"$LEVEL".iedges" $ROOTNAME"_"$LEVEL".refine_iedges"

  fi

done

# finally we have to convert back to original coord file
echo "cp" $ROOTNAME".refine_icoord" $ROOTNAME".icoord"
cp $ROOTNAME".refine_icoord" $ROOTNAME".icoord"

echo "cp" $ROOTNAME".refine_iedges" $ROOTNAME".iedges"
cp $ROOTNAME".refine_iedges" $ROOTNAME".iedges"

echo $BIN_DIR"/recoord -e" $ROOTNAME
$BIN_DIR/recoord -e $ROOTNAME

# erase miscellaneous .ints, .icoords, .iedges, and .parms
rm *.int
rm *.icoord
rm *.iedges
rm $ROOTNAME*".parms"

echo "----- RECURSIVE LAYOUT SHELL COMPLETE -----"
