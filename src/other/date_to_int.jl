"""
```julia
dates = collect(Date(2012,4):Month(1):Date(2022, 06))
timestamps = yearmon.(dates)
```
"""
function yearmon(x)                                                                                                                        
    Dates.format(x, Dates.dateformat"YYYYmm")                                                                                   
end
