#Modifying impute function from https://github.com/invenia/Impute.jl/blob/master/src/imputors/interp.jl 

"""
Uses linear interpolation to fill for missing values. This function work for any kind of array, and not just nighttime lights radiance time series data. 
```
x = rand(1:10.0, 10)
x = Vector{Union{Missing, Float64}}(x)
x[5] = missing
na_interp_linear(x)
```
"""
function na_interp_linear(timeseries)
    if  count(i->(ismissing(i)), timeseries) > length(timeseries) *0.9
        return zero(1:length(timeseries))
    end
    data = copy(timeseries)
    i = findfirst(!ismissing, data) + 1
    while i < length(data)
        if ismissing(data[i])
            prev_idx = i - 1
            next_idx = findnext(!ismissing, data, i + 1)
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
    if count(i->(ismissing(i)), data)>0 
        data[1:findfirst(!ismissing, data)] .= data[findfirst(!ismissing, data)]
        data = reverse(data)
        data[1:findfirst(!ismissing, data)] .= data[findfirst(!ismissing, data)]
        data = reverse(data)
    end
    return data
end
