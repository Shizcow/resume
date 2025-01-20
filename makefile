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

# Convenience script to push to website... really only works on my machine
deploy: build
	cp $(JOB).pdf ../shizcow.github.io/static/uploads/resume.pdf
	cp $(JOB).pdf ../shizcow.github.io/docs/uploads/resume.pdf
	cd ../shizcow.github.io && git add static/uploads/resume.pdf docs/uploads/resume.pdf && git commit -m "Re-compile resume" && git push
