var documenterSearchIndex = {"docs":
[{"location":"concepts/#Basics-of-nighttime-lights-data","page":"Basic concepts","title":"Basics of nighttime lights data","text":"","category":"section"},{"location":"concepts/#Data-structure","page":"Basic concepts","title":"Data structure","text":"","category":"section"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"NOAA provides tif files of the nightlights images. These are represented as 2D arrays with floating-point values. Tif files can be read using the Rasters.jl package. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"Images of different months are stacked together to form 3D arrays. Such 3D arrays are called datacubes.","category":"page"},{"location":"concepts/#Data-IO","page":"Basic concepts","title":"Data IO","text":"","category":"section"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"While the Rasters.jl has a comprehensive documentation. This page shows some concepts needed to be known to study nighttime lights. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"The package can be used to load 2D matrices, saved as .tif files, and 3D matrices. saved as .nc files using the Raster functions. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example: ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"using Rasters\nimage = Raster(\"file.tif\")\ndatacube = Raster(\"file.nc\")","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"NOAA provides images of different months in separate .tif files. It is often required to combined these into a single datacube.  A list of .tif files can be joined together to make a datacube using Rasters.combine.  ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example: ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"using Rasters\nfilelist = readdir(\"path\")\nradiances = [Raster(i, lazy = true) for i in filelist]\ntimestamps = DateTime.(collect(range(start = Date(\"2012-04\"), step = Month(1), length = length(radiances)))) \nseries = RasterSeries(radiances, Ti(timestamps))\ndatacube = Rasters.combine(series, Ti)","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"write function from Rasters can be used to write images into .tif files and datacubes into .nc files. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example: ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"write(\"datacube.nc\", datacube)\nwrite(\"image.tif\", image)","category":"page"},{"location":"concepts/#Indexing","page":"Basic concepts","title":"Indexing","text":"","category":"section"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"The dimension regarding bands can be hidden using view as nighttime lights are single band images and then images can be indexed like 2D arrays and datacubes can be indexed like 3D arrays. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example:","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"radiance_image[1, 2] # value of the image at location [1, 2]. 1st row and 2nd column \nradiance_datacube[:, :, 3] # Image of the 3rd month.\nradiance_datacube[1, 2, :] # Time series values of the pixel at location 1, 2\nradiance_datacube[1, 2, 3] # Value of the image at location [1, 2] of the 3rd month","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"Longitude and latitude can also be used for indexing.  For example:","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"radiance_image[X(Near(77.1025)), Y(Near(28.7041))] # value of image near longitude = 77.1025 and latitude = 28.7041\nradiance_datacube[X(Near(77.1025)), Y(Near(28.7041))] # timeseries of near longitude = 77.1025 and latitude = 28.7041\nradiance_datacube[X(Near(72.8284)), Y(Near(19.05)), Ti(At(Date(\"2012-04\")))] # value of image near longitude = 77.1025 and latitude = 28.7041 at Time = Date(\"2012-04\") ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"In some cases, one may need to convert row and column numbers to latitude and longitude. One can use map. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example:","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"row = 10 \ncolumn = 10 \nlongitude, latitude = map(getindex, dims(radiance_image), [column, row]) ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"In some cases, one may need to convert (longtitude, latitude) to row and column numbers. One can use dims2indices function from DimensionalData.jl. ","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"For example:","category":"page"},{"location":"concepts/","page":"Basic concepts","title":"Basic concepts","text":"using Rasters\nusing DimensionalData\nDimensionalData.dims2indices(dims(radiance_image)[1], X(Near(72.7625))) # column number corresponding to longitude\nDimensionalData.dims2indices(dims(radiance_image)[2], Y(Near(19.4583))) # row number corresponding to latitude","category":"page"},{"location":"data_cleaning/","page":"Data Cleaning","title":"Data Cleaning","text":"For accurate economic inference using nighttime lights data, it's essential to perform thorough data cleaning. The rationale behind this process is elaborated in the work \"But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds\" by Patnaik, Ayush et al. (2021)","category":"page"},{"location":"data_cleaning/","page":"Data Cleaning","title":"Data Cleaning","text":"Additionally, a comprehensive description of the API can be found in the paper \"Foundations for nighttime lights data analysis\" by Patnaik, Ayush, Ajay Shah, and Susan Thomas (2022)","category":"page"},{"location":"data_cleaning/","page":"Data Cleaning","title":"Data Cleaning","text":"na_recode(radiance, ncfobs; replacement)\nna_interp_linear(timeseries)\noutlier_variance(datacube, mask)\noutlier_hampel(timeseries, window_size = 5, n_sigmas = 3)\nbgnoise_PSTT2021(radiance_datacube, ncfobs_datacube, th = 0.4)\nbias_PSTT2021(radiance, ncfobs, smoothing_parameter=10.0) \nbias_PSTT2021(radiance_datacube, ncfobs_datacube, mask)\nPSTT2021_conventional(radiance_datacube, ncfobs_datacube)\nPSTT2021(radiance_datacube, ncfobs_datacube)\nclean_complete(radiance_datacube, ncfobs_datacube)","category":"page"},{"location":"data_cleaning/#NighttimeLights.na_recode-Tuple{Any, Any}","page":"Data Cleaning","title":"NighttimeLights.na_recode","text":"The na_recode function also works on datacubes.  \n\nna_recode(radiance_datacube, ncfobs_datacube)\n\nWherever the number of cloud-free observations is 0, radiance will be marked as missing. \n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.na_interp_linear-Tuple{Any}","page":"Data Cleaning","title":"NighttimeLights.na_interp_linear","text":"Uses linear interpolation to fill for missing values. This function work for any kind of array, and not just nighttime lights radiance time series data. \n\nx = rand(1:10.0, 10)\nx = Vector{Union{Missing, Float64}}(x)\nx[5] = missing\nna_interp_linear(x)\n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.outlier_variance-Tuple{Any, Any}","page":"Data Cleaning","title":"NighttimeLights.outlier_variance","text":"There are extremely high values in the nighttime lights data due to fires, gas flare etc. You may find some values even greater than the aggregate radiance of large cities. Such pixels also have high standard deviation. These pixels may not be of importantance from the point of view of measureming prosperity. The outlier_variance function generates a mask of pixels with standard deviation less that a user defined cutoff value, that defaults to the 99.9th percentile. Essentially, this function can be used to remove the pixels with the high standard deviation. A mask can be provided to the function, so that it calculates the percentile based on the lit pixel of the mask. For example, if the radiance_datacube is a box around Mumbai and the mask is the polygon mask of Mumbai, the outlier_variance function will calculate the 99th percentile (default cutoff value) of the standard deviation of the pixels inside Mumbai's boundary. \n\noutlier_variance(radiance_datacube, mask; cutoff = 0.999)\n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.outlier_hampel","page":"Data Cleaning","title":"NighttimeLights.outlier_hampel","text":"The time series of a pixel may show a few outliers, but as a whole the pixel may be of importantance in measuring economic activity. The outlier_hampel function uses replaces the outlier observations with interpolated values. This is done using the tsclean function the forecast package of R.\n\noutlier_hampel(radiance_pixel_ts)\n\n\n\n\n\n","category":"function"},{"location":"data_cleaning/#NighttimeLights.bgnoise_PSTT2021","page":"Data Cleaning","title":"NighttimeLights.bgnoise_PSTT2021","text":"Pixels with no economic activity may show some light due to background noise. These pixels could be in forests, oceans, deserts etc. The bgnoise_PSTT2021 function generates a background moise mask such that those pixels which are considered dark are marked as 0 and those considered lit are marked as 1. The function uses the datacubes of radiance and ncfobs to generate annual image of the last year the data. The function considers all the pixels below a provided threshold as dark and remaining to be lit. \n\nbgnoise_PSTT2021(radiance_datacube, ncfobs_datacube)\n\n\n\n\n\n","category":"function"},{"location":"data_cleaning/#NighttimeLights.bias_PSTT2021","page":"Data Cleaning","title":"NighttimeLights.bias_PSTT2021","text":"The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. \n\nbias_PSTT2021(radiance_datacube, ncfobs_datacube)\n\n\n\n\n\n","category":"function"},{"location":"data_cleaning/#NighttimeLights.bias_PSTT2021-Tuple{Any, Any, Any}","page":"Data Cleaning","title":"NighttimeLights.bias_PSTT2021","text":"The bias correction function can use the datacubes of radiance and the number of cloud-free observations to correct for attenuation in radiance due to low number of cloud-free observations. \n\nbias_PSTT2021(radiance_datacube, ncfobs_datacube)\n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.PSTT2021_conventional-Tuple{Any, Any}","page":"Data Cleaning","title":"NighttimeLights.PSTT2021_conventional","text":"All steps of data cleaning that most researchers do can be performed using the conventional cleaning funciton.\n\nPSTT2021_conventional(radiance_datacube, ncfobs_datacube)\n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.PSTT2021-Tuple{Any, Any}","page":"Data Cleaning","title":"NighttimeLights.PSTT2021","text":"The PSTT2021 function performs all the steps of the new cleaning procedure described in But clouds got in my way: Bias and bias correction of VIIRS nighttime lights data in the presence of clouds, Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas as conventional cleaning.\n\nPSTT2021(radiance_datacube, ncfobs_datacube)\n\n\n\n\n\n","category":"method"},{"location":"data_cleaning/#NighttimeLights.clean_complete-Tuple{Any, Any}","page":"Data Cleaning","title":"NighttimeLights.clean_complete","text":"The function clean_complete() represents our views on an optimal set of steps for pre- processing in the future (for the period for which this package is actively maintained). As of today, it is identical to PSTT2021()`\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = NighttimeLights","category":"page"},{"location":"#NighttimeLights.jl","page":"Home","title":"NighttimeLights.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"GitHub repository.","category":"page"},{"location":"","page":"Home","title":"Home","text":"National Oceanic and Atmospheric Administration (NOAA) releases nighttime lights images produced using the Visible Infrared Imaging Radiometer Suite (VIIRS) since April 2012. Nighttime lights data had emerged as a useful tool to measure economic activity. Many researchers have established a correlation between prosperity and the brightness of a region. In many situations, nighttime lights generates measures with accuracy, latency and geographical resolution that are superior to conventional methods of measurement, such as GDP.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Using nighttime lights for economic analysis require cleaning of data over regions of interest. This is the first open source implementation of these procedures for nighttime lights.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package was a foundation for a research paper, But clouds got in my way: bias and bias correction of VIIRS nighttime lights data in the presence of clouds. The paper diagnoses a source of bias in the data and responds to this problem with a bias correction scheme. Along with other mainstream methods of data cleaning, this method is also implemented in the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Foundations for nighttime lights data analysis is the research paper associated with this software package. Please cite it if you use the package.","category":"page"},{"location":"","page":"Home","title":"Home","text":"@techreport{patnaik2022foundations,\n  title={Foundations for nighttime lights data analysis},\n  author={Patnaik, Ayush and Shah, Ajay and Thomas, Susan},\n  year={2022}\n}","category":"page"},{"location":"","page":"Home","title":"Home","text":"The package is built on top of Rasters.jl, which provides cutting edge features to study raster data and perform routine tasks such as zonal statistics and plotting. ","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"pkg> add NighttimeLights","category":"page"},{"location":"#Getting-help","page":"Home","title":"Getting help","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To get inquire about the Julia package, you can also email one of the authors of the package, Ayush Patnaik. ","category":"page"},{"location":"","page":"Home","title":"Home","text":"For questions regarding nighttime lights data, you can email EOG","category":"page"},{"location":"#Objects-used-in-this-documentation","page":"Home","title":"Objects used in this documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"In the following objects are used throughout the documentation. ","category":"page"},{"location":"#.-radiance_datacube","page":"Home","title":"1. radiance_datacube","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"48×101×131 Raster{Union{Missing, Float32},3} unnamed with dimensions: \n  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points\nextent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415), Ti = (DateTime(\"2012-04-01T00:00:00\"), DateTime(\"2023-01-01T00:00:00\")))\nmissingval: missing\ncrs: EPSG:4326\nmappedcrs: EPSG:4326\nparent:\n[:, :, 1]\n          19.2667  19.2625  19.2583  …  18.8625  18.8583  18.8542  18.85\n 72.7833   3.36     1.46     1.2         0.52     0.43     0.41     0.38\n 72.7875   2.75     1.54     1.51        0.56     0.47     0.5      0.52\n 72.7917   3.2      2.19     1.71        0.53     0.46     0.5      0.5\n 72.7958   4.89     3.29     1.83        0.53     0.46     0.51     0.47\n  ⋮                                  ⋱                     ⋮       \n 72.9625  25.05    22.82    10.87        1.72     1.79     1.72     1.88\n 72.9667  32.95    32.63    20.81        1.71     1.49     1.18     1.05\n 72.9708  28.36    29.57    38.93        1.46     1.28     1.39     1.22\n 72.975   15.14    23.27    27.99        1.49     1.26     1.12     1.28\n 72.9792  16.96    22.11    24.48    …   1.67     1.33     1.12     1.24\n[and 130 more slices...]","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is a datacube of radiance around Mumbai city in India. It has been created by cropping the global monthly nighttime lights data using a shapefile of the city. It contains the images from 2012-04 to 2023-01. It can be loaded using load_example(). ","category":"page"},{"location":"#.-ncfobs_datacube","page":"Home","title":"2. ncfobs_datacube","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"48×101×131 Raster{UInt16,3} unnamed with dimensions: \n  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points\nextent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415), Ti = (DateTime(\"2012-04-01T00:00:00\"), DateTime(\"2023-01-01T00:00:00\")))\ncrs: EPSG:4326\nmappedcrs: EPSG:4326\nparent:\n[:, :, 1]\n              19.2667      19.2625  …      18.8583      18.8542      18.85\n 72.7833  0x000b       0x000b          0x000a       0x000a       0x000a\n 72.7875  0x000b       0x000b          0x000b       0x000b       0x000b\n 72.7917  0x000c       0x000c          0x000a       0x000b       0x000b\n 72.7958  0x000c       0x000c          0x000a       0x000b       0x000b\n  ⋮                                 ⋱                    ⋮       \n 72.9625  0x000c       0x000c          0x000a       0x0009       0x0009\n 72.9667  0x000c       0x000c          0x000a       0x0009       0x0008\n 72.9708  0x000c       0x000c          0x0009       0x000a       0x0009\n 72.975   0x000c       0x000c          0x0009       0x0009       0x000b\n 72.9792  0x000c       0x000c       …  0x0009       0x0009       0x000b\n[and 130 more slices...]","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is a datacube of the number of cloud-free observations around Mumbai city in India. It has also been created by cropping the global monthly nighttime lights data using a shapefile of the city. It has the same dimensions as radiance_datacube. It also contains the images from 2012-04 to 2023-01. It can be loaded using load_example(). ","category":"page"},{"location":"#.-radiance_image","page":"Home","title":"3. radiance_image","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"48×101 Raster{Union{Missing, Float32},2} unnamed with dimensions: \n  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG\nand reference dimensions: \n  Ti Sampled{DateTime} DateTime[DateTime(\"2012-12-01T00:00:00\")] ForwardOrdered Irregular Points\nextent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415))\nmissingval: missing\ncrs: EPSG:4326\nmappedcrs: EPSG:4326\nparent:\n          19.2667  19.2625  19.2583  …  18.8625  18.8583  18.8542  18.85\n 72.7833   1.52     0.84     0.64        0.09     0.06     0.07     0.06\n 72.7875   1.63     1.35     0.86        0.08     0.07     0.05     0.06\n 72.7917   3.3      2.28     1.26        0.09     0.08     0.07     0.11\n  ⋮                                  ⋱                     ⋮       \n 72.9708  31.7     37.09    42.36        1.23     1.06     0.97     0.93\n 72.975   21.98    28.94    38.1         1.19     0.95     0.86     0.94\n 72.9792  19.52    26.22    28.3         1.35     1.01     0.87     0.8","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the image of Mumbai's radiance in 2012-12. It can be loaded from radiance_datacube by subsetting it.  ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Rasters\nusing Dates\nradiance_image = radiance_datacube[Ti=At(Date(\"2012-12\"))]","category":"page"},{"location":"#.-ncfobs_image","page":"Home","title":"4. ncfobs_image","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"48×101 Raster{UInt16,2} unnamed with dimensions: \n  X Mapped{Float64} Float64[72.78333535560002, 72.78750202230002, …, 72.97500202380003, 72.97916869050003] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998, 19.262499554099996, …, 18.8541662175, 18.8499995508] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG\nand reference dimensions: \n  Ti Sampled{DateTime} DateTime[DateTime(\"2012-12-01T00:00:00\")] ForwardOrdered Irregular Points\nextent: Extent(X = (72.78125202225002, 72.98125202385003), Y = (18.84791621745, 19.26874955415))\ncrs: EPSG:4326\nmappedcrs: EPSG:4326\nparent:\n              19.2667      19.2625  …      18.8583      18.8542      18.85\n 72.7833  0x000d       0x000d          0x000f       0x000f       0x000e\n 72.7875  0x000d       0x000d          0x000e       0x000e       0x000e\n 72.7917  0x000d       0x000d          0x000e       0x000e       0x000e\n  ⋮                                 ⋱                    ⋮       \n 72.9708  0x000c       0x000c          0x000d       0x000e       0x000d\n 72.975   0x000c       0x000c          0x000e       0x000e       0x000d\n 72.9792  0x000c       0x000c          0x000d       0x000d       0x000e","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the image of Mumbai's number of cloud-free observations for radiance in 2012-12. It can be loaded from ncfobs_datacube by subsetting it.  ","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Rasters\nusing Dates\nncfobs_image = ncfobs_datacube[Ti=At(Date(\"2012-12\"))]","category":"page"},{"location":"#.-radiance_pixel_ts","page":"Home","title":"5. radiance_pixel_ts","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"131-element Raster{Union{Missing, Float32},1} unnamed with dimensions: \n  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points\nand reference dimensions: \n  X Mapped{Float64} Float64[72.78333535560002] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG\nextent: Extent(Ti = (DateTime(\"2012-04-01T00:00:00\"), DateTime(\"2023-01-01T00:00:00\")),)\nmissingval: missing\nparent:\n 2012-04-01T00:00:00  3.36\n 2012-05-01T00:00:00  2.34\n 2012-06-01T00:00:00  2.04\n 2012-07-01T00:00:00  0.0\n ⋮                                \n 2022-11-01T00:00:00  2.88\n 2022-12-01T00:00:00  4.05\n 2023-01-01T00:00:00  3.1","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the timeseries of radiance of pixel [1,1] extracted from radiance_datacube. It contains radiance observations between 2012-04 and 2023-01. It can be loaded using by subsetting radiance_datacube","category":"page"},{"location":"","page":"Home","title":"Home","text":"radiance_pixel_ts = radiance_datacube[1, 1, :]","category":"page"},{"location":"#.-ncfobs_pixel_ts","page":"Home","title":"6. ncfobs_pixel_ts","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"131-element Raster{UInt16,1} unnamed with dimensions: \n  Ti Sampled{DateTime} DateTime[2012-04-01T00:00:00, …, 2023-01-01T00:00:00] ForwardOrdered Irregular Points\nand reference dimensions: \n  X Mapped{Float64} Float64[72.78333535560002] ForwardOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG,\n  Y Mapped{Float64} Float64[19.266666220799998] ReverseOrdered Explicit Intervals crs: EPSG mappedcrs: EPSG\nextent: Extent(Ti = (DateTime(\"2012-04-01T00:00:00\"), DateTime(\"2023-01-01T00:00:00\")),)\nparent:\n 2012-04-01T00:00:00  0x000b\n 2012-05-01T00:00:00  0x000f\n 2012-06-01T00:00:00  0x0004\n 2012-07-01T00:00:00  0x0000\n ⋮                                \n 2022-11-01T00:00:00  0x000c\n 2022-12-01T00:00:00  0x0012\n 2023-01-01T00:00:00  0x000f","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the timeseries of number of cloud-free observations of the pixel [1,1] extracted from ncfobs_datacube. It contains radiance observations between 2012-04 and 2023-01. It can be loaded using by subsetting ncfobs_datacube","category":"page"},{"location":"","page":"Home","title":"Home","text":"ncfobs_pixel_ts = ncfobs_datacube[1, 1, :]","category":"page"},{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This tutorial shows how to: ","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Download monthly nighttime light data\nLoad the data cubes of radiance and the number of cloud-free observations. \nClean the data\nGenerate zonal statistics","category":"page"},{"location":"tutorial/#.-Downloading-the-data","page":"Tutorial","title":"1. Downloading the data","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Create a folder called radiance and a folder called cfobs. We will use these folders to the radiance and the cloud-free observations images respectively. \nGo to the VIIRS Nighttime Lights download page at Earth Observation Group\nClick on 2017, the on 201704. This means April 2017. \nClick on vcmcfg (we will use this version of the dataset)\nClick on SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.tgz. Note that the filename has 75N060E in it. This means TILE3, where Mumbai is. \nExtract the tar files. Put SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.avg_rade9h.tif in the radiance folder. Put SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.cf_cvg.tif in the cfobs folder. \nRepeat the process for all the months. If you are interested only in a certain set of months. Download only those. ","category":"page"},{"location":"tutorial/#.-Loading-the-data","page":"Tutorial","title":"2. Loading the data","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Create data cubes for radiance and cloud-free observations.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using NighttimeLights\nusing Rasters\nusing Dates","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"dates = collect(Date(2012,4):Month(1):Date(2022, 06))\ntimestamps = NighttimeLights.yearmon.(dates)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"filelist = readdir(\"~/Downloads/radiance\")\nradiances = [Raster(i, lazy = true) for i in filelist]\ntimestamps = collect(1:length(radiances))\nseries = RasterSeries(radiances, Ti(timestamps))\nradiance_datacube = Rasters.combine(series, Ti)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"filelist = readdir(\"~/Downloads/cfobs\")\nradiances = [Raster(i, lazy = true) for i in filelist]\ntimestamps = collect(1:length(radiances))\nseries = RasterSeries(radiances, Ti(timestamps))\nncfobs_datacube = Rasters.combine(series, Ti)","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"If you haven't downloaded the data, and you want to run the remaining code, you can use load_example() to load the datacubes of radiance and the number of cloud-free observations around Mumbai ","category":"page"},{"location":"tutorial/#.-Cleaning-Data","page":"Tutorial","title":"3. Cleaning Data","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"A single function, clean_complete, can be used on radiance_datacube and ncfobs_datacube to generate a cleaned datacube of radiance. ","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"cleaned_datacube = clean_complete(radiance_datacube, ncfobs_datacube) ","category":"page"}]
}
