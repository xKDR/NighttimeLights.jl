
struct Mask
    top::Int
    left::Int
    bottom::Int
    right::Int
    vals
end

function Base.show(io::IO, mask::Mask)
    println("Top: ", mask.top)
    println("Left: ", mask.left)
    println("Bottom: ", mask.bottom)
    println("Right: ", mask.right)
    println("Points: ", sum(mask.vals))
end

"""
Polygon boundaries are usually stored in a format called shapefile. For example, the shapefile of the world will consist of country names and each country will have coordinates of the boundaries.   
```julia
load_shapefile("assets/mumbai_map/mumbai_districts.shp")
```
"""
function load_shapefile(filepath)
    table           = Shapefile.Table(filepath)                        ## Reading the shapefile
    shapefile_df    = DataFrame(table)                             ## Converting to dataframe         
    geoms                        = Shapefile.shapes(table)         ## Reading shapes from the shapefile
    shapefile_df[!, "geometry"]  = geoms 
    return shapefile_df
end

function make_polygon(geometry::CoordinateSystem, coords)
    array           = Array{Float16}[]          ## Declaring an empty array of Float32
    array           = coords[1]                 ## Accesssing n(th) polygon from the multipolgyon.
    poly    = []             ## Declaring a Luxor.Point type variable
    for x in array
        push!(poly, Point(long_to_column(geometry, x[1]), lat_to_row(geometry, x[2]))) # make FLOAT16/INT16
            # We convert the long,lat to 'Luxor.Point' and store them in points_luxor 
    end
    return convert(Array{Point, 1}, poly)
end


function make_polygons(geometry::CoordinateSystem, geoms)
    #Makes a list of Luxor polygons from list of list of coordinates
    coord       = GeoInterface.coordinates(geoms)
    polygons    = Any[]
    for x in coord
        push!(polygons, make_polygon(geometry, x))
    end
    return polygons
end

function polygon_mask(geometry::CoordinateSystem, polygon::Shapefile.Polygon)
    geoms = polygon
    polygons = make_polygons(geometry,geoms)
    points = zeros(Int32, geometry.height, geometry.width)
    bounds_i = []
    bounds_j = []
    bounds_iend = []
    bounds_jend = []
    for poly in polygons
        Boundary    = BoundingBox(poly)
        iend        = Int32(round(Boundary[2].y))
        push!(bounds_iend, iend)
        j           = Int32(round(Boundary[1].x))
        push!(bounds_j, j)
        jend        = Int32(round(Boundary[2].x))
        push!(bounds_jend, jend)
        i           = Int32(round(Boundary[1].y))
        push!(bounds_i, i)
        for e in i:iend
            for f in j:jend
                if isinside(Point(f, e), poly, allowonedge = true) == true
                    points[e,f] = 1
                end
            end
        end
    end
    bounds_i = minimum(bounds_i)
    bounds_j = minimum(bounds_j)
    bounds_iend = maximum(bounds_iend)
    bounds_jend = maximum(bounds_jend)
    if bounds_i < 0
        @warn "Top boundary problem"
        bounds_i = 0
    end
    if bounds_j < 0
        @warn "Left boundary problem"
        bounds_j = 0
    end
    if bounds_iend > geometry.height
        @warn "Bottom boundary problem"
        bounds_iend = geometry.height
    end
    if bounds_jend > geometry.width
        @warn "Right boundary problem"
        bounds_jend = geometry.width
    end
    return Mask(bounds_i, bounds_j, bounds_iend, bounds_jend, points)    
end

"""
The polygon of a shapefile row can be make into a mask. This means all the points inside the polygon will be marked as 1, while the points outside will be marked as 0.
 
```julia
load_example()
district1 = mumbai_map[1,:] # Select the first district
district1_mask = polygon_mask(MUMBAI_COORDINATE_SYSTEM, district1)
```
"""
function polygon_mask(geometry::CoordinateSystem, shapefile_row::DataFrames.DataFrameRow{DataFrames.DataFrame, DataFrames.Index})
    polygon_mask(geometry, shapefile_row.geometry)
end

