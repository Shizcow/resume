export TEXINPUTS=.:..//:
JOB=DevinPohlResume
LTX=xelatex

default: $(JOB).pdf

$(JOB).pdf: main.tex *.png | build
	cd build && $(LTX) -jobname=$(JOB) ../main.tex
	mv build/$(JOB).pdf .

build: # set up the build directory
	mkdir build

test:	default
	okular $(JOB).pdf

clean:
	-rm -rf build
