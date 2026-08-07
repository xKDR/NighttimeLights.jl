# Define a function that sorts the files in a folder by date
function sort_files_by_date(folder_path, start_date=Date(0), end_date=Date(today()))
    function extract_date(filename)
        # Extract the date range using regex
        m = match(r"_(\d{8})-\d{8}_", filename)
        return m == nothing ? nothing : DateTime(Date(m[1], "yyyymmdd"))
    end
    # Get the list of file names in the directory
    files = readdir(folder_path)
    # Filter out files that we couldn't extract a date from and are not within the date range
    files = filter(x -> (d = extract_date(x)) != nothing && start_date <= d <= end_date, files)
    # Sort files based on the date they contain
    sort!(files, by=extract_date)
    # Extract the list of dates
    dates = map(extract_date, files)
    # Return the sorted files and their corresponding dates
    return files, dates
end

"""
    readnl_date(date::Date; rad_path, cf_path, resample_factor)

Read and load two raster files (radiance and cloud fraction) for a specified date.

# Arguments
- `date::Date`: The date for which to read the rasters.
- `rad_path` (default: "/mnt/giant-disk/nighttimelights/monthly/rad/"): Path to radiance data files.
- `cf_path` (default: "/mnt/giant-disk/nighttimelights/monthly/cf/"): Path to cloud fraction data files.
- `resample_factor` (default: nothing): Optional factor to resample the raster dimensions.

# Returns
A tuple of two `Raster` objects: (radiance, cloud_fraction).

# Example
```julia
today = Date(2023, 1)
rad_data, cf_data = readnl_date(today)
```
"""
function readnl_date(date::Date; rad_path =  "/mnt/giant-disk/nighttimelights/monthly/rad/", cf_path = "/mnt/giant-disk/nighttimelights/monthly/cf/", resample_factor = nothing)
    rad_files, sorted_dates = sort_files_by_date(rad_path, date, date)
    cf_files, sorted_dates = sort_files_by_date(cf_path, date, date)
    
    rad_raster = Raster(rad_path .* rad_files[1], lazy = true)
    cf_raster = Raster(cf_path .* cf_files[1], lazy = true)
    
    if !isnothing(resample_factor)
        rad_raster = resample(rad_raster, size = Int.(round.(size(rad_raster) ./ resample_factor)))
        cf_raster = resample(cf_raster, size = Int.(round.(size(cf_raster) ./ resample_factor)))
    end
    
    return rad_raster, cf_raster
end

"""
    readnl_rectangle(xlims = X(Rasters.Between(65.39, 99.94)), ylims = Y(Rasters.Between(5.34, 39.27)), start_date = Date(2012, 04), end_date = Date(2023, 01); resample_factor = nothing)

Read nighttime lights data from a specific directory and return two raster series representing radiance and coverage.

# Arguments
- `xlims`: An instance of `X(Rasters.Between(min, max))`, defining the X-coordinate limits. Default is `X(Rasters.Between(65.39, 99.94))`.
- `ylims`: An instance of `Y(Rasters.Between(min, max))`, defining the Y-coordinate limits. Default is `Y(Rasters.Between(5.34, 39.27))`.
- `start_date`: The start date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2012, 04)`.
- `end_date`: The end date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2023, 01)`.
- `resample_factor`: Optional factor to resample the raster. If provided, the raster dimensions will be divided by this factor.

# Returns
Two data cubes. The first contains the radiance data, and the second contains the coverage data. Each data cube includes data from the start_date to the end_date, sorted in ascending order.
# Examples
```julia
using Rasters
xlims = X(Rasters.Between(65.39, 75.39))
ylims = Y(Rasters.Between(5.34, 15.34))
start_date = Date(2015, 01)
end_date = Date(2020, 12)
rad_dc, cf_dc = readnl_rectangle(xlims, ylims, start_date, end_date)
```
"""
function readnl_rectangle(xlims::X, ylims::Y, start_date::Date = Date(2012, 04), end_date::Date = Date(2023, 01); rad_path =  "/mnt/giant-disk/nighttimelights/monthly/rad/", cf_path = "/mnt/giant-disk/nighttimelights/monthly/cf/", resample_factor = nothing)
    lims = xlims, ylims
    rad_files, sorted_dates = sort_files_by_date(rad_path, start_date, end_date)
    cf_files, sorted_dates = sort_files_by_date(cf_path, start_date, end_date)
    
    if !isnothing(resample_factor)
        rad_raster_list = [let r = Raster(i, lazy = true); resample(r, size = Int.(round.(size(r) ./ resample_factor)))[lims...] end for i in rad_path .* rad_files]
        cf_raster_list = [let r = Raster(i, lazy = true); resample(r, size = Int.(round.(size(r) ./ resample_factor)))[lims...] end for i in cf_path .* cf_files]
    else
        rad_raster_list = [Raster(i, lazy = true)[lims...] for i in rad_path .* rad_files]
        cf_raster_list = [Raster(i, lazy = true)[lims...] for i in cf_path .* cf_files]
    end

    rad_series = RasterSeries(rad_raster_list, Ti(sorted_dates))
    cf_series = RasterSeries(cf_raster_list, Ti(sorted_dates))
    rad_datacube = Rasters.combine(rad_series, Ti)
    cf_datacube = Rasters.combine(cf_series, Ti)
    return rad_datacube, cf_datacube
end

