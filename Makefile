#***************************************************************************
#                               Makefile
#                          -------------------
#
#  _________________________________________________________________________
#    Build for DrL
#  _________________________________________________________________________
#
#    begin                : Sat Oct 29 2005
#    copyright            : (C) 2005 by W. Michael Brown
#    email                : wmbrown@sandia.gov
# ***************************************************************************/

include ./Configuration.mk
SRC_DIR = ./src
OBJ_DIR = $(HOBJ_DIR)
VX_O     = $(OBJ_DIR)/layout.o $(OBJ_DIR)/parse.o \
           $(OBJ_DIR)/DensityGrid.o $(OBJ_DIR)/graph.o
VX_E     = $(BIN_DIR)/layout
REC_O 	 = $(OBJ_DIR)/average_link.o $(OBJ_DIR)/average_link_clust.o $(OBJ_DIR)/average_link_parse.o \
	   $(OBJ_DIR)/recoord.o $(OBJ_DIR)/recoord_parse.o \
	   $(OBJ_DIR)/coarsen.o $(OBJ_DIR)/coarsen_parse.o $(OBJ_DIR)/refine.o \
	   $(OBJ_DIR)/refine_parse.o $(OBJ_DIR)/truncate.o $(OBJ_DIR)/truncate_parse.o
REC_E	 = $(BIN_DIR)/truncate $(BIN_DIR)/average_link $(BIN_DIR)/coarsen $(BIN_DIR)/refine $(BIN_DIR)/recoord

all: $(VX_O) $(VX_E) $(REC_O) $(REC_E)

$(OBJ_DIR)/truncate.o: $(SRC_DIR)/truncate.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/truncate.cpp

$(OBJ_DIR)/truncate_parse.o: $(SRC_DIR)/truncate_parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/truncate_parse.cpp

$(OBJ_DIR)/recoord.o: $(SRC_DIR)/recoord.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/recoord.cpp

$(OBJ_DIR)/recoord_parse.o: $(SRC_DIR)/recoord_parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/recoord_parse.cpp

$(OBJ_DIR)/average_link.o: $(SRC_DIR)/average_link.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/average_link.cpp

$(OBJ_DIR)/average_link_clust.o: $(SRC_DIR)/average_link_clust.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/average_link_clust.cpp

$(OBJ_DIR)/average_link_parse.o: $(SRC_DIR)/average_link_parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/average_link_parse.cpp

$(OBJ_DIR)/coarsen.o: $(SRC_DIR)/coarsen.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/coarsen.cpp

$(OBJ_DIR)/coarsen_parse.o: $(SRC_DIR)/coarsen_parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/coarsen_parse.cpp

$(OBJ_DIR)/refine.o: $(SRC_DIR)/refine.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/refine.cpp

$(OBJ_DIR)/refine_parse.o: $(SRC_DIR)/refine_parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/refine_parse.cpp

$(OBJ_DIR)/layout.o: $(SRC_DIR)/layout.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/layout.cpp

$(OBJ_DIR)/parse.o: $(SRC_DIR)/parse.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/parse.cpp

$(OBJ_DIR)/DensityGrid.o: $(SRC_DIR)/DensityGrid.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/DensityGrid.cpp

$(OBJ_DIR)/graph.o: $(SRC_DIR)/graph.cpp
	$(CPP) $(CFLAGS) -o $@ $(SRC_DIR)/graph.cpp

$(BIN_DIR)/truncate: $(OBJ_DIR)/truncate.o
	$(CPP) $(LFLAGS) -o $@ $(OBJ_DIR)/truncate.o $(OBJ_DIR)/truncate_parse.o

$(BIN_DIR)/recoord: $(OBJ_DIR)/recoord.o
	$(CPP) $(LFLAGS) -o $@ $(OBJ_DIR)/recoord.o $(OBJ_DIR)/recoord_parse.o

$(BIN_DIR)/average_link: $(OBJ_DIR)/average_link.o
	$(CPP) $(LFLAGS) -o $@ $(OBJ_DIR)/average_link.o $(OBJ_DIR)/average_link_clust.o $(OBJ_DIR)/average_link_parse.o
	
$(BIN_DIR)/coarsen: $(OBJ_DIR)/coarsen.o
	$(CPP) $(LFLAGS) -o $@ $(OBJ_DIR)/coarsen.o $(OBJ_DIR)/coarsen_parse.o

$(BIN_DIR)/refine: $(OBJ_DIR)/refine.o
	$(CPP) $(LFLAGS) -o $@ $(OBJ_DIR)/refine.o $(OBJ_DIR)/refine_parse.o

$(BIN_DIR)/layout: $(VX_O)
	$(CPP) $(LFLAGS) -o $@ $(VX_O)


#
#  Remove objects, cores, etc.
#

clean:
	rm -rf *.o $(VX_O) $(VX_E) $(REC_O) $(REC_E) \
	  a.out core test *.exe Makefile.win Makefile.am*

veryclean: clean
	rm -rf *~ ./api
