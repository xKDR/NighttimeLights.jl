# NighttimeLights

[![stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://xKDR.github.io/NighttimeLights.jl/stable)
[![dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://xKDR.github.io/NighttimeLights.jl/dev)
![Build Status](https://github.com/xKDR/NighttimeLights.jl/actions/workflows/ci.yml/badge.svg)
![Build Status](https://github.com/xKDR/NighttimeLights.jl/actions/workflows/documentation.yml/badge.svg)
[![codecov](https://codecov.io/gh/xKDR/NighttimeLights.jl/branch/main/graph/badge.svg?token=929G1I53PW)](https://codecov.io/gh/xKDR/NighttimeLights.jl)

National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) since April 2012. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.

Using nighttime lights for economic analysis require cleaning of data and aggregating measurements of pixels over regions of interest. This package provides functions to clean nighttime lights data and well as some other niche functions used by reseachers in this field.

This package was a foundation for a research paper, *["But clouds got in my way: bias and bias correction of VIIRS nighttime lights data in the presence of clouds"](https://xkdr.org/wp2021-07.html)*. This paper diagnoses a source of bias in the data and responds to this problem with a bias correction scheme. Along with other mainstream methods of data cleaning, this method is also implemented in the package. A detailed description of the functions of the package used for data cleaning is in the paper *["Foundations for nighttime lights data analysis"](https://papers.xkdr.org/papers/2022Patnaiketal_foundationsforNighttimelightsDataanalysis.pdf)*. 

This package is build on top of [Rasters.jl](https://github.com/rafaqz/Rasters.jl/). Nighttime lights tif/nc files can be read using `Rasters.Raster()`.  

## To install: 
```Julia
 add NighttimeLights
```

## Citing NighttimeLights.jl

To cite NighttimeLights.jl, please cite the package's corresponding [paper](https://papers.xkdr.org/papers/2022Patnaiketal_foundationsforNighttimelightsDataanalysis.pdf). The bib entry is given below:

```bibtex
@techreport{patnaik2022foundations,
  title={Foundations for nighttime lights data analysis},
  author={Patnaik, Ayush and Shah, Ajay and Thomas, Susan},
  year={2022}
}
```

## Support

We gratefully acknowledge the JuliaLab at MIT for financial support for this project.