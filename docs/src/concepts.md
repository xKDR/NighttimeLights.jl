
# Basics of nighttime lights data

## Data IO

NOAA provides tif files of the nightlights images. Images in the package are represented as 2D arrays with floating-point values. Images of different months are stacked together to form 3D arrays. Such 3D arrays are called datacubes. 

Raster data in Julia can be loaded using the [Rasters.jl](https://github.com/rafaqz/Rasters.jl/) package. While the package has a comprehensive [documentation](https://rafaqz.github.io/Rasters.jl/dev/). This page highlights the small set of tools required to study nighttime lights. It is recommended to study the full documentation of `Rasters.jl`. 

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
timestamps = collect(1:length(radiances))
series = RasterSeries(radiances, Ti(timestamps))
datacube = Rasters.combine(series, Ti)
datacube = datacube[:,:,1,:] # needed to drop dimension regarding bands, since nighttime lights data is single band. 
```

`write` function from Rasters can be used to write images into `.tif` files and datacubes into `.nc` files. 

For example: 
```julia
write("datacube.nc", datacube)
write("image.tif", image)
```

## Indexing
Images can be indexed like 2D arrays and datacubes can be indexed like 3D arrays. 

For example:

```julia
image[1, 2] # value of the image at location [1, 2]. 1st row and 2nd column 
datacube[:, :, 3] # Image of the 3rd month.
datacube[1, 2, :] # Time series values of the pixel at location 1, 2
datacube[1, 2, 3] # Value of the image at location [1, 2] of the 3rd month
```

Longitude and latitude can also be used for indexing. 
For example:
```julia
image[X(Near(77.1025)), Y(Near(28.7041))] # value of image near longitude = 77.1025 and latitude = 28.7041
datacube[X(Near(77.1025)), Y(Near(28.7041))] # timeseries of near longitude = 77.1025 and latitude = 28.7041
datacube[X(Near(72.8284)), Y(Near(19.05)), Ti(At(201204))] # value of image near longitude = 77.1025 and latitude = 28.7041 at Time = 201204 
```

It is often required to convert row and column numbers to latitude and longitude. One can use `map`. 

For example:

```julia
row = 10 
column = 10 
longitude, latitude = map(getindex, dims(raster), [column, row]) 
```
It is often required to convert (longtitude, latitude) to row and column numbers. One can use `dims2indices` function from `DimensionalData.jl`. 

For example:
```julia
using Rasters
using DimensionalData
DimensionalData.dims2indices(dims(raster)[1], X(Near(72.7625))) # column number corresponding to longitude
DimensionalData.dims2indices(dims(raster)[2], Y(Near(19.4583))) # row number corresponding to latitude
```

## Cropping
Due the large size of raster files, cropping is often required. Cropping of raster files can be done creating bounds.

```julia
bounds = X(Rasters.Between(72.721252, 73.074187)), Y(Rasters.Between(18.849475, 19.49907))
raster[bounds...]
```
This works for both images and datacubes. 

They can also be done 



Raster image can also be cropped using polygons from [Shapefiles](@ref). 