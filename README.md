# NighttimeLights

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](http://nighttimelights.s3-website.ap-south-1.amazonaws.com/)

National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) since April 2012. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.

Using nighttime lights for economic analysis require cleaning of data and aggregating measurements of pixels over regions of interest. This is the first open source implementation of these procedures for nighttime lights.

## To install: 
```Julia
 add "git://github.com/JuliaPlanet/NighttimeLights.jl.git"
```

The package requires a functioning RCall with forecast package installed. 
