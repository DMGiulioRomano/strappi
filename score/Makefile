all: pdf pdfUnite clean

pdf:
	@for file in *.tex; do \
		xelatex $$file; \
	done

pdfUnite:
	pdfunite 1-titolo.pdf 2-dedica.pdf 4-partitura.pdf generale.pdf 5-legenda.pdf comportamenti.pdf  De-Mattia-Jolt.pdf
	rm -f 1-titolo.pdf 2-dedica.pdf 5-legenda.pdf 6-gestiComplessi.pdf 3-partitura-circolare.pdf 4-partitura.pdf comportamenti.pdf generale.pdf 0-comportamento1.pdf

# Pulizia dei file di output
clean:
	rm -f *.aux *.log *.out *.synctex.gz
cleanPdf:
	rm -f *.pdf