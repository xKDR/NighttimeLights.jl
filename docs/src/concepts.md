
# Basics of nighttime lights data

## Data structure

NOAA provides tif files of the nightlights images. These are represented as 2D arrays with floating-point values. Tif files can be read using the [Rasters.jl](https://github.com/rafaqz/Rasters.jl/) package. 

Images of different months are stacked together to form 3D arrays. Such 3D arrays are called datacubes.

## Data IO

While the Rasters.jl has a comprehensive [documentation](https://rafaqz.github.io/Rasters.jl/dev/). This page shows some concepts needed to be known to study nighttime lights. 

The package can be used to load 2D matrices, saved as `.tif` files, and 3D matrices. saved as `.nc` files using the `Raster` functions. 

For example: 
```julia
using Rasters
image = Raster("file.tif")
datacube = Raster("file.nc")
```
NOAA provides images of different months in separate `.tif` files. It is often required to combined these into a single datacube. 
A list of `.tif` files can be joined together to make a datacube using `Rasters.combine`.  

For example: 
```julia
using Rasters
filelist = readdir("path")
radiances = [Raster(i, lazy = true) for i in filelist]
timestamps = DateTime.(collect(range(start = Date("2012-04"), step = Month(1), length = length(radiances)))) 
series = RasterSeries(radiances, Ti(timestamps))
datacube = Rasters.combine(series, Ti)
```

`write` function from Rasters can be used to write images into `.tif` files and datacubes into `.nc` files. 

For example: 
```julia
write("datacube.nc", datacube)
write("image.tif", image)
```

## Indexing
The dimension regarding bands can be hidden using `view` as nighttime lights are single band images and then images can be indexed like 2D arrays and datacubes can be indexed like 3D arrays. 

For example:

```julia
radiance_image[1, 2] # value of the image at location [1, 2]. 1st row and 2nd column 
radiance_datacube[:, :, 3] # Image of the 3rd month.
radiance_datacube[1, 2, :] # Time series values of the pixel at location 1, 2
radiance_datacube[1, 2, 3] # Value of the image at location [1, 2] of the 3rd month
```

Longitude and latitude can also be used for indexing. 
For example:
```julia
radiance_image[X(Near(77.1025)), Y(Near(28.7041))] # value of image near longitude = 77.1025 and latitude = 28.7041
radiance_datacube[X(Near(77.1025)), Y(Near(28.7041))] # timeseries of near longitude = 77.1025 and latitude = 28.7041
radiance_datacube[X(Near(72.8284)), Y(Near(19.05)), Ti(At(Date("2012-04")))] # value of image near longitude = 77.1025 and latitude = 28.7041 at Time = Date("2012-04") 
```

In some cases, one may need to convert row and column numbers to latitude and longitude. One can use `map`. 

For example:

```julia
row = 10 
column = 10 
longitude, latitude = map(getindex, dims(radiance_image), [column, row]) 
```
In some cases, one may need to convert (longtitude, latitude) to row and column numbers. One can use `dims2indices` function from `DimensionalData.jl`. 

For example:
```julia
using Rasters
using DimensionalData
DimensionalData.dims2indices(dims(radiance_image)[1], X(Near(72.7625))) # column number corresponding to longitude
DimensionalData.dims2indices(dims(radiance_image)[2], Y(Near(19.4583))) # row number corresponding to latitude
```