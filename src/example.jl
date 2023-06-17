global radiance_datacube 
global ncfobs_datacube 
global mumbai_map 
""" 
The datacubes and the district level shapefile for Mumbai city are provided with the package as examples. These can be loaded using the function. The radiance datacube, cloud-free observations datacube and the shapefile of Mumbai districts are loaded as global variables. 
    """
    function load_example()
        println("Loading sample data")
        package_path = pathof(NighttimeLights)
        path_len = length(package_path)
        assets_path = package_path[1:path_len-22] * "assets"
        map_path = assets_path * "/mumbai_map/mumbai_districts.shp"
        radiance_path = assets_path * "/mumbai_ntl/datacube/mumbai_radiance.nc"
        ncfobs_path = assets_path * "/mumbai_ntl/datacube/mumbai_clouds.nc"
        global radiance_datacube = Raster(radiance_path)
        global ncfobs_datacube = Raster(ncfobs_path)
        global mumbai_map = Shapefile.Table(map_path)
        """
        i) Distict level shapefile of Mumbai is loaded as mumbai_map. 
        ii) Radiance datacube of Mumbai is loaded as radiance_datacube. 
        iii) Cloud-free observations data is loaded as ncfobs_datacube. 
        """
        println("
        Follow the tutorial on:
        
        https://xkdr.github.io/NighttimeLights.jl/tutorial.html
        
        radiance_datacube, ncfobs_datacube and mumbai_map are loaded
        ")

end
