
```@docs
load_shapefile(filepath)
```

```
|   |       geometry      |     DISTRICT    |    ST_NM    | ST_CEN_CD | DT_CEN_CD | censuscode |
|:-:|:-------------------:|:---------------:|:-----------:|:---------:|:---------:|:----------:|
| 1 | Polygon(78 Points)  | Mumbai          | Maharashtra | 27        | 23        | 519        |
| 2 | Polygon(139 Points) | Mumbai Suburban | Maharashtra | 27        | 22        | 518        |
```

Each row of a shapefile dataframe contains a polygon and other information about it. 

```@docs
polygon_mask(geometry::CoordinateSystem, shapefile_row)
```

Once a mask is obtained from a polygon, the mask can be used as just as any other mask. 