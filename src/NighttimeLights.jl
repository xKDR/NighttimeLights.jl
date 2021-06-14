module NighttimeLights

# Write your package code here.
using ArchGDAL
using GeoArrays
using DataFrames
using Shapefile
using Luxor
using GeoInterface
using GeometricalPredicates
using ProgressMeter
using SparseArrays
using StatsBase

export load_img, load_datacube, save_img, save_datacube
include("data_io.jl")
export lat_to_row, row_to_lat, lat_to_row, long_to_column, translate_coordinate_system, Coordinate, CoordinateSystem, india
include("coordinate_system.jl")
export polygon_mask, load_shapefile
include("polygons.jl")
end
