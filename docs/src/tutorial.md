The following example demonstrates how to use nighttime lights data for research. The following steps have been following in the paper: 

```julia
datacube = replace!(x -> x < 0 ? NaN : x, datacube) # replace all values below 0 with NaN
```