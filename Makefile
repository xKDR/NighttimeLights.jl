SHELL:= /bin/bash

docs:
	julia docs/make.jl
	aws s3 sync docs/build/ s3://nighttimelights	

.PHONY: docs