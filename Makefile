#
# Makefile for acmart package
#
# This file is in public domain
#
# $Id: Makefile,v 1.10 2016/04/14 21:55:57 boris Exp $
#

PACKAGE=acmart


PDF = $(PACKAGE).pdf acmguide.pdf

all:  ${PDF} ALLSAMPLES


%.pdf:  %.dtx   $(PACKAGE).cls
	pdflatex $<
	- bibtex $*
	pdflatex $<
	- makeindex -s gind.ist -o $*.ind $*.idx
	- makeindex -s gglo.ist -o $*.gls $*.glo
	pdflatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do pdflatex $<; done


acmguide.pdf: $(PACKAGE).dtx $(PACKAGE).cls
	pdflatex -jobname acmguide $(PACKAGE).dtx
	- bibtex acmguide
	pdflatex -jobname acmguide $(PACKAGE).dtx
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' acmguide.log) \
	do pdflatex -jobname acmguide $(PACKAGE).dtx; done

%.cls:   %.ins %.dtx
	pdflatex $<

acmart-tagging.sty: acmart.ins acmart.dtx
	pdflatex $<

ALLSAMPLES: samples/timestamp;

samples/%:
	cd samples; ${MAKE} $(notdir $@); cd ..


.PRECIOUS:  $(PACKAGE).cfg $(PACKAGE).cls 

docclean:
	$(RM)  *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls *.cut *.hd \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi \
	samples/$(PACKAGE).cls samples/ACM-Reference-Format.bst \
	samples/*.log samples/*.aux samples/*.out \
	samples/*.bbl samples/*.blg samples/*.cut \
	samples/acmart-tagging.sty samples/timestamp



clean: docclean
	$(RM)  $(PACKAGE).cls acmart-tagging.sty \
	samples/*.tex

distclean: clean
	$(RM)  *.pdf samples/sample-*.pdf

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	COPYFILE_DISABLE=1 tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' --exclude '*.tgz' --exclude '*.zip'  --exclude CVS --exclude '.git*' $(PACKAGE); mv ../$(PACKAGE).tgz .

zip:  all clean
	zip -r  $(PACKAGE).zip * -x '*~' -x '*.tgz' -x '*.zip' -x CVS -x 'CVS/*'

documents.zip: all docclean
	zip -r $@ acmart.pdf acmguide.pdf samples *.cls ACM-Reference-Format.* *.sty

.PHONY: all ALLSAMPLES docclean clean distclean archive zip
