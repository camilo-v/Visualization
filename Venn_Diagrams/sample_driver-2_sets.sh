#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------
#
#                                   		Center for Computational Science
#												http://www.ccs.miami.edu/
#                             			  			University of Miami
#
#   This software is a "University of Miami Work" under the terms of the United States Copyright Act.
#   Please cite the author(s) in any work or product based on this material.
#
#   OBJECTIVE:
#	The purpose of this script is to act as a driving script for 'venn_diagrams.py'.  This bash script supplies the
#	aforementioned Python script with the requisite lists that will be used to create the venn diagram.
#
#
#   NOTES:
#   Please see the dependencies section below for the required libraries, modules, and/or scripts.
#
#
#   DEPENDENCIES:
#
#       • venn_diagrams.py.
#
#
#	AUTHOR:	Camilo Valdes (cvaldes3@miami.edu)
#			Computational Biology and Bioinformatics Group
#			Center for Computational Science (CCS), University of Miami
#
#
# ---------------------------------------------------------------------------------------------------------------------

echo ""
echo "[" `date '+%m/%d/%y %H:%M:%S'` "]"
echo "[" `date '+%m/%d/%y %H:%M:%S'` "] Starting..."
echo "[" `date '+%m/%d/%y %H:%M:%S'` "]"

# ---------------------------------------------------- Run Params -----------------------------------------------------


BASE_DIR="/Base/Directory/To/Use"

APP_PATH=$BASE_DIR"/Directory/Location/Of/The/Python/Script"

AFFIX_FOR_DIAGRAM="NAME_OF_OUTPUT_DIRECTORY"

OUTPUT_DIRECTORY=$BASE_DIR'/'$AFFIX_FOR_DIAGRAM

mkdir -p $OUTPUT_DIRECTORY



# -------------------------------------------------- Labels & Titles --------------------------------------------------

# 	Labels
#	These are the labels for each bubble in the venn diagram.  Labels should contain a distinct string that represents
#	each set.  The label will be drawn alongside the size (count) of the corresponding set.
#
LABEL_FOR_SET_1='label_for_set_1'

LABEL_FOR_SET_2='label_for_set_2'


#	Figure Title
#	A string that will be used as a centered title label for the venn diagram.
#
FIGURE_TITLE="title_for_venn_diagram"



# ------------------------------------------------------- Set 1 -------------------------------------------------------

FILE_WITH_LIST_1='/Path/To/Input/File/With/Set_1.txt'


# ------------------------------------------------------- Set 2 -------------------------------------------------------

FILE_WITH_LIST_2='/Path/To/Input/File/With/Set_1.txt'




# ---------------------------------------------------- Build & Run ----------------------------------------------------

$APP_PATH/script_venn_diagrams.py   --list1 $FILE_WITH_LIST_1 \
									--list2 $FILE_WITH_LIST_2 \
									-a $AFFIX_FOR_DIAGRAM \
									--label1 $LABEL_FOR_SET_1 \
									--label2 $LABEL_FOR_SET_2 \
									--title $FIGURE_TITLE \
									--out $OUTPUT_DIRECTORY



echo "[" `date '+%m/%d/%y %H:%M:%S'` "]"
echo "[" `date '+%m/%d/%y %H:%M:%S'` "] Done."
echo ""