
function detrend_ts(arr)
    """
    This function removes time trend from a time series (array)
    """
    x = collect(0:1/12:1/12*(length(arr)-1))
    x = convert(Array{Float64,1},x)
    y = convert(Array{Float64},arr)
    y = replace(y, NaN=>missing)
    data = DataFrame(X=x, Y=y)
    ols = lm(@formula(Y ~ X), data)
    f(x) = coef(ols)[1] + coef(ols)[2]*x
    return (arr - f.(x))
end
