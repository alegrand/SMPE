ORG_SOURCES=1_reproducible_research.org  2_data_presentation.org  3_introduction_to_statistics.org  4_linear_model.org  5_design_of_experiments.org 2bis_descriptive_statistics.org

PDF_SLIDES=$(subst .org,.pdf,$(ORG_SOURCES))
TEX_SLIDES=$(subst .org,.tex,$(ORG_SOURCES))

all: $(TEX_SLIDES)  $(PDF_SLIDES)

crop:
	for i in pdf_babel/*.pdf ; do pdfcrop $$i $$i ; done

smartcrop:
	for i in `git status | grep babel | sed 's/.*pdf_babel/pdf_babel/'`; do pdfcrop $$i $$i ; done

PDFLATEX=pdflatex -shell-escape

include LaTeX.mk

%.tex: %.org
	emacs -batch --eval "(setq enable-local-eval t)" --eval "(setq enable-local-variables t)" $^  --funcall org-beamer-export-to-latex
	mv $@ $@.bak
	echo '\\def\\raggedright{}' > $@
	echo "\PassOptionsToPackage{svgnames}{xcolor}" >> $@
	sed -e 's/\\begin{verbatim}/\\begin{pyglist}[language=r,style=tango,bgcolor=Moccasin,numbers=left,numbersep=5pt]/' -e 's/\\end{verbatim}/\\end{pyglist}/' \
	    -e "s/^Signif. codes:.*$$/Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1/g"   $@.bak >> $@
	rm $@.bak
