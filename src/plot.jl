
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