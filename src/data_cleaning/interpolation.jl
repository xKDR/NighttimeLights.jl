#Modifying impute function from https://github.com/invenia/Impute.jl/blob/master/src/imputors/interp.jl 

using RCall
R"""
library(forecast)
"""
R"""
RInterp <- function(x) {
    return<-na.interp(x)

}"""
function forecast_interp(arr)
    array =copy(arr)
    """
    Applies na.interp from Rob Hyndman's package forecast in R
    """
    return convert(Array{Float16},rcall(:RInterp,array))
end

function linear_interpolation(array)
    if counter_nan(array)>50
        return zero(1:length(array))
    end
    data = copy(array)
    i = findfirst(!isnan, data) + 1
    while i < length(data)
        if isnan(data[i])
            prev_idx = i - 1
            next_idx = findnext(!isnan, data, i + 1)
            if next_idx !== nothing
                gap_sz = (next_idx - prev_idx) - 1

                diff = data[next_idx] - data[prev_idx]
                incr = diff / (gap_sz + 1)
                val = data[prev_idx] + incr
                for j in i:(next_idx - 1)
                    data[j] = val
                    val += incr
                end
                i = next_idx
            else
                break
            end
        end
        i += 1
    end
    if counter_nan(data)>0 
        data = forecast_interp(data)
    end
    return data
end
