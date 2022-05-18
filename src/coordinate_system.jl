"""
Makes a coordinate given latitude and longitude
#Example:

```julia
Coordinate(37.5, 67.91666)
```
"""
struct Coordinate
    latitude
    longitude
end

function Base.show(io::IO, coords::Coordinate)
    println("Latitude: ", coords.latitude)
    print("Longitude: ", coords.longitude)
end
"""
The mapping between the coordinates of earth and indices of the image is needed to convert from one to another. In this package such mapping is referred to as a coordinate system. To define a coordinate system, you need to provide coordinates of the top-left and bottom-right pixels, and the height and the width of the image. 

Suppose the image we plan to load had 8000 rows and 7100 columns. The top-left coordinate (37.5, 67.91666) is and bottom-right (4.166, 97.5). We can use these to create a the mapping. 

```julia
top_left     = Coordinate(37.5, 67.91666)
bottom_right = Coordinate(4.166, 97.5)
height = 8000
width  = 7100
my_coordinate_system = CoordinateSystem(top_left, bottom_right, height, width)
```

Now functions can use this mapping to go from one to another. 
"""
struct CoordinateSystem
    top_left::Coordinate
    bottom_right::Coordinate 
    height::Int64
    width::Int64
end

function Base.show(io::IO, geometry::CoordinateSystem)
    println("Top left: (", geometry.top_left.latitude, ", ", geometry.top_left.longitude, ")")
    println("Bottom right: (", geometry.bottom_right.latitude, ", ", geometry.bottom_right.longitude, ")")
    println("Height:", geometry.height)
    print("width: ", geometry.width)
end

global TILE1_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(75, -180), Coordinate(0, -60), 18000, 28800)
global TILE2_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(75, -60), Coordinate(0, 60), 18000, 28800)
global TILE3_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(75, 60), Coordinate(0, 180), 18000, 28800)
global TILE4_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(0, -180), Coordinate(-65, -60), 15600, 28800)
global TILE5_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(0, -60), Coordinate(-65, 60), 15600, 28800)
global TILE6_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(0, 60), Coordinate(-65, 180), 15600, 28800)
global FULL_COORDINATE_SYSTEM  = CoordinateSystem(Coordinate(75, -180), Coordinate(-65, 180), 33600, 86400)

global INDIA_COORDINATE_SYSTEM = CoordinateSystem(Coordinate(37.5, 67.91666), Coordinate(4.166, 97.5), 8000, 7100)