"""
    readnl_geom(geom, start_date = Date(2012, 04), end_date = Date(2023, 01); resample_factor = nothing)

Read nighttime lights data from a specific directory and return two raster data cubes representing radiance and coverage. This function also crops the rasters based on the given geometry.

# Arguments
- `geom`: A geometry object, which will be used to crop the rasters. This could be an instance of `Geometry`, `Polygon`, `MultiPolygon`, etc. from a shapefile.
- `start_date`: The start date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2012, 04)`.
- `end_date`: The end date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2023, 01)`.
- `resample_factor`: Optional factor to resample the raster. If provided, the raster dimensions will be divided by this factor.

# Returns
Two `RasterDataCube` instances. The first contains the cropped radiance data, and the second contains the cropped coverage data. Each `RasterDataCube` includes data from the `start_date` to the `end_date`, sorted in ascending order.

# Examples
```julia
using Shapefile
geom = Shapefile.Table("path_to_your_shapefile.shp").geometry[1]  # replace this with your actual shapefile
start_date = Date(2015, 01)
end_date = Date(2020, 12)
rad_dc, cf_dc = readnl_geom(geom, start_date, end_date)
```
"""
function readnl_geom(geom, start_date::Date = Date(2012, 04), end_date::Date = Date(2023, 01); rad_path =  "/mnt/giant-disk/nighttimelights/monthly/rad/", cf_path = "/mnt/giant-disk/nighttimelights/monthly/cf/", resample_factor = nothing)
    rad_files, sorted_dates = sort_files_by_date(rad_path, start_date, end_date)
    cf_files, sorted_dates = sort_files_by_date(cf_path, start_date, end_date)

    if !isnothing(resample_factor)
        rad_raster_list = [let c = crop(Raster(i, lazy = true), to = geom); resample(c, size = Int.(round.(size(c) ./ resample_factor))) end for i in rad_path .* rad_files]
        cf_raster_list = [let c = crop(Raster(i, lazy = true), to = geom); resample(c, size = Int.(round.(size(c) ./ resample_factor))) end for i in cf_path .* cf_files]
    else
        rad_raster_list = [crop(Raster(i, lazy = true), to = geom) for i in rad_path .* rad_files]
        cf_raster_list = [crop(Raster(i, lazy = true), to = geom) for i in cf_path .* cf_files]
    end
    
    rad_series = RasterSeries(rad_raster_list, Ti(sorted_dates))
    cf_series = RasterSeries(cf_raster_list, Ti(sorted_dates))
    rad_datacube = Rasters.combine(rad_series, Ti)
    cf_datacube = Rasters.combine(cf_series, Ti)
    return rad_datacube, cf_datacube
end

"""
    read_noise_mask(;path = "/mnt/giant-disk/ntl/noisemask/VNL_v22_npp_2024_global_vcmslcfg_c202502261200.lit_mask.dat.tif", resample_factor = nothing)

Read the noise mask file.

# Arguments
- `path`: The path to the noise mask file.
- `resample_factor`: Optional factor to resample the raster. If provided, the raster dimensions will be divided by this factor.

# Returns
A `Raster` object of the noise mask with 0s converted to missing values.
"""
function read_noise_mask(;path = "/mnt/giant-disk/ntl/noisemask/VNL_v22_npp_2024_global_vcmslcfg_c202502261200.lit_mask.dat.tif", resample_factor = nothing)
    raster = Raster(path, lazy = true)
    if !isnothing(resample_factor)
        raster = resample(raster, size = Int.(round.(size(raster) ./ resample_factor)))
    end
    # Convert 0 values to missing
    raster = Int64.(raster)
    mask = replace(raster, 0 => missing)
    return mask
end

"""
    read_noise_mask(geom; kwargs...)

Read and crop the noise mask file based on a geometry.

# Arguments
- `geom`: A geometry object to crop the raster.
- `kwargs...`: Keyword arguments passed to `read_noise_mask()`, e.g., `path` or `resample_factor`.

# Returns
A cropped `Raster` object of the noise mask with 0s converted to missing values.
"""
function read_noise_mask(geom; path = "/mnt/giant-disk/ntl/noisemask/VNL_v22_npp_2024_global_vcmslcfg_c202502261200.lit_mask.dat.tif", resample_factor = nothing, kwargs...)
    raster = Raster(path, lazy = true)
    cropped = crop(raster, to = geom)
    if !isnothing(resample_factor)
        cropped = resample(cropped, size = Int.(round.(size(cropped) ./ resample_factor)))
    end
    # Convert 0 values to missing
    cropped = Int64.(cropped)
    mask = replace(cropped, 0 => missing)
    return mask
end

"""
    read_noise_mask(xlims, ylims; kwargs...)

Read and crop the noise mask file based on X and Y limits.

# Arguments
- `xlims`, `ylims`: X and Y coordinate limits for cropping.
- `kwargs...`: Keyword arguments passed to `read_noise_mask()`, e.g., `path` or `resample_factor`.

# Returns
A cropped `Raster` object of the noise mask with 0s converted to missing values.
"""
function read_noise_mask(xlims, ylims; path = "/mnt/giant-disk/ntl/noisemask/VNL_v22_npp_2024_global_vcmslcfg_c202502261200.lit_mask.dat.tif", resample_factor = nothing, kwargs...)
    raster = Raster(path, lazy = true)
    cropped = raster[xlims, ylims]
    if !isnothing(resample_factor)
        cropped = resample(cropped, size = Int.(round.(size(cropped) ./ resample_factor)))
    end
    # Convert 0 values to missing
    cropped = Int64.(cropped)
    mask = replace(cropped, 0 => missing)
    return mask
end 