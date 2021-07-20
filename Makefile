SHELL:= /bin/bash

documentation:
	julia docs/make.jl
	aws s3 sync docs/build/ s3://nighttimelights	