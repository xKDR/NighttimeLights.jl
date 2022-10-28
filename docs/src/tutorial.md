# Tutorial

This tutorial shows how to: 
1) Download monthly nighttime light data
2) Load the data cubes of radiance and the number of cloud-free observations. 
3) Clean the data
4) Generate zonal statistics

## 1. Downloading the data 

0. Create a folder called `radiance` and a folder called `cfobs`. We will use these folders to the radiance and the cloud-free observations images respectively. 
1. Go to the VIIRS Nighttime Lights download page at [Earth Observation Group](https://eogdata.mines.edu/nighttime_light/monthly/v10/)
2. Click on ```2017```, the on ```201704```. This means April 2017. 
3. Click on `vcmcfg` (we will use this version of the dataset)
4. Click on ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.tgz```. Note that the filename has 75N060E in it. This means TILE3, where Mumbai is. 
5. Extract the tar files. Put ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.avg_rade9h.tif``` in the `radiance` folder. Put ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.cf_cvg.tif``` in the `cfobs` folder. 
6. Repeat the process for all the months. If you are interested only in a certain set of months. Download only those. 

## 2. Loading the data 

Create data cubes for radiance and cloud-free observations.
```julia
using NighttimeLights
using Rasters
using Dates
```

```julia
dates = collect(Date(2012,4):Month(1):Date(2022, 06))
timestamps = NighttimeLights.yearmon.(dates)
```

```julia
filelist = readdir("~/Downloads/radiance")
radiances = [Raster(i, lazy = true) for i in filelist]
timestamps = collect(1:length(radiances))
series = RasterSeries(radiances, Ti(timestamps))
radiance_datacube = Rasters.combine(series, Ti)
```

```julia
filelist = readdir("~/Downloads/cfobs")
radiances = [Raster(i, lazy = true) for i in filelist]
timestamps = collect(1:length(radiances))
series = RasterSeries(radiances, Ti(timestamps))
clouds_datacube = Rasters.combine(series, Ti)
```

If you haven't downloaded the data, and you want to run the remaining code, you can use `load_example()` to load the datacubes of radiance and the number of cloud-free observations around Mumbai 

## 3. Cleaning Data

A single function, `clean_complete`, can be used on `radiance_datacube` and `clouds_datacube` to generate a cleaned datacube of radiance. 
```julia
cleaned_datacube = clean_complete(radiance_datacube, clouds_datacube) 
```