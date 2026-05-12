"""
Function replaces the negative values in a datacube with a user specified value. The replacement value defaults to `missing`.
"""
function replace_negative(radiance_datacube; replacement = missing)
    radiance_datacube = map(x -> (!ismissing(x) && x < 0) ? replacement : x, radiance_datacube)
    return radiance_datacube
end
