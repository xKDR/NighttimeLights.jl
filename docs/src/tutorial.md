# Tutorial

The following example demonstrates how to use nighttime lights data for research. First the dataset is cleaned and then aggregate of polygons are produced. The following tutorial shows the cleaning procedure for nighttime lights of a box around Mumbai and then the time series of aggregate radiance for each district of Mumbai is generated. The radiance and cloud-free observations datacubes for Mumbai and the district level shapefiles for Mumbai can be downloaded from [assets provided with the package](https://github.com/JuliaPlanet/NighttimeLights.jl/tree/main/assets)

# Cleaning Data

##### Load datasets
```@docs
load_example()
```
```
i) Distict level shapefile of Mumbai is loaded as mumbai_map. 
ii) Radiance datacube of Mumbai is loaded as radiance_datacube. 
iii) Cloud-free observations data is loaded as clouds_datacube. 
iv) MUMBAI_COORDINATE_SYSTEM should be used as the coordinate system. 
```
##### Convention cleaning can be performed using the ```conventonal_cleaning``` function. 
```julia
cleaned_datacube = conventonal_cleaning(radiance_datacube, clouds_datacube) 
```

##### Or new cleaning described in PatnaikSTT2021 can be performed using the ```PatnaikSTT2021``` function. 
```julia
cleaned_datacube = PatnaikSTT2021(radiance_datacube, clouds_datacube) 
```
# Generating Aggregates

##### 1. Make a coordinate system of Mumbai. 
The top left pixel of the box around Mumbai, which we have used so far, have coordinates (19.49907,72.721252). The bottom right pixel's coordinates are (18.849475, 73.074187). There are 156 rows and 85 columns in the datacube. The number of months of data doesn't matter in calculating the coordinate system.  

```julia
MUMBAI_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(19.49907,72.721252), (18.849475, 73.074187), 156, 85)
```
This coordinate system is predefined, you can just use the global variable ```MUMBAI_COORDINATE_SYSTEM```. 
##### 2. Load the shape file for the districts of Mumbai. 
[The district level shapefile of Mumbai](https://github.com/JuliaPlanet/NighttimeLights.jl/tree/main/assets/mumbai_map) 
These have been downloaded from datameet. 
```julia
mumbai_map = load_shapefile("assets/mumbai_map/mumbai_districts.shp")
```
The shapefile has a column called DISTRICT. For each district, the name of the district is shown in this column. Will be used this column as column names of the dataset that we'll generate in the next step. We could have also used census code or any other column with unique names. 

##### 3. Generate the time series of aggregate radiance for each district of Mumbai. 
```julia
mumbai_district_ntl = aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, "DISTRICT")
``` 
