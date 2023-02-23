ORG_SOURCES:= $(wildcard lecture_*.org)
# 1_reproducible_research.org  2_data_presentation.org  3_introduction_to_statistics.org  4_linear_model.org  5_design_of_experiments.org 2bis_descriptive_statistics.org 
PDF_SLIDES=$(subst .org,.pdf,$(ORG_SOURCES))
TEX_SLIDES=$(subst .org,.tex,$(ORG_SOURCES))
FIG_FILES=$(wildcard fig/*.fig)
FIG_PDFTEX_FILES=$(subst .fig,.pdftex,$(FIG_FILES))
FIG_PDFTEXT_FILES=$(subst .fig,.pdftex_t,$(FIG_FILES))

all: figures  $(TEX_SLIDES)  $(PDF_SLIDES)

figures: $(FIG_PDFTEX_FILES) $(FIG_PDFTEXT_FILES)

crop:
	for i in pdf_babel/*.pdf ; do pdfcrop $$i $$i ; done

smartcrop:
	for i in `git status | grep babel | sed 's/.*pdf_babel/pdf_babel/'`; do pdfcrop $$i $$i ; done

PDFLATEX=pdflatex -shell-escape

include LaTeX.mk

talk_23_02_23_LISTIC.tex: talk_23_02_23_LISTIC.org
	emacs -q -batch --eval="(setq enable-local-eval t)" --eval="(setq enable-local-variables t)" $< --funcall org-beamer-export-to-latex
	sed -i -e 's/begin{verbatim}/begin{Verbatim}[fontsize=\\scriptsize,commandchars=\\\\\\{\\}]/' -e 's/end{verbatim}/end{Verbatim}/' $@


%.tex: %.org
	emacs -batch --eval "(setq enable-local-eval t)" \
                     --eval "(setq enable-local-variables t)" \
                     --eval "(setq org-confirm-babel-evaluate nil)" \
                 $^  --funcall org-beamer-export-to-latex
	mv $@ $@.bak
	echo '\\def\\raggedright{}' > $@
	echo "\PassOptionsToPackage{svgnames}{xcolor}" >> $@
	sed -e 's/\\begin{verbatim}/\\begin{pyglist}[language=r,style=tango,bgcolor=Moccasin,numbers=left,numbersep=5pt]/' -e 's/\\end{verbatim}/\\end{pyglist}/' \
	    -e "s/^Signif. codes:.*$$/Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1/g"   $@.bak >> $@
	rm $@.bak

%.pdftex: %.fig
	fig2dev -L pdftex $^ $@

%.pdftex_t: %.fig
	fig2dev -L pdftex_t $^ $@

lecture_great_scientific_experiments_notes.tex: lecture_great_scientific_experiments.tex
	sed -e 's/,presentation/,handout/' -e 's/usepackage{pgfpages}/usepackage{pgfpages}\\setbeameroption{show only notes}/' $^ >> $@
# grep includegraphics talk_17_02_08_Inria_comdir.tex | sed -e 's/.*includegraphics[^{]*{//' -e 's/}.*$//g
