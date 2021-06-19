function load_shapefile(path = "assets/districts.shp")
    """
    Provide path to shapefile
    """
    table           = Shapefile.Table(path)                        ## Reading the shapefile
    shapefile_df    = DataFrame(table)                             ## Converting to dataframe         
    geoms                        = Shapefile.shapes(table)         ## Reading shapes from the shapefile
    shapefile_df[!, "geometry"]  = geoms 
    return shapefile_df
end

function make_polygon(geometry::CoordinateSystem, coords)
    """
    This function Luxor polygon given a list of coordinates and a coordinate system. 
    """
    Drawing(geometry.height, geometry.width)
    # Make Luxor polygon from list of coordinates.
    array           = Array{Float16}[]          ## Declaring an empty array of Float32
    array           = coords[1]                 ## Accesssing n(th) polygon from the multipolgyon.
    points_luxor    = Luxor.Point[]             ## Declaring a Luxor.Point type variable
    for x in array
        push!(points_luxor, Luxor.Point(long_to_column(geometry, x[1]), lat_to_row(geometry, x[2]))) # make FLOAT16/INT16
            # We convert the long,lat to 'Luxor.Point' and store them in points_luxor 
    end
    poly = Luxor.poly(points_luxor, :stroke) 
    return poly
end


function make_polygons(geometry::CoordinateSystem, geoms)
    """Makes a list of Luxor polygons from list of list of coordinates."""
    coord       = GeoInterface.coordinates(geoms)
    polygons    = Any[]
    for x in coord
        push!(polygons, make_polygon(geometry, x))
    end
    return polygons
end

function polygon_mask(geometry::CoordinateSystem, shapefile_row)
    geoms = shapefile_row.geometry
    polygons = make_polygons(geometry,geoms)
    points = zeros(geometry.height, geometry.width)
    for poly in polygons
        Boundary    = BoundingBox(poly)
        iend        = Int16(round(Boundary[2][2]))
        j           = Int16(round(Boundary[1][1]))
        jend        = Int16(round(Boundary[2][1]))
        i           = Int16(round(Boundary[1][2]))
        for e in i:iend
            for f in j:jend
                if Luxor.isinside(Luxor.Point(f, e), poly, allowonedge=true) == true
                    points[e,f] = 1
                end
            end
        end
    end
    return sparse(points)
end

## Using cubic spline model to define earth's curvature. 
## Data points are obtained from: https://www.ngdc.noaa.gov/mgg/topo/report/s6/s6A.html

global LAT =[-90, -89, -86, -82, -78, -74, -70, -60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 74, 78, 82, 86, 89, 90]
global EW  =[0, 16, 64, 133, 193, 256, 318, 465, 598, 712, 804, 872, 914, 928, 914, 872, 804, 712, 598, 465, 318, 256, 193, 133, 64, 16, 0]/1000
global NS  =[931, 931, 931, 931, 930, 930, 930, 929, 927, 925, 924, 923, 922, 921, 922, 923, 924, 925, 927, 929, 930, 930, 930, 931, 931,931, 931]/1000 # We divide by thousand to convert into kilometer from meter
global EW = EW / 2 # The values are for 30", our geometry is 15"
global NS = NS / 2 

global MODEL_EW = CubicSpline(LAT, EW)
global MODEL_NS = CubicSpline(LAT, NS)


function mask_area(geometry::CoordinateSystem,mask)
    area = 0 
    for i in 1:geometry.height
        for j in 1:geometry.width
            if mask[i, j] ==1 
                lat = row_to_lat(geometry, i)
                ns = MODEL_NS[lat]
                ew = MODEL_EW[lat]
                area = area + ew * ns
            end
        end
    end
    return area
end
