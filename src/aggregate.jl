"""
The aggregate value of an image over a mask can be computed by the aggregate function. The function multiplies the image and the mask (elementwise) and then performs the summation. 
```
rand_image = rand(10, 10)
rand_mask = rand(0:1, 10, 10)
aggregate(rand_image, rand_mask)
```
"""
function aggregate(image, mask::Array{T, 2}) where T <: Real
    masked_image = copy(image).*mask
    return sum(masked_image)
end

function aggregate(image, mask::Mask) 
    tmp  = copy(image[mask.top: mask.bottom, mask.left: mask.right])
    return sum(tmp.*(mask.vals[mask.top: mask.bottom, mask.left: mask.right]))
end

"""
To find the time series of aggregate values of a datacube over a mask, using the ```aggregate_timeseries``` function

```
rand_datacube = rand(10, 10, 10)
rand_mask = rand(0:1, 10, 10)
aggregate_timeseries(rand_datacube, rand_mask)
```
"""
function aggregate_timeseries(datacube, mask::Array{T, 2}) where T <: Real
    tmp = apply_mask(copy(datacube), mask)
    lights = []
    for i in 1:size(datacube)[3]
        push!(lights, sum(tmp[:,:,i]))
    end
    return Float32.(lights)
end

function aggregate_timeseries(datacube, mask::Mask)
    tmp  = datacube[mask.top: mask.bottom, mask.left: mask.right, :]
    cropped_mask = mask.vals[mask.top: mask.bottom, mask.left: mask.right]
    lights = Vector{Float32}(undef, size(datacube)[3])
    for i in 1:size(datacube)[3]
        lights[i] = sum(tmp[:,:,i].* cropped_mask)
    end
    # dropdims(sum(dropdims(sum(radiance_datacube, dims=1), dims=1), dims = 1), dims =1)
    return lights
end

function aggregate_timeseries(datacube, polygon::Shapefile.Polygon, geometry::CoordinateSystem)
    mask = polygon_mask(geometry, polygon)
    return aggregate_timeseries(datacube, mask)
end

"""
Computes the time series of aggregate value of datacube for each row of a shapefile
# Example:
```
```julia
load_example()
aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map)
```
```
"""
function aggregate_dataframe(geometry::CoordinateSystem, datacube, shapefile_df)
    tmp(polygon::Shapefile.Polygon) = aggregate_timeseries(datacube, polygon, geometry)
    tmp(x::Vector{Shapefile.Polygon}) = tmp.(x)
    tmp(x::Vector{Union{Missing, Shapefile.Polygon}}) = tmp.(x)
    df = combine(shapefile_df, :geometry => tmp => AsTable)
    df.geometry = shapefile_df.geometry
    return leftjoin(shapefile_df, df, on = :geometry)
end

"""
Computes the time series of aggregate value of datacube for each row of a shapefile. Put the ```start_date``` and ```step``` of the dates to name the columns correctly. 
# Example:

```julia
load_example()
aggregate_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, Date(2012), Month(1))
```
"""
function aggregate_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, start_date, step)
    tmp(polygon::Shapefile.Polygon) = aggregate_timeseries(datacube, polygon, geometry)
    tmp(x::Vector{Shapefile.Polygon}) = tmp.(x)
    tmp(x::Vector{Union{Missing, Shapefile.Polygon}}) = tmp.(x)
    df = combine(shapefile_df, :geometry => tmp => AsTable)
    dates = collect(range(start = start_date, length = size(datacube)[3], step = step))
    rename!(df, string.(dates))
    df.geometry = shapefile_df.geometry
    return leftjoin(shapefile_df, df, on = :geometry)
end


"""
Computes the time series of aggregate value per area of datacube for each row of a shapefile
# Example:
```julia
load_example()
aggregate_per_area_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, 15)

```
"""
function aggregate_per_area_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, res = 15)
    tmp(polygon::Shapefile.Polygon) = aggregate_timeseries(datacube, polygon, geometry) ./mask_area(geometry, polygon_mask(geometry, polygon), res)
    tmp(x::Vector{Shapefile.Polygon}) = tmp.(x)
    tmp(x::Vector{Union{Missing, Shapefile.Polygon}}) = tmp.(x)
    df = combine(shapefile_df, :geometry => tmp => AsTable)
    df.geometry = shapefile_df.geometry
    return leftjoin(shapefile_df, df, on = :geometry) 
end

"""
Computes the time series of aggregate value per area of datacube for each row of a shapefile. You can optionally specify the ```start_date``` and ```step```.
# Example:
```julia
load_example()
aggregate_per_area_dataframe(MUMBAI_COORDINATE_SYSTEM, radiance_datacube, mumbai_map, Date(2012), Month(1), 15)
```
"""
function aggregate_per_area_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, start_date, step, res = 15)
    tmp(polygon::Shapefile.Polygon) = aggregate_timeseries(datacube, polygon, geometry) ./mask_area(geometry, polygon_mask(geometry, polygon), res)
    tmp(x::Vector{Shapefile.Polygon}) = tmp.(x)
    tmp(x::Vector{Union{Missing, Shapefile.Polygon}}) = tmp.(x)
    df = combine(shapefile_df, :geometry => tmp => AsTable)
    dates = collect(range(start = start_date, length = size(datacube)[3], step = step))
    rename!(df, string.(dates))
    df.geometry = shapefile_df.geometry
    return leftjoin(shapefile_df, df, on = :geometry) 
end


