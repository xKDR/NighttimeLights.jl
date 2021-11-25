"""
The aggregate value of an image over a mask can be computed by the aggregate function. The function multiplies the image and the mask (elementwise) and then performs the summation. 
```
rand_image = rand(10, 10)
rand_mask = rand(0:1, 10, 10)
aggregate(rand_image, rand_mask)
```
"""
function aggregate(image, mask)
    masked_image = copy(image).*mask
    return sum(masked_image)
end

"""
To find the time series of aggregate values of a datacube over a mask, using the ```aggregate_timeseries``` function

```
rand_datacube = rand(10, 10, 10)
rand_mask = rand(0:1, 10, 10)
aggregate_timeseries(rand_datacube, rand_mask)
```
"""
function aggregate_timeseries(datacube, mask)
    if typeof(datacube) == Array{Float16, 3}
        @warn "Float 16 may not be sufficient to aggregate."
    end
    datacube = apply_mask(datacube, mask)
    lights = []
    for i in 1:length(datacube)
        push!(lights, sum(ts[i]))
    end
    return Float32.(lights)
end

"""
Computes the time series of aggregate value of datacube for each row of a shapefile
# Example:
```
rand_datacube = rand(10, 10, 10)
shapefile_df  = load_shapefile("assets/mumbai_map/mumbai_districts.shp")
aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, rand_datacube, shapefile_df, "District")
```
"""
function aggregate_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, attribute)
    if typeof(datacube) == Array{Float16, 3}
        @warn "Float 16 may not be sufficient to aggregate."
    end
    datacube = sparse_cube(datacube)
    df = DataFrame()
    @showprogress for i in 1:length(shapefile_df[:, 1])
        shapefile_row = shapefile_df[i, :]
        geom_polygon = polygon_mask(geometry, shapefile_row)
        df[!, shapefile_df[!, attribute][i]] = aggregate_timeseries(datacube, geom_polygon)
        i = i + 1
    end
    return df
end

"""
Computes the time series of aggregate value per area of datacube for each row of a shapefile
# Example:
```
rand_datacube = rand(10, 10, 10)
shapefile_df  = load_shapefile("assets/mumbai_map/mumbai_districts.shp")
aggregate_per_area_dataframe(MUMBAI_COORDINATE_SYSTEM, rand_datacube, shapefile_df, "District")
```
"""
function aggregate_per_area_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, attribute)
    if typeof(datacube) == Array{Float16, 3}
        @warn "Float 16 may not be sufficient to aggregate."
    end
    datacube = sparse_cube(datacube)
    df = DataFrame()
    @showprogress for i in 1:length(shapefile_df[:, 1])
        shapefile_row = shapefile_df[i, :]
        geom_polygon = polygon_mask(geometry, shapefile_row)
        df[!, shapefile_df[!, attribute][i]] = aggregate_timeseries(datacube, geom_polygon) ./mask_area(geom_polygon)
        i = i + 1
    end
    return df
end