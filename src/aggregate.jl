function aggregate(mask,image)
    masked_image = copy(image).*mask
    return sum(masked_image)
end

function aggregate_timeseries(mask,datacube)
    datacube = convert(Array{Float32,3},datacube)
    datacube = sparse_cube(copy(datacube))
    datacube = apply_mask(datacube,mask)
    lights = cross_apply(sum,datacube)
    return lights
end

function aggregate_dataframe(geometry::CoordinateSystem, datacube, shapefile_df, start_year=2012, start_month=04)
    df = DataFrame()
    df2 = copy(shapefile_df)
    i = 1
    @showprogress for shapefile_row in shapefile_df
        geom_polygon = polygon_mask(geometry, shapefile_row)
        data = aggregate_timeseries(geom_polygon, datacube)
        df[repr(i)] = data
        i = i + 1
    end
    df1 = DataFrame(transpose(convert(Array{Float32,2}, df)))
    names!(df1, Symbol.(date_generator(start_year, start_month, size(datacube)[3])))
    for x in names(df1)
       df2[x] = df1[x]
       end
    return df2
    """
    To save the DataFrame as CSV, do 
    CSV.write("RESULdatacube/path.csv",df)
    """
end