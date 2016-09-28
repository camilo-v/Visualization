#!/usr/local/bin/Rscript
# ---------------------------------------------------------------------------------------------------------------------
#
#                             			Florida International University
#                                          			Data Mining
#
#   This software is a "Camilo Valdes Work" under the terms of the United States Copyright Act.
#   Please cite the author(s) in any work or product based on this material.
#
#   OBJECTIVE:
#	The purpose of this program is to implement question No. 1 (Section 3) and question 17 (Section 5.10) of Homework 2.
#	Obtain one of the datasets available at the UCI Machine Learning Repository and apply as many of the different 
#	visualization techniques described in the chapter as possible.
#	
#
#	To run this code you have to adjust the variables 'working_directory' and 'homeworkDirectory' to match the
#	directory structure of the machine you are working on.
#
#
#   NOTES:
#   Please see the dependencies section below for the required libraries (if any).
#
#   DEPENDENCIES:
#
#		• ggplot2
#       • reshape2
#		• class
#		• RColorBrewer
#		• corrplot
#		• GGally
#		• plotROC
#
#
#   AUTHOR:	Camilo Valdes (cvalde03@fiu.edu)
#			Bioinformatics Research Group,
#			School of Computing and Information Sciences, 
#			Florida International University (FIU)
#
#
# ---------------------------------------------------------------------------------------------------------------------


# 	Import any necessary libraries here
library(ggplot2)
library(RColorBrewer)
library(reshape2)
library(corrplot)
library(GGally)
library(plotROC)


# 	Enable printing of large numbers. R defaults to "rounding" for display, and
# 	Cause the warnings to be printed as they occur.
options( width=512, digits=15, warn=1 )


#
#	Custom Colors for Color Blind folks
#
# 	The palette with black:
cbbPalette_black = c( "#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7" )

# 	The palette with grey:
cbPalette_grey = c( "#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7" )


# ------------------------------------------------- Project Setup -----------------------------------------------------

print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] ", sep="") )
print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] R Starting... ", sep="") )
print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] ", sep="") )


working_directory="/path/to/working/directory/"
setwd( file.path( working_directory ) )

projectNumber = "2"
homeworkDirectory = paste( working_directory, "/project_", projectNumber, sep="" )

figures_base_dir=paste( homeworkDirectory, "/figures", sep="")
png_output_dir=paste( figures_base_dir, "/png", sep="" )

dir.create( file.path( png_output_dir ), showWarnings=FALSE, recursive=TRUE )



# ------------------------------------------------------ Main ---------------------------------------------------------
#
#	As per question 1, we'll import one of the datasets from the UCI Machine Learning Repository
#	Note that some of these datasets are built into R, so we do not have to import any external files.  All that
#	is required to import the datasets is to import the necessary R libraries & modules that contain the data.
#

#	The data we'll be using is the 'iris' dataset (Fisher, 1936)
#	After the call to 'data()', the data is available in the 'iris' object.
data(iris)

#
#	iris Data
#	Note that this dataset is in 'long-format' form.  It contains one column for the possible variable tyes, followed
#	by multiple columns for the values of those variables. The available columns for the iris dataset are:
#
#		- Sepal.Length 
#		- Sepal.Width
#		- Petal.Length
#		- Petal.Width
#		- Species
#
#	Having the data in this format is an advantage, as the GGplot2 libraries expect their input data in that format.	
#
iris


# ------------------------------------------------------ Plots --------------------------------------------------------
#
#	The following plots will be created using GGplot2.
#		- Histogram
#		- Boxplot
#		- Scatter Plot
#

#
#	Histogram
#
histogramPlot = ggplot(iris, aes(x=Sepal.Length) ) +
					geom_histogram( aes(y=..density..), binwidth=.1, colour="black", fill="grey" ) +
					geom_density(alpha=.2, fill="#FF6666") + 
					facet_grid(Species ~ .) +
					ggtitle( paste( "Histogram - Iris Data", sep="" ) ) +
					theme(legend.position="top")

histogramPlot
outputFileForHistogram	= paste( png_output_dir, "/histogram", ".png", sep="" )
ggsave(outputFileForHistogram)



#
#	Box Plot
#
boxPlot = ggplot(iris, aes(x=Species, y=Sepal.Length, fill=Species)) +
			geom_boxplot( outlier.colour = "red" ) +
			ggtitle( paste( "Box Plot - Iris Data", sep="" ) ) + 
			theme(legend.position="top")

