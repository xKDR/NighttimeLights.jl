```@meta
CurrentModule = NighttimeLights
```

# NighttimeLights.jl

Documentation for [NighttimeLights](https://github.com/xKDR/NighttimeLights.jl).

National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) since April 2012. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.

Using nighttime lights for economic analysis require cleaning of data and aggregating measurements of pixels over regions of interest. This is the first open source implementation of these procedures for nighttime lights.

While there are packages to do image processing in Julia, the assumptions about the sensor producing the data, such as in Images.jl, make it incompatible with nighttime lights data. We built the package from scratch without making any assumptions about the sensor. Functions in the package take regular float 3D arrays as input, which makes it possible to extend the package to data from any sensor and not just VIIRS nighttime lights. 

![india lights](eog.png)

This package was a foundation for a research paper, "[But clouds got in my way: bias and bias correction of VIIRS nighttime lights data in the presence of clouds]((https://xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_correction_nighttime_lights.html))" by Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas. The paper diagnoses a source of bias in the data and responds to this problem with a bias correction scheme. Along with other mainstream methods of data cleaning, this method is also implemented in the package.

The package is built on top of [Rasters.jl](https://github.com/rafaqz/Rasters.jl/), which provides cutting edge features to study raster data and perform routine tasks such as zonal statistics and plotting. 

# Installation

```
pkg> add NighttimeLights
```

# Getting help 

To get inquire about the Julia package, you can join the Julia community on [slack](https://julialang.org/slack/) and post questions on the nighttime-lights channel. You can also email one of the authors of the package, [Ayush Patnaik](mailto:ayushpatnaik@gmail.com). 

For questions regarding nighttime lights data, you can email [Kim Baugh](mailto:Kim.Baugh@noaa.gov)