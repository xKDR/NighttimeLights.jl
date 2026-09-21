"""
Function replaces the negative values in a datacube with a user specified value. The replacement value defaults to `missing`. 
"""
function replace_negative(radiance_datacube; replacement = missing)
    for i in 1:prod(size(radiance_datacube))
        if ismissing(radiance_datacube[i]) 
            continue
        elseif radiance_datacube[i] < 0
                radiance_datacube[i] = replacement
        else
            continue
        end
    end
    return radiance_datacube
end

"""
Function marks radiance above a ceiling as missing. Readings this high are fill values or gas
flares rather than usable measurements of economic activity, so they are removed the same way
negative readings are. Unlike `replace_negative`, this function does not modify its argument:
it returns a new datacube, because the input may not yet be able to hold `missing`. The `T`
keyword sets the element type of that new datacube, so the ceiling and a conversion to a
smaller float can be done in a single pass.

```julia
replace_above(radiance_datacube, 8000)
replace_above(radiance_datacube, 8000; T = Float16)
```
"""
function replace_above(radiance_datacube, ceiling = 8000; replacement = missing, T = nonmissingtype(eltype(radiance_datacube)))
    data = _replace_above(parent(radiance_datacube), ceiling, replacement, T)
    return rebuild(radiance_datacube; data = data, missingval = missing)
end

# T arrives as a type parameter rather than a value, so that `convert` can be inferred. Passing
# it as an ordinary argument makes the whole map type-unstable and about 30x slower.
function _replace_above(data, ceiling, replacement, ::Type{T}) where T
    map(x -> ismissing(x) || x > ceiling ? replacement : convert(T, x), data)
end
