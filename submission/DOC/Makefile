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
SRC := paper.md paper.bib datacube.png raw_vs_cleaned.png

all: preview

preview: paper.pdf

paper.pdf: $(SRC)
	pandoc -s --citeproc --pdf-engine=xelatex paper.md -o paper.pdf

# --userns=keep-id maps host UID into the container so it owns the bind mount;
# :Z relabels the mount for SELinux (Fedora) so the container can write to it.
joss: $(SRC)
	$(ENGINE) run --rm \
	    --volume "$(CURDIR)":/data:Z \
	    --userns=keep-id \
	    --env JOURNAL=joss \
	    openjournals/inara

clean:
	rm -rf paper.{aux,log,out,bbl,blg,tex} Makefile~ paper.jats paper.crossref jats media

squeaky: clean
	rm -f paper.pdf

.PHONY: all preview joss clean squeaky
