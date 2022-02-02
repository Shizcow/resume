export TEXINPUTS=.:..//:
JOB=DevinPohlResume
LTX=xelatex

SRCFILES=main.tex *.png

default: $(JOB).pdf

watch:
	inotifywait -qm --event modify --format '%w' $(SRCFILES) | xargs -I{} $(MAKE)

$(JOB).pdf: $(SRCFILES) | build
	cd build && $(LTX) -jobname=$(JOB) ../main.tex
	mv build/$(JOB).pdf .

build: # set up the build directory
	mkdir build

test:	default
	okular $(JOB).pdf

clean:
	-rm -rf build
