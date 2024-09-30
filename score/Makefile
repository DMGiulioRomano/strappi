all: pdf pdfUnite clean

pdf:
	@for file in *.tex; do \
		xelatex $$file; \
	done

pdfUnite:
	pdfunite titolo.pdf dedica.pdf legenda.pdf gestiComplessi.pdf partitura.pdf De-Mattia-Jolt.pdf
	rm -f titolo.pdf dedica.pdf legenda.pdf gestiComplessi.pdf partitura-circolare.pdf partitura.pdf

# Pulizia dei file di output
clean:
	rm -f *.aux *.log *.out *.synctex.gz
cleanPdf:
	rm -f *.pdf