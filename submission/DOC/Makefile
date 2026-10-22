SHELL := /bin/bash

# Two ways to build paper.pdf:
#
#   make          -> quick local preview (pandoc + xelatex). NOT the real JOSS
#                    layout, but fast and needs no container. Good enough for
#                    checking prose, citations, figures.
#
#   make joss     -> exact JOSS PDF via the official openjournals/inara
#                    container (same thing their bot runs). Requires podman
#                    (or set ENGINE=docker). This is what to trust before
#                    submitting.

ENGINE ?= podman
# Rootless podman remaps container UIDs by default, so a plain bind mount
# looks owned by the wrong user inside the container; --userns=keep-id fixes
# that. Docker doesn't have (or need) this problem, so skip the flag there.
ENGINE_USERNS := $(if $(filter podman,$(ENGINE)),--userns=keep-id)
SRC := paper.md paper.bib datacube.png raw_vs_cleaned.png

all: preview

preview: paper.pdf

paper.pdf: $(SRC)
	pandoc -s --citeproc --pdf-engine=xelatex paper.md -o paper.pdf

joss: $(SRC)
	$(ENGINE) run --rm \
	    $(ENGINE_USERNS) \
	    --volume "$(CURDIR)":/data:Z \
	    --env JOURNAL=joss \
	    openjournals/inara

clean:
	rm -f paper.{aux,log,out,bbl,blg,tex} Makefile~ paper.jats paper.crossref

squeaky: clean
	rm -f paper.pdf

.PHONY: all preview joss clean squeaky
