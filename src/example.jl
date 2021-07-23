""" 
The datacubes and the district level shapefile for Mumbai city are provided with the package as examples. These can be loaded using the function. The radiance datacube, cloud-free observations datacube and the shapefile of Mumbai districts are loaded as global variables. 

    """
    function load_example()
        println("Loading sample data")
        package_path = pathof(NighttimeLights)
        path_len = length(package_path)
        assets_path = package_path[1:path_len-22] * "assets"
        map_path = assets_path * "/mumbai_map/mumbai_districts.shp"
        radiance_jld_path = assets_path * "/mumbai_ntl/datacube/mumbai_radiance.jld"
        clouds_jld_path = assets_path * "/mumbai_ntl/datacube/mumbai_clouds.jld"
        
        global radiance_datacube = load_datacube(radiance_jld_path)
        global clouds_datacube = load_datacube(radiance_jld_path)
        global mumbai_map = load_shapefile(map_path)
        """
        i) Distict level shapefile of Mumbai is loaded as mumbai_map. 
        ii) Radiance datacube of Mumbai is loaded as radiance_datacube. 
        iii) Cloud-free observations data is loaded as clouds_datacube. 
        iv) MUMBAI_COORDINATE_SYSTEM should be used as the coordinate system. 
        """
        println("
        Follow the tutorial on:
        
        http://nighttimelights.s3-website.ap-south-1.amazonaws.com/tutorial.html")

end

