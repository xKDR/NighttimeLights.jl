
"""
This function removes time trend from a timeseries. 
"""
function detrend_ts(timeseries)
    x = collect(0:1/12:1/12*(length(timeseries)-1))
    x = convert(Array{Float64,1},x)
    y = Array{Union{Float64, Missing}}(timeseries)
    data = DataFrame(X=x, Y=y)
    ols = lm(@formula(Y ~ X), data)
    f(x) = coef(ols)[1] + coef(ols)[2]*x
    return (timeseries - f.(x))
end
