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
    readnl(xlims = X(Rasters.Between(65.39, 99.94)), ylims = Y(Rasters.Between(5.34, 39.27)), start_date = Date(2012, 04), end_date = Date(2023, 01))

Read nighttime lights data from a specific directory and return two raster series representing radiance and coverage.

# Arguments
- `xlims`: An instance of `X(Rasters.Between(min, max))`, defining the X-coordinate limits. Default is `X(Rasters.Between(65.39, 99.94))`.
- `ylims`: An instance of `Y(Rasters.Between(min, max))`, defining the Y-coordinate limits. Default is `Y(Rasters.Between(5.34, 39.27))`.
- `start_date`: The start date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2012, 04)`.
- `end_date`: The end date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2023, 01)`.

# Returns
Two data cubes. The first contains the radiance data, and the second contains the coverage data. Each data cube includes data from the start_date to the end_date, sorted in ascending order.
# Examples
```julia
using Rasters
xlims = X(Rasters.Between(65.39, 75.39))
ylims = Y(Rasters.Between(5.34, 15.34))
start_date = Date(2015, 01)
end_date = Date(2020, 12)
rad_dc, cf_dc = readnl(xlims, ylims, start_date, end_date)
"""
function readnl(xlims = X(Rasters.Between(65.39, 99.94)), ylims = Y(Rasters.Between(5.34, 39.27)), start_date = Date(2012, 04), end_date = Date(2023, 01); rad_path =  "/mnt/giant-disk/nighttimelights/monthly/rad/", cf_path = "/mnt/giant-disk/nighttimelights/monthly/cf/")
    lims = xlims, ylims
    rad_files, sorted_dates = sort_files_by_date(rad_path, start_date, end_date)
    cf_files, sorted_dates = sort_files_by_date(cf_path, start_date, end_date)
    rad_raster_list = [Raster(i, lazy = true)[lims...] for i in rad_path .* rad_files]
    cf_raster_list = [Raster(i, lazy = true)[lims...] for i in cf_path .* cf_files]
    rad_series = RasterSeries(rad_raster_list, Ti(sorted_dates))
    cf_series = RasterSeries(cf_raster_list, Ti(sorted_dates))
    rad_datacube = Rasters.combine(rad_series, Ti)
    cf_datacube = Rasters.combine(cf_series, Ti)
    return rad_datacube, cf_datacube
end

"""
    readnl(geom, start_date = Date(2012, 04), end_date = Date(2023, 01))

Read nighttime lights data from a specific directory and return two raster data cubes representing radiance and coverage. This function also crops the rasters based on the given geometry.

# Arguments
- `geom`: A geometry object, which will be used to crop the rasters. This could be an instance of `Geometry`, `Polygon`, `MultiPolygon`, etc. from a shapefile.
- `start_date`: The start date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2012, 04)`.
- `end_date`: The end date (inclusive) of the period for which to load data. Should be an instance of `Date`. Default is `Date(2023, 01)`.

# Returns
Two `RasterDataCube` instances. The first contains the cropped radiance data, and the second contains the cropped coverage data. Each `RasterDataCube` includes data from the `start_date` to the `end_date`, sorted in ascending order.

# Examples
```julia
using Geometries
geom = Geometries.read("path_to_your_shapefile.shp")  # replace this with your actual shapefile
start_date = Date(2015, 01)
end_date = Date(2020, 12)
rad_dc, cf_dc = readnl(geom, start_date, end_date)
```
"""
function readnl(geom, start_date = Date(2012, 04), end_date = Date(2023, 01); rad_path =  "/mnt/giant-disk/nighttimelights/monthly/rad/", cf_path = "/mnt/giant-disk/nighttimelights/monthly/cf/")
    rad_files, sorted_dates = sort_files_by_date(rad_path, start_date, end_date)
    cf_files, sorted_dates = sort_files_by_date(cf_path, start_date, end_date)
    rad_raster_list = [crop(Raster(i, lazy = true), to = geom) for i in rad_path .* rad_files]
    cf_raster_list = [crop(Raster(i, lazy = true), to = geom) for i in cf_path .* cf_files]
    rad_series = RasterSeries(rad_raster_list, Ti(sorted_dates))
    cf_series = RasterSeries(cf_raster_list, Ti(sorted_dates))
    rad_datacube = Rasters.combine(rad_series, Ti)
    cf_datacube = Rasters.combine(cf_series, Ti)
    return rad_datacube, cf_datacube
end