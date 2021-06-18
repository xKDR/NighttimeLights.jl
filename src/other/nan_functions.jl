## There are many NaNs in the data. Missing values are also considered NaN. The following functions help dealing with NaNs. 
function counter_nan(x)
    """Counts the number of NaN in an array"""
        count = 0 
        for y in x
            if isnan(y)==true
            count = count+1
            end
        end
        return count
    end
    
function max_nan(x)
"""Finds the maximum value of a array where NaN are present.""" 
    y = replace(copy(x), NaN => 0)
    return(maximum(y))
end

function mean_nan(x)
"""Finds the mean value of a array where NaN are present.""" 
    flat = vcat(x...)
    nans = counter_nan(flat)
    y = replace(x, NaN => 0)
    return sum(y)/(length(flat)-nans)
end

function replace_nan(datacube,replacement = 0)
"""Replaces all the NaN values in a 3D array with replacement value provided as a parameter."""
    for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            for k in 1:size(datacube)[3]
                if isnan(datacube[i,j,k])
                    datacube[i,j,k] = replacement
                end
            end
        end
    end
    return datacube
end
    