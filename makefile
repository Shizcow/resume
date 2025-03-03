export TEXINPUTS=.:..//:
JOB=DevinPohlResume
LTX=lualatex

SRCFILES=main.tex *.png *.bib

default: $(JOB).pdf

.PHONY: _force_run

# Set this to 1 to enable console output, 0 to disable
DEBUG ?= 1

$(JOB).pdf: $(SRCFILES) | build
	@echo "Running LaTeX..."
	@$(MAKE) _force_run JOB=$(JOB) LTX=$(LTX) DEBUG=$(DEBUG)
	@echo "Moving final PDF..."
	@mv build/$(JOB).pdf .

_force_run:
	@$(MAKE) _run_latex JOB=$(JOB) LTX=$(LTX) DEBUG=$(DEBUG)

_run_latex:
	@if [ "$(DEBUG)" -eq 1 ]; then \
		cd build && $(LTX) -jobname=$(JOB) ../main.tex 2>&1 | tee output.log; \
	else \
		cd build && $(LTX) -jobname=$(JOB) ../main.tex > output.log 2>&1; \
	fi
	@if grep -Pq "[Pp]lease \(re\)run Biber on the file" build/output.log; then \
		echo "Running Biber..."; \
		cd build && biber $(JOB); \
		echo "Rerunning LaTeX after Biber..."; \
		$(MAKE) -C .. _force_run JOB=$(JOB) LTX=$(LTX) DEBUG=$(DEBUG); \
	elif grep -Pq "[Rr]erun to get outlines right|[Pp]lease rerun" build/output.log; then \
		echo "Rerunning LaTeX..."; \
		$(MAKE) _force_run JOB=$(JOB) LTX=$(LTX) DEBUG=$(DEBUG); \
	fi

watch:
	inotifywait -qm --event modify --format '%w' $(SRCFILES) | xargs -I{} $(MAKE)

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
