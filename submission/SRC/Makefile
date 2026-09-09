# Analysis for the Mumbai replication example.
#
# The analysis is replication.ipynb, which runs on Google Colab with two
# kernels (Python for the Earth Engine download, Julia 1.12 for the
# cleaning). It cannot run from `make` and is not meant to. This Makefile
# exists for structural completeness.
#
# `make` copies the generated figure up to ../DOC if it is present, so the
# paper build has it. It is a no-op if the notebook has not been run.

all:
	@if [ -f raw_vs_cleaned.png ]; then \
	  cp raw_vs_cleaned.png ../DOC/raw_vs_cleaned.png; \
	  echo "SRC: copied raw_vs_cleaned.png to ../DOC."; \
	else \
	  echo "SRC: no generated figure (run replication.ipynb on Colab). See README."; \
	fi

clean:

squeaky: clean
	rm -f table1.csv table2.csv raw_vs_cleaned.png

.PHONY: all clean squeaky
