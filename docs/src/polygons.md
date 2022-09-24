
# Shapefiles 

```julia
using Shapefile
Shapetile.Table(filepath)
```

```julia
load_example()
mumbai_map
```
```
Shapefile.Table{Union{Missing, Shapefile.Polygon}} with 2 rows and the following 6 columns:
	
geometry, DISTRICT, ST_NM, ST_CEN_CD, DT_CEN_CD, censuscode
```
```julia
using DataFrames
DataFrame(mumbai_map)
```

|   |       geometry      |     DISTRICT    |    ST_NM    | ST_CEN_CD | DT_CEN_CD | censuscode |
|:-:|:-------------------:|:---------------:|:-----------:|:---------:|:---------:|:----------:|
| 1 | Polygon(78 Points)  | Mumbai          | Maharashtra | 27        | 23        | 519        |
| 2 | Polygon(139 Points) | Mumbai Suburban | Maharashtra | 27        | 22        | 518        |

## Cropping

Shapefile can be used to crop raster images. 

```julia
crop(raster; to=mumbai_map.geometry)
crop(raster; to=mumbai_map.geometry[1])
```

## Masking

```julia
mask(raster, with = mumbai_map.geometry)
mask(raster, with = mumbai_map.geometry[1])
```

## Zonal statistics

```julia
zonal(sum, raster; of=mumbai_map, boundary=:touches)
```