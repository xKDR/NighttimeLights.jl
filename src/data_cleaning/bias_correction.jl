function na_exclude(f,radiance, clouds)
    na_excluded_rad = []
    na_excluded_cloud = []
    na_locations = []
    for i in 1:length(radiance)
        if isnan(radiance[i])
            push!(na_locations,i)
        else
            push!(na_excluded_rad,radiance[i])
            push!(na_excluded_cloud,clouds[i])
        end
    end
    na_excluded_rad = convert(Array{Float16,1},na_excluded_rad)
    results = f(na_excluded_rad,na_excluded_cloud)
    for i in na_locations
        insert!(na_excluded_rad,i,NaN)
    end
    return na_excluded_rad
end

# macro na_exclude(function_call) 
#     tmp = function_call
#     pushfirst!(tmp.args,:na_exclude_biascorrection)
#     eval(tmp)
# end

function bias_correction(radiance,clouds)
    if OtCorTest(radiance,clouds)>0.05
        return radiance     
    end
    log_radiance = log.(radiance) 
    ys = log_radiance
    ys = detrend_ts(ys)
    time_trend = log_radiance .- ys
    xs = clouds
    xs = xs/maximum(xs)
    model = loess(xs, ys)
    vs = Loess.predict(model, xs)
    for i in 1:length(ys)
        if ys[i]<0
            ys[i] = ys[i] + vs[findmax(xs)[2]] - vs[i]
        end
    end
    ys = ys .+ time_trend
    ys = exp.(ys)
    return ys   
end

function bias_correction_datacube(radiance_datacube,clouds_datacube,mask=ones(Int8, (size(radiance_datacube)[1],size(radiance_datacube)[2])))
    rad_corrected_datacube = copy(radiance_datacube)
    @showprogress for i in 1:size(radiance_datacube)[1]
        for j in 1:size(radiance_datacube)[2]
            if counter_nan(radiance_datacube[i,j,:])>50 
                continue
            end
            if mask[i,j]==0
                continue
            end
            radiance_arr = radiance_datacube[i,j,:]
            clouds_arr = clouds_datacube[i,j,:]
            rad_corrected_datacube[i,j,:]= na_exclude(bias_correction(radiance_arr,clouds_arr))
        end
    end
    return rad_corrected_datacube
end
