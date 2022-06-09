
"""
load_example()
table = mumbai_map
random = rand(Int8, length(table.geometry))
plot_chloropleth(table, random)
"""
function plot_chloropleth(geoms, data)
    n=length(geoms.geometry)
    colors=Array{String,2}(undef,1,n)
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
    end

    plot(geoms.geometry,color=colors,lw=0.1)
end


