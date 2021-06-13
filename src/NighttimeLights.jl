module NighttimeLights

# Write your package code here.
using ArchGDAL
using GeoArrays
export load_img, load_datacube, save_img, save_datacube
include("data_io.jl")
end
