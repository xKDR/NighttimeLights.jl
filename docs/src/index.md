```@meta
CurrentModule = NighttimeLights
```

# NighttimeLights.jl

[GitHub repository](https://github.com/xKDR/NighttimeLights.jl).

National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) since April 2012. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.

Using nighttime lights for economic analysis require cleaning of data over regions of interest. This is the first open source implementation of these procedures for nighttime lights.

This package was a foundation for a research paper, *[But clouds got in my way: bias and bias correction of VIIRS nighttime lights data in the presence of clouds](https://xkdr.org/releases/PatnaikShahTayalThomas_2021_bias_correction_nighttime_lights.html)*. The paper diagnoses a source of bias in the data and responds to this problem with a bias correction scheme. Along with other mainstream methods of data cleaning, this method is also implemented in the package.

*[Foundations for nighttime lights data analysis](https://xkdr.org/paper/foundations-for-nighttime-lights-data-analysis)* is the research paper associated with this software package. Please cite it if you use the package.

```bib
@techreport{patnaik2022foundations,
  title={Foundations for nighttime lights data analysis},
  author={Patnaik, Ayush and Shah, Ajay and Thomas, Susan},
  year={2022}
}
```

The package is built on top of [Rasters.jl](https://github.com/rafaqz/Rasters.jl/), which provides cutting edge features to study raster data and perform routine tasks such as zonal statistics and plotting. 

# Installation

```
pkg> add NighttimeLights
```

# Getting help 

To get inquire about the Julia package, you can also email one of the authors of the package, [Ayush Patnaik](mailto:ayushpatnaik@gmail.com). 

For questions regarding nighttime lights data, you can email [EOG](mailto:eog@mines.edu)

# Objects used in this documentation

In the following objects are used throughout the documentation. 

#### 1. `radiance_datacube`

```julia
48×101×131 Raster{Union{Missing, Float32},3} unnamed with dimensions: 
  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points
extent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415), Ti = (DateTime("2012-04-01T00:00:00"), DateTime("2023-01-01T00:00:00")))
missingval: missing
crs: EPSG:4326
mappedcrs: EPSG:4326
parent:
[:, :, 1]
          19.2667  19.2625  19.2583  …  18.8625  18.8583  18.8542  18.85
 72.7833   3.36     1.46     1.2         0.52     0.43     0.41     0.38
 72.7875   2.75     1.54     1.51        0.56     0.47     0.5      0.52
 72.7917   3.2      2.19     1.71        0.53     0.46     0.5      0.5
 72.7958   4.89     3.29     1.83        0.53     0.46     0.51     0.47
  ⋮                                  ⋱                     ⋮       
 72.9625  25.05    22.82    10.87        1.72     1.79     1.72     1.88
 72.9667  32.95    32.63    20.81        1.71     1.49     1.18     1.05
 72.9708  28.36    29.57    38.93        1.46     1.28     1.39     1.22
 72.975   15.14    23.27    27.99        1.49     1.26     1.12     1.28
 72.9792  16.96    22.11    24.48    …   1.67     1.33     1.12     1.24
[and 130 more slices...]
```

This is a datacube of radiance around Mumbai city in India. It has been created by cropping the global monthly nighttime lights data using a shapefile of the city. It contains the images from 2012-04 to 2023-01. It can be loaded using `load_example()`. 

#### 2. `ncfobs_datacube`

```julia
48×101×131 Raster{UInt16,3} unnamed with dimensions: 
  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points
extent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415), Ti = (DateTime("2012-04-01T00:00:00"), DateTime("2023-01-01T00:00:00")))
crs: EPSG:4326
mappedcrs: EPSG:4326
parent:
[:, :, 1]
              19.2667      19.2625  …      18.8583      18.8542      18.85
 72.7833  0x000b       0x000b          0x000a       0x000a       0x000a
 72.7875  0x000b       0x000b          0x000b       0x000b       0x000b
 72.7917  0x000c       0x000c          0x000a       0x000b       0x000b
 72.7958  0x000c       0x000c          0x000a       0x000b       0x000b
  ⋮                                 ⋱                    ⋮       
 72.9625  0x000c       0x000c          0x000a       0x0009       0x0009
 72.9667  0x000c       0x000c          0x000a       0x0009       0x0008
 72.9708  0x000c       0x000c          0x0009       0x000a       0x0009
 72.975   0x000c       0x000c          0x0009       0x0009       0x000b
 72.9792  0x000c       0x000c       …  0x0009       0x0009       0x000b
[and 130 more slices...]
```

This is a datacube of the number of cloud-free observations around Mumbai city in India. It has also been created by cropping the global monthly nighttime lights data using a shapefile of the city. It has the same dimensions as `radiance_datacube`. It also contains the images from 2012-04 to 2023-01. It can be loaded using `load_example()`. 

#### 3. `radiance_image`

```julia
48×101 Raster{Union{Missing, Float32},2} unnamed with dimensions: 
  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG
and reference dimensions: 
  Ti Sampled{DateTime} DateTime[DateTime("2012-12-01T00:00:00")] ForwardOrdered Irregular Points
extent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415))
missingval: missing
crs: EPSG:4326
mappedcrs: EPSG:4326
parent:
          19.2667  19.2625  19.2583  …  18.8625  18.8583  18.8542  18.85
 72.7833   1.52     0.84     0.64        0.09     0.06     0.07     0.06
 72.7875   1.63     1.35     0.86        0.08     0.07     0.05     0.06
 72.7917   3.3      2.28     1.26        0.09     0.08     0.07     0.11
  ⋮                                  ⋱                     ⋮       
 72.9708  31.7     37.09    42.36        1.23     1.06     0.97     0.93
 72.975   21.98    28.94    38.1         1.19     0.95     0.86     0.94
 72.9792  19.52    26.22    28.3         1.35     1.01     0.87     0.8
```

This is the image of Mumbai's radiance in 2012-12. It can be loaded from `radiance_datacube` by subsetting it.  

```julia
using Rasters
using Dates
radiance_image = radiance_datacube[Ti=At(Date("2012-12"))]
```

#### 4. `ncfobs_image`

```julia
48×101 Raster{UInt16,2} unnamed with dimensions: 
  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG
and reference dimensions: 
  Ti Sampled{DateTime} DateTime[DateTime("2012-12-01T00:00:00")] ForwardOrdered Irregular Points
extent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415))
crs: EPSG:4326
mappedcrs: EPSG:4326
parent:
              19.2667      19.2625  …      18.8583      18.8542      18.85
 72.7833  0x000d       0x000d          0x000f       0x000f       0x000e
 72.7875  0x000d       0x000d          0x000e       0x000e       0x000e
 72.7917  0x000d       0x000d          0x000e       0x000e       0x000e
  ⋮                                 ⋱                    ⋮       
 72.9708  0x000c       0x000c          0x000d       0x000e       0x000d
 72.975   0x000c       0x000c          0x000e       0x000e       0x000d
 72.9792  0x000c       0x000c          0x000d       0x000d       0x000e
```

This is the image of Mumbai's number of cloud-free observations for radiance in 2012-12. It can be loaded from `ncfobs_datacube` by subsetting it.  

```julia
using Rasters
using Dates
ncfobs_image = ncfobs_datacube[Ti=At(Date("2012-12"))]
```

#### 5. `radiance_pixel_ts`
```julia
131-element Raster{Union{Missing, Float32},1} unnamed with dimensions: 
  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points
and reference dimensions: 
  X Mapped{Float64} Float64[72.78333535560002] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG
extent: Extent(Ti = (DateTime("2012-04-01T00:00:00"), DateTime("2023-01-01T00:00:00")),)
missingval: missing
parent:
 2012-04-01T00:00:00  3.36
 2012-05-01T00:00:00  2.34
 2012-06-01T00:00:00  2.04
 2012-07-01T00:00:00  0.0
 ⋮                                
 2022-11-01T00:00:00  2.88
 2022-12-01T00:00:00  4.05
 2023-01-01T00:00:00  3.1
```

This is the timeseries of radiance of pixel `[1,1]` extracted from `radiance_datacube`. It contains radiance observations between 2012-04 and 2023-01. It can be loaded using by subsetting `radiance_datacube`

```julia
radiance_pixel_ts = radiance_datacube[1, 1, :]
```

#### 6. `ncfobs_pixel_ts`
```julia
131-element Raster{UInt16,1} unnamed with dimensions: 
  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points
and reference dimensions: 
  X Mapped{Float64} Float64[72.78333535560002] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,
  Y Mapped{Float64} Float64[19.266666220799998] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG
extent: Extent(Ti = (DateTime("2012-04-01T00:00:00"), DateTime("2023-01-01T00:00:00")),)
parent:
 2012-04-01T00:00:00  0x000b
 2012-05-01T00:00:00  0x000f
 2012-06-01T00:00:00  0x0004
 2012-07-01T00:00:00  0x0000
 ⋮                                
 2022-11-01T00:00:00  0x000c
 2022-12-01T00:00:00  0x0012
 2023-01-01T00:00:00  0x000f
```
This is the timeseries of number of cloud-free observations of the pixel `[1,1]` extracted from `ncfobs_datacube`. It contains radiance observations between 2012-04 and 2023-01. It can be loaded using by subsetting `ncfobs_datacube`

```julia
ncfobs_pixel_ts = ncfobs_datacube[1, 1, :]
```
