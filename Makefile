## ********************************************************************* ##
## Copyright 2016                                                        ##
## David Farmer, Greg Hartman, Alex Jordan, Carly Vollet                 ##
##                                                                       ##
## This file is part of APEX Calculus                                    ##
##                                                                       ##
## ********************************************************************* ##

#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Make a copy of Makefile.paths.original
#      as Makefile.paths, which git will ignore.
#   2) Edit Makefile.paths to provide full paths to the root folders
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it does not
# operate on dependencies.  It is more of a shell
# script, sharing common configurations

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   xmllint         (only to check source against DTD)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Navigate to the location of this file
#	B) At command line:  make <some-target-from-the-options-below>

# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
include Makefile.paths

###################################
# These paths are subdirectories of
# the project distribution
###################################
SRC       = $(PRJ)/ptx
IMGSRC    = $(SRC)/images
OUTPUT    = $(PRJ)/output
STYLE     = $(PRJ)/style
XSL       = $(PRJ)/xsl

# The project's root file
MAINFILE  = $(SRC)/index.ptx

# These paths are subdirectories of
# the PreTeXt distribution
PTXXSL = $(PTX)/xsl

# These paths are subdirectories of the output
# folder for different output formats
PRINTOUT   = $(OUTPUT)/print
HTMLOUT    = $(OUTPUT)/html
WWOUT      = $(OUTPUT)/webwork-extraction
IMGOUT     = $(OUTPUT)/images
PGOUT      = $(OUTPUT)/pg
PRVOUT     = $(OUTPUT)/preview

# The WeBWorK server we use
#SERVER = "(https://webwork-dev.aimath.org,anonymous,anonymous,anonymous,anonymous)"
SERVER = "(https://webwork.pcc.edu,orcca,orcca,anonymous,orcca)"
#SERVER = http://localhost

webwork-extraction:
	-rm -r $(WWOUT) || :
	install -d $(WWOUT)
	$(PTX)/pretext/pretext -vv -a -c webwork -d $(WWOUT) -s $(SERVER) $(MAINFILE)

merge:
	cd $(OUTPUT); \
	xsltproc --xinclude --stringparam webwork.extraction $(WWOUT)/webwork-extraction.xml $(PTXXSL)/pretext-merge.xsl $(MAINFILE) > merge.xml

pg:
	-rm -r $(PGOUT) || :
	install -d $(PGOUT)
	cd $(PGOUT); \
	xsltproc --xinclude --stringparam chunk.level 2 $(PTXXSL)/pretext-ww-problem-sets.xsl $(OUTPUT)/merge.xml

html:
	install -d $(OUTPUT)
	-rm -r $(HTMLOUT) || :
	install -d $(HTMLOUT)
	install -d $(HTMLOUT)/images
	install -d $(IMGOUT)
	install -d $(IMGSRC)
	cp -a $(IMGOUT) $(HTMLOUT) || :
	cp -a $(IMGSRC) $(HTMLOUT) || :
	cp -a $(WWOUT)/*.png $(HTMLOUT)/images || :
	cd $(HTMLOUT); \
	xsltproc -xinclude --stringparam html.calculator geogebra-graphing --stringparam exercise.inline.hint no --stringparam exercise.inline.answer no --stringparam exercise.inline.solution yes --stringparam exercise.divisional.hint no --stringparam exercise.divisional.answer no --stringparam exercise.divisional.solution no --stringparam html.knowl.exercise.inline no --stringparam html.knowl.example no $(PTXXSL)/pretext-html.xsl $(OUTPUT)/merge.xml; \

images:
	install -d $(OUTPUT)
	-rm $(IMGOUT) || :
	install -d $(IMGOUT)
	$(PTX)/pretext/pretext -c latex-image -f all -d $(IMGOUT) $(OUTPUT)/merge.xml

pdf:
	install -d $(OUTPUT)
	-rm -r $(PRINTOUT) || :
	install -d $(PRINTOUT)
	install -d $(PRINTOUT)/images
	install -d $(IMGOUT)
	install -d $(IMGSRC)
	cp -a $(WWOUT)/*.png $(PRINTOUT)/images || :
	cp -a $(IMGSRC) $(PRINTOUT) || :
	cd $(PRINTOUT); \
	xsltproc -xinclude --stringparam latex.print 'yes' --stringparam latex.pageref 'no' --stringparam latex.sides 'two' --stringparam exercise.divisional.answer no --stringparam exercise.divisional.solution no --stringparam exercise.divisional.hint no $(PTXXSL)/pretext-latex.xsl $(OUTPUT)/merge.xml > apex.tex; \
	xelatex apex.tex; \
	xelatex apex.tex; \


###########
# Utilities
###########

check:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/jingreport.txt
	-java -classpath ~/jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration -jar ~/jing-trang/build/jing.jar $(PTX)/schema/pretext.rng $(MAINFILE) > $(OUTPUT)/jingreport.txt
	less $(OUTPUT)/jingreport.txt