boxPlot
outputFileForBoxPlot	= paste( png_output_dir, "/boxplot", ".png", sep="" )
ggsave(outputFileForBoxPlot)



#
#	Scatter Plot
#
scatterPlot = ggplot( iris, aes(x=Sepal.Length, y=Sepal.Width, color=Species, shape=Species) ) +
				geom_point() +
				geom_smooth(method=lm) +
				ggtitle( paste( "ScatterPlot - Iris Data", sep="" ) ) + 
				theme(legend.position="top")

scatterPlot
outputFileForScatterPlot	= paste( png_output_dir, "/scatterplot", ".png", sep="" )
ggsave(outputFileForScatterPlot)



#
#	Correlation Matrix
#	We'll first create a correlation matrix for the iris dataset, and then we'll use the package 'corrplot'
#	to display the results
#

correlationMatrixForIris = cor(iris[,1:4])

corrplot(correlationMatrixForIris)
png( paste( png_output_dir, "/correlation_matrix.png", sep="" ), width=1024, height=1024, units="px", res=120 )
corrplot( correlationMatrixForIris, title="Correlation Matrix - Iris Data", mar=c(0,0,1,0))
dev.off()



#
#	Parallel Coordinate Plot
#	Note: higher 'splineFactor' gives smoother curves
#
parallelCoordinatePlot = ggparcoord( data=iris, columns=1:4, groupColumn=5, order="anyClass", 
									showPoints=TRUE, alphaLines=0.4, splineFactor=10 ) +
									ggtitle( paste( "Parallel Coordinates - Iris Data", sep="" ) ) +
									xlab("Species") +
									ylab( "F-Statistic Value" ) +
									theme(legend.position="top")

parallelCoordinatePlot
outputFileForParallelCoordinatePlot	= paste( png_output_dir, "/parallel_coordinates", ".png", sep="" )
ggsave(outputFileForParallelCoordinatePlot)





# ------------------------------------------------------ ROC Curve --------------------------------------------------------
#
#	The code below contains the code to draw the ROC curve for question 17, Section 5.10
#

#
#	Model 1 data
#
model1_output 	= c(0.73, 0.69, 0.67, 0.55, 0.47, 0.45, 0.44, 0.35, 0.15, 0.08)
model1_class 	= c(1, 1, 1, 0, 1, 1, 0, 0, 0, 0)

#
#	Model 2 data
#
model2_output 	= c(0.68, 0.61, 0.45, 0.38, 0.31, 0.09, 0.05, 0.04, 0.03, 0.01)
model2_class 	= c(0, 1, 1, 0, 0, 1, 0, 0, 1, 1)

#
#	Models in Long-form format
#
model_class 	= c(1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1)
model_output 	= c(0.73, 0.69, 0.67, 0.55, 0.47, 0.45, 0.44, 0.35, 0.15, 0.08, 0.68, 0.61, 0.45, 0.38, 0.31, 0.09, 0.05, 0.04, 0.03, 0.01)
model_name 		= c('m1', 'm1', 'm1', 'm1', 'm1', 'm1', 'm1', 'm1', 'm1', 'm1', 'm2', 'm2', 'm2', 'm2', 'm2', 'm2', 'm2', 'm2', 'm2', 'm2')


modelDataFrame = data.frame(D=model_class, M=model_output, model.name=model_name, stringsAsFactors=FALSE)
modelDataFrame


#
#	ROC Curve
#			
roc_curve = ggplot( modelDataFrame, aes( d=D, m=M, color=model.name) ) + 
				geom_roc() + style_roc() +
				geom_abline(intercept=0, slope=1, color="blue") +
				ggtitle( paste( "ROC Curve", sep="" ) ) +
				xlab("False Positive (1-Specificity)") +
				ylab( "True Positive (Sensitivity)" ) +
				theme(legend.position="top")

roc_curve
outputFileForROCCurve	= paste( png_output_dir, "/roc_curve", ".png", sep="" )
ggsave(outputFileForROCCurve)





# ------------------------------------------------------ END ---------------------------------------------------------

print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] ", sep="") )
print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] Done.", sep="") )
print( paste( "[", format(Sys.time(), "%m/%d/%y %H:%M:%S"),"] ", sep="") )

