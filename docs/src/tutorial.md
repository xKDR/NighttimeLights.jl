# Tutorial

The following example demonstrates how to use nighttime lights data for research. First the dataset is cleaned and then aggregate of polygons are produced. The following tutorial shows the cleaning procedure for monthly nighttime lights of a box around Mumbai and then the time series of aggregate radiance for each district of Mumbai is generated. The radiance and cloud-free observations datacubes for Mumbai and the district level shapefiles for Mumbai can be downloaded from [assets provided with the package](https://github.com/xKDR/NighttimeLights.jl/tree/main/assets). 

## 1. Make a coordinate system of Mumbai. 
The top left pixel of the box around Mumbai, which we have used so far, have coordinates ```(19.49907,72.721252)```. The bottom right pixel's coordinates are ```(18.849475, 73.074187)```. We will create a coordinate system from the existing ```TILE3_COORDINATE_SYSTEM```


```julia
my_coordinate_system = translate_geometry(TILE3_COORDINATE_SYSTEM, Coordinate(19.49907, 72.721252), Coordinate(18.849475, 73.074187))
```
This coordinate system also comes predefined with the package. You can use the global variable ```MUMBAI_COORDINATE_SYSTEM```. 
```julia
my_coordinate_system = MUMBAI_COORDINATE_SYSTEM
```

## 2. Downloading the data 
You can use ```load_example()``` to load the sample datacubes. However, the following steps can be used to learn the downloading process.  

0. Create a folder called "radiance" and a folder called "cfobs". We will use these folders to the radiance and the cloud-free observations images respectively. 
1. Go to the VIIRS Nighttime Lights download page at [Earth Observation Group](https://eogdata.mines.edu/nighttime_light/monthly/v10/)
2. Click on ```2017```, the on ```201704```. This means April 2017. 
3. Click on vcmcfg (we will use this version of the dataset)
4. Click on ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.tgz```. Note that the filename has 75N060E in it. This means TILE3, where Mumbai is. 
5. Extract the tar files. Put ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.avg_rade9h.tif``` in the radiance folder. Put ```SVDNB_npp_20170401-20170430_75N060E_vcmcfg_v10_c201705011300.cf_cvg.tif``` in the cfobs folder. 
6. Repeat the process for all the months. If you  are interested only in a certain set of months. Download only those. 

## 3. Loading the data 

Create data cubes for radiance and cloud-free observations. 

```julia
radiance_datacube = make_datacube("~/Downloads/radiance", TILE3_COORDINATE_SYSTEM, my_coordinate_system)

clouds_datacube = make_datacube("~/Downloads/cfobs",  TILE3_COORDINATE_SYSTEM, my_coordinate_system)
```

If you haven't downloaded the data and you want to run the code on an example, run: 
```julia
load_example()
```

## 4. Cleaning Data

Convention cleaning can be performed using the ```conventonal_cleaning``` function. 
```julia
cleaned_datacube = conventonal_cleaning(radiance_datacube, clouds_datacube) 
```

Or new cleaning described in PatnaikSTT2021 can be performed using the ```PatnaikSTT2021``` function. 
```julia
cleaned_datacube = PatnaikSTT2021(radiance_datacube, clouds_datacube) 
```
## 5. Generating Aggregates

1. Load the shape file for the districts of Mumbai. 
You can download the [district level shapefile of Mumbai](https://github.com/xKDR/NighttimeLights.jl/tree/main/assets/mumbai_map) or load it using ```load_example()```. 

```julia
mumbai_map = load_shp("~Downloads/mumbai_map.shp")
```
These have been created from the datameet shapefiles of India, based on 2011. 

The shapefile has a column called ```DISTRICT```. For each district, the name of the district is shown in this column. This column will be used as column names of the dataset that we'll generate in the next step. We could have also used census code or any other column with unique names. 

2. Generate the time series of aggregate radiance for each district of Mumbai. 
```julia
mumbai_district_ntl = aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, cleaned_datacube, mumbai_map, "DISTRICT")
``` 
