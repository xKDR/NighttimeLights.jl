## There are many missing in the data. The following functions help dealing with missings. 
function check_missing(x)
    for i in x
        if ismissing(i) ==true
            return true
        end
    end
    return false
end

function count_missing(x)
    """Counts the number of missing values in an array"""
        count = 0 
        for y in x
            if ismissing(y)==true
            count = count+1
            end
        end
        return count
    end
    
function max_missing(x)
"""Finds the maximum value of a array where missing are present.""" 
    y = replace(copy(x), missing => 0)
    return(maximum(y))
end

function mean_missing(x)
"""Finds the mean value of a array where missing are present.""" 
    flat = vcat(x...)
    missings = count_missing(flat)
    y = replace(x, missing => 0)
    return sum(y)/(length(flat)- missings)
end

function replace_missing(datacube, replacement = 0)
"""Replaces all the missing values in a 3D array with replacement value provided as a parameter."""
    for i in 1:size(datacube)[1]
        for j in 1:size(datacube)[2]
            for k in 1:size(datacube)[3]
                if ismissing(datacube[i,j,k])
                    datacube[i,j,k] = replacement
                end
            end
        end
    end
    return datacube
end
    