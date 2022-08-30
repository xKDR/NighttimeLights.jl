
"""
Plots a chloropleth map using a vector of values and a shapefile. A symbol indiciating the column which contains the names of the polygons (or any column) should be passed to the function. 
```julia
load_example()
code = rand(2)
plot_chloropleth(mumbai_map, code, :DISTRICT)
```
"""
function plot_chloropleth(geoms::DataFrames.DataFrame, data::Vector, names::Symbol)
    n=length(geoms.geometry)
    colors=Array{String,2}(undef,1,n)
    hovers=Array{String,2}(undef,1,n)
    M=maximum(data)
    m=minimum(data)
    k=M/6-m/6

    for i in 1:n
        if (data[i]>m+5*k)
            colors[i]="#8B0000"
        elseif (data[i]<=m+5*k && data[i]>m+4*k)
            colors[i]="#B22222"
        elseif (data[i]<=m+4*k && data[i]>m+3*k)
            colors[i]="#DC143C"
        elseif (data[i]<=m+3*k && data[i]>m+2*k)
            colors[i]="#CD5C5C"
        elseif (data[i]<=m+2*k && data[i]>m+k)
            colors[i]="#FA8072"
        else
            colors[i]="#FFA07A"
        end
        hovers[i]=geoms[!,string(names)][i]*": "*string(data[i])
    end
        
    plotlyjs()
    plot(geoms.geometry,color=colors,hover=hovers,lw=0.3)
end

"""
The `plot_chloropleth` can use a column name to plot instead of a vector of values. 

```julia
load_example()
plot_chloropleth(mumbai_map, :censuscode, :DISTRICT)
```
"""
function plot_chloropleth(geoms::DataFrames.DataFrame, data::Symbol, names::Symbol)
    plot_chloropleth(geoms, geoms[!,string(data)], names)
end

"""
The `plot_img` function plots a 2D matrix and paints a grid of latitudes and longitudes using the specified coordinate system. 
```julia
load_example()
april2012 = radiance_datacube[:,:,1]
plot_img(april2012, MUMBAI_COORDINATE_SYSTEM)
```
"""
function plot_img(img, coordinate_system)

    function lat(c, a, b)
        return round(image_to_coordinate(c, [a, b]).latitude; digits=2)
    end
    
    function lon(c, a, b)
        return round(image_to_coordinate(c, [a, b]).longitude; digits=2)
    end
    
    a=size(img)[1]/6
    b=size(img)[2]/5
    c=coordinate_system

    xc=[b, 2*b, 3*b, 4*b]
    yc=[a, 2*a, 3*a, 4*a, 5*a]
    xcs=[lon(c,1,b), lon(c,1,2*b), lon(c,1,3*b), lon(c,1,4*b)]
    ycs=[lat(c,a,1), lat(c,2*a,1), lat(c,3*a,1), lat(c,4*a,1), lat(c,5*a,1)]

    Plots.plot(Gray.(img))
    plot!(xc, seriestype="vline", xticks = (xc,xcs), label="", color=:red, linestyle=:dot)
    plot!(yc, seriestype="hline", yticks = (yc,ycs), label="", color=:red, linestyle=:dot)
    xlabel!("longitude")
    ylabel!("latitude")
end


"""
If user wants to specify lat-long to put a crosshair inside the graph then the variable coordinate = Coordinate(lat,long) should be used
"""

function plot_img(img, coordinate_system,coordinate::Coordinate)

function lat(c, a, b)
return round(image_to_coordinate(c, [a, b]).latitude; digits=2)
end
function lon(c, a, b)
return round(image_to_coordinate(c, [a, b]).longitude; digits=2)
end
a=size(img)[1]/6
b=size(img)[2]/5
c=coordinate_system

xc=[b, 2*b, 3*b, 4*b]
yc=[a, 2*a, 3*a, 4*a, 5*a]
xcs=[lon(c,1,b), lon(c,1,2*b), lon(c,1,3*b), lon(c,1,4*b)]
ycs=[lat(c,a,1), lat(c,2*a,1), lat(c,3*a,1), lat(c,4*a,1), lat(c,5*a,1)]

Plots.plot(Gray.(img))
plot!(xc, seriestype="vline", xticks = (xc,xcs), label="", color=:red, linestyle=:dot)
plot!(yc, seriestype="hline", yticks = (yc,ycs), label="", color=:red, linestyle=:dot)
scatter!((coordinate.latitude,coordinate.longitude),markersize = 10,label ="",markershape =:cross,markercolor =:red)
xlabel!("longitude")
ylabel!("latitude")
end



"""
The `plot_datacube` function plots the individual images of a datacube and paints a grid of latitudes and longitudes using the specified coordinate system. It compiles all the images in a PDF file. It uses a vector of dates to put a title on each image. 

```julia
using Dates
load_example()
dates = collect(Date(2012,4):Month(1):Date(2020, 02))
plot_datacube(radiance_datacube, MUMBAI_COORDINATE_SYSTEM, string.(dates), "Mumbai.pdf")
```
"""
function plot_datacube(datacube, coordinate_system, date, filename)
    map=[]

    function plot_img(img, coordinate_system, i)

        function lat(c, a, b)
            return round(image_to_coordinate(c, [a, b]).latitude; digits=2)
        end
        
        function lon(c, a, b)
            return round(image_to_coordinate(c, [a, b]).longitude; digits=2)
        end

        a=size(img)[1]/6
        b=size(img)[2]/5
        c=coordinate_system
    
        xc=[b, 2*b, 3*b, 4*b]
        yc=[a, 2*a, 3*a, 4*a, 5*a]
        xcs=[lon(c,1,b), lon(c,1,2*b), lon(c,1,3*b), lon(c,1,4*b)]
        ycs=[lat(c,a,1), lat(c,2*a,1), lat(c,3*a,1), lat(c,4*a,1), lat(c,5*a,1)]

        p=plot(Gray.(img), title=date[i], xlabel="longitude", ylabel="latitude")
        plot!(xc, seriestype=:vline, xticks = (xc,xcs), label="", color=:red, linestyle=:dot)
        plot!(yc, seriestype=:hline, yticks = (yc,ycs), label="", color=:red, linestyle=:dot)

        append!(map,[p])
    end
    
    for i in 1:size(datacube)[3]
        img=datacube[:, :, i]
        plot_img(img, coordinate_system, i)
    end

    Plots.GR.beginprint(filename)
    gr(show=true)
    for i in 1:size(datacube)[3]
        plot(map[i])
    end
    Plots.GR.endprint()
end
