#!/usr/bin/python
# coding: utf-8
#
# ---------------------------------------------------------------------------------------------------------------------
#
#                                           Center for Computational Science
#										        http://www.ccs.miami.edu/
#                             			            University of Miami
#
#   This software is a "University of Miami Work" under the terms of the United States Copyright Act.
#   Please cite the author(s) in any work or product based on this material.
#
#   OBJECTIVE:
#	The purpose of this program is to generate Venn Diagrams using the input lists (up to 3) given as command-line
#	arguments.  The script will utilize the 'matplotlib-venn' module to create and draw the Venn Diagram.  The lists
#	supplied in the arguments should be plain tab-delimited text files in Unicode (UTF-8) format, with Unix (LF)
#   line endings.  The input file should contain in the first column a list of unique identifiers (UUID, GeneID, etc.)
#   that the script will use as Python Sets — unordered collections with no duplicate elements.
#
#
#	NOTES:
#   This script is just a convenience wrapper around Python's 'matplotlib-venn' module, and it primarily facilitates
#   the creation of Venn diagrams from another script, e.g., a bash shell script. Please see the dependencies section
#   below for the required libraries.
#
#   DEPENDENCIES:
#
#       • matplotlib (http://matplotlib.org)
#       • matplotlib-venn (https://pypi.python.org/pypi/matplotlib-venn)
#
#
#
#   The above libraries & modules are required. You can check the modules currently installed in your
#   system by running: python -c "help('modules')"
#
#
#   USAGE:
#   Run the program with the "--help" flag to see usage instructions.
#
#
#	AUTHOR:	Camilo Valdes (cvaldes3@miami.edu)
#			Computational Biology and Bioinformatics Group
#			Center for Computational Science (CCS), University of Miami
#
#
# ---------------------------------------------------------------------------------------------------------------------

# 	Python Modules
import os, sys
import argparse
import time
import csv

import matplotlib_venn
from matplotlib_venn import *
from matplotlib import pyplot as plt

# ------------------------------------------------------ Main ---------------------------------------------------------

sys.stdout.flush()

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Python Venn Diagrams" + "" )

# 	Pick up the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument( "-l1", "--list1", required=True, type=str, help="List 1, will build Set A in Venn Diagram" )
parser.add_argument( "-l2", "--list2", required=False, type=str, help="List 2, will build Set B in Venn Diagram" )
parser.add_argument( "-l3", "--list3", required=False, type=str, help="List 3, will build Set C in Venn Diagram" )
parser.add_argument( "-lb1", "--label1", required=False, type=str, help="Label for List 1" )
parser.add_argument( "-lb2", "--label2", required=False, type=str, help="Label for List 2" )
parser.add_argument( "-lb3", "--label3", required=False, type=str, help="Label for List 3" )
parser.add_argument( "-a", "--affix", required=False, type=str, help="Affix for Output files" )
parser.add_argument( "-o", "--out", required=False, type=str, help="Output Directory for files" )
parser.add_argument( "-t", "--title", required=False, type=str, help="Title for Diagram" )
parser.add_argument( "-d", "--display", action="store_true", default=False, dest="boolean_display_switch", help="BOOL switch to save or display the plot")
args = parser.parse_args()

# 	Variables initialized from the command line arguments
filePathForSetA     = args.list1
filePathForSetB     = args.list2 if args.list2 is not None else ""
filePathForSetC     = args.list3 if args.list3 is not None else ""
labelForSetA        = args.label1 if args.label1 is not None else "List 1"
labelForSetB        = args.label2 if args.label2 is not None else "List 2"
labelForSetC        = args.label3 if args.label3 is not None else "List 3"
affixForOutputFile  = args.affix if args.affix is not None else "default_out"
output_directory    = args.out if args.out is not None else "./figures"
titleForDiagram     = args.title if args.title is not None else affixForOutputFile
displayPlot         = args.boolean_display_switch

# Remove any whitespaces around the file paths
filePathForSetA.strip()
filePathForSetB.strip()
filePathForSetC.strip()
labelForSetA.strip()
labelForSetB.strip()
labelForSetC.strip()

# Lists that we'll use to represent the Sets in the diagrams
set_A = set()   # Set A, list to hold the contents of the first file (at least 1 is required)
set_B = set()	# Set B, list to hold the contents of the second file (if one is provided)
set_C = set()	# Set C, list to hold the contents of the third file (if one is provided)

# Array to hold the files we need to process (up to 3 files supported)
arrayOfFilesToUse = []
arrayOfFilesToUse.append( filePathForSetA )
if filePathForSetB != "" : arrayOfFilesToUse.append( filePathForSetB )
if filePathForSetC != "" : arrayOfFilesToUse.append( filePathForSetC )

numberOfSetsInDiagram = len( arrayOfFilesToUse )
stringForNumberOfSetsInDiagram = '{:0,.0f}'.format( len( arrayOfFilesToUse ) )

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Number of Sets in Plot: " + stringForNumberOfSetsInDiagram + "" )

# -------------------------------------------- Output Files & Directories ---------------------------------------------

# We'll check if the output directory exists — either the default (current) or the requested one
if not os.path.exists( output_directory ):
    print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Output directory base does not exist.  Creating..." + "" )
    os.makedirs( output_directory )

if not os.path.exists( output_directory + "/figures" ):
    print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Output directory base/figures does not exist.  Creating..." + "" )
    os.makedirs( output_directory + "/figures" )

if not os.path.exists( output_directory + "/lists" ):
    print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Output directory base/lists does not exist.  Creating..." + "" )
    os.makedirs( output_directory + "/lists" )

