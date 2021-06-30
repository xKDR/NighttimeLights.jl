```@meta
CurrentModule = NighttimeLights
```

# NighttimeLights

Documentation for [NighttimeLights](https://github.com/ayushpatnaikgit/NighttimeLights.jl).

National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) each month since April 2012. The image of India as night in April 2012 is shown below. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. Doll found a strong correlation between the nighttime lights, aggregated over a geographical region of interest, with the regional GDP of 11 European Union countries, and US GDP at the state
level. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.

Using nighttime lights for economic analysis require cleaning of data. This is the first open source implementation of cleaning procedures for nighttime lights.

![india lights](india.png)

The package, NighttimeLights.jl, was a foundation for a research paper, "But clouds got in my way: bias and bias correction of VIIRS nighttime lights data in the presence of clouds" by Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas. This paper diagnoses a source of bias in the data and responds to this problem with a bias correction scheme. Along with other mainstream methods of data cleaning, this method is also implemented in the package.

While there are packages to do image processing in Julia, the assumptions about the sensor producing the data, such as in Images.jl, make it incompatible with nighttime lights data. We built the package from scratch without making any assumptions about the sensor. Functions in the package take regular float 3D arrays as input, which makes it possible to extend the package to data from any sensor and not just VIIRS nighttime lights. 