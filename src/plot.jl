
"""
load_example()
code=mumbai_map.censuscode
plot_chloropleth(mumbai_map, code, :DISTRICT)
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
load_example()
plot_chloropleth(mumbai_map, :censuscode, :DISTRICT)
"""
function plot_chloropleth(geoms::DataFrames.DataFrame, data::Symbol, names::Symbol)
    plot_chloropleth(geoms, geoms[!,string(data)], names)
end

"""
load_example()
april2012=radiance_datacube[:,:,1]
plot_img(april2012, MUMBAI_COORDINATE_SYSTEM)
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
load_example()
plot_datacube(radiance_datacube, MUMBAI_COORDINATE_SYSTEM)
"""
function plot_datacube(datacube, coordinate_system)
    month=["April, ", "May, ", "June, ", "July, ", "August, ", "September, ", "October, ", "November, ", "December, ", "January, ", "February, ", "March, "]
    year=["2012","2013","2014","2015","2016","2017","2018","2019","2020"]
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
        
        if (mod(i,12)>0) 
            s=month[Int64(mod(i,12))]*year[Int64(ceil((i+3)/12))] 
        else 
            s=month[12]*year[Int64(ceil((i+3)/12))] 
        end

        p=plot(Gray.(img), title=s, xlabel="longitude", ylabel="latitude")
        plot!(xc, seriestype=:vline, xticks = (xc,xcs), label="", color=:red, linestyle=:dot)
        plot!(yc, seriestype=:hline, yticks = (yc,ycs), label="", color=:red, linestyle=:dot)

        append!(map, [p])
    end
    
    for i in 1:size(datacube)[3]
        img=datacube[:, :, i]
        plot_img(img, coordinate_system, i)
    end

    Plots.GR.beginprint("mumbai.pdf")
    gr(show=true)
    for i in 1:size(datacube)[3]
        plot(map[i])
    end
    Plots.GR.endprint()
end