suffixForOutputFile = ""

if( numberOfSetsInDiagram == 2 ):
    suffixForOutputFile = labelForSetA + "_" + labelForSetB
elif( numberOfSetsInDiagram == 3 ):
    suffixForOutputFile = labelForSetA + "_" + labelForSetB + "_" + labelForSetC

# PNG file
outputFileForVennFigure      = output_directory + "/figures/"+ "/vennDiagram-" + affixForOutputFile + "-" + stringForNumberOfSetsInDiagram + "-" + suffixForOutputFile + ".png"

# TXT files
outputFileForSetIntersection = output_directory + "/lists/" + "/intersection-" + affixForOutputFile + "-" + stringForNumberOfSetsInDiagram + "-" + suffixForOutputFile + ".txt"
outputFileForSetUnion        = output_directory + "/lists/" + "/union-" + affixForOutputFile + "-" + stringForNumberOfSetsInDiagram + "-" + suffixForOutputFile + ".txt"

# Writers
writerForSetIntersectionFile = csv.writer( open( outputFileForSetIntersection, "wb" ), delimiter='\t' )
writerForSetUnionFile        = csv.writer( open( outputFileForSetUnion, "wb" ), delimiter='\t' )


# --------------------------------------------------- File Loading ----------------------------------------------------

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Loading Files..." + "" )

for aFile in arrayOfFilesToUse:

    numberOfLinesInFile = 0

    with open( aFile,'r' ) as INFILE:

        reader = csv.reader( INFILE, delimiter='\t' )
        try:
            for row_line in reader:

                geneId = row_line[ 0 ]

                if aFile is filePathForSetA : set_A.add( geneId )

                if( len( arrayOfFilesToUse ) == 2 ):
                    if aFile is filePathForSetB : set_B.add( geneId )

                if( len( arrayOfFilesToUse ) == 3 ):
                    if aFile is filePathForSetB : set_B.add( geneId )
                    if aFile is filePathForSetC : set_C.add( geneId )

                numberOfLinesInFile += 1 # C'mon! Really? No "++" support in Python??? Perl can do this ;)

        except csv.Error as e:
            sys.exit( "File %s, line %d: %s" % ( aFile, reader.line_num, e ) )

    print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Number of Lines in file: " + '{:0,.0f}'.format(numberOfLinesInFile) + "" )


print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Inspecting Sets..." + "" )

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Set A: " + '{:0,.0f}'.format( len( set_A ) ) + "" )
print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Set B: " + '{:0,.0f}'.format( len( set_B ) ) + "" )
print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Set C: " + '{:0,.0f}'.format( len( set_C ) ) + "" )

# --------------------------------------------------- Venn Diagrams ---------------------------------------------------
#
#   We'll use the library matplotlib-venn to draw the Venn Diagrams.  The library contains two functions:
#   'venn2' and 'venn3' which take 2 and 3 sets respectively.
#

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Generating Venn Diagrams..." + "" )

labelForSetAWithCounts = labelForSetA + "\n(" + '{:0,.0f}'.format( len( set_A ) ) + ")"
labelForSetBWithCounts = labelForSetB + "\n(" + '{:0,.0f}'.format( len( set_B ) ) + ")"
labelForSetCWithCounts = labelForSetC + "\n(" + '{:0,.0f}'.format( len( set_C ) ) + ")"

if( len( arrayOfFilesToUse ) == 2 ):
    venn2( subsets = ( [ set_A, set_B ] ), set_labels = ( labelForSetAWithCounts, labelForSetBWithCounts ) )

if( len( arrayOfFilesToUse ) == 3 ):
    venn3( subsets = ( [ set_A, set_B, set_C ] ), set_labels = ( labelForSetAWithCounts, labelForSetBWithCounts, labelForSetCWithCounts ) )

plt.title( titleForDiagram )

#
# Display or Save the Venn Diagram depending on the request from the user
# show()        Displays the plot in a matplotlib GUI window
# savefig()     Saves the image to disk. Format is specified by file extension in savefig('file.png') function.
#
if( displayPlot ):
    plt.show()
else:
    plt.savefig( outputFileForVennFigure )


# --------------------------------------------------- Set Operations --------------------------------------------------
#
#   After we plot the Venn Diagrams, we'll compute the Set Intersections and Unions, and save the output.
#

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Calculating Intersections & Union..." + "" )

if( len( arrayOfFilesToUse ) == 2 ):    # Two Sets

    # Intersection
    setIntersection = set_A.intersection( set_B )

    for intersectedGeneId in setIntersection:
        writerForSetIntersectionFile.writerow( [ intersectedGeneId ] )

    # Union
    setUnion = set_A.union( set_B )

    for unionionizedGeneId in setUnion:
        writerForSetUnionFile.writerow([unionionizedGeneId])


if( len( arrayOfFilesToUse ) == 3 ):    # Three Sets

    # Intersection
    setIntersection = set_A.intersection( set_B, set_C )

    for intersectedGeneId in setIntersection:
        writerForSetIntersectionFile.writerow( [ intersectedGeneId ] )

    # Union
    setUnion = set_A.union( set_B, set_C )

    for unionionizedGeneId in setUnion:
        writerForSetUnionFile.writerow([unionionizedGeneId])


# ---------------------------------------------------- End of Line ----------------------------------------------------

print( "[ " + time.strftime('%d-%b-%Y %H:%M:%S',time.localtime()) + " ]" + " Done." + "\n" )

sys.exit()
