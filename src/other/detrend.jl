"""
This function removes time trend from a timeseries using direct OLS computation.
"""
function detrend_ts(timeseries)
    n = length(timeseries)
    x = collect(0.0:(1/12):(1/12*(n-1)))
    y = Array{Float64}(timeseries)
    x̄ = sum(x) / n
    ȳ = sum(y) / n
    Sxy = zero(Float64)
    Sxx = zero(Float64)
    @inbounds for i in 1:n
        dx = x[i] - x̄
        Sxy += dx * (y[i] - ȳ)
        Sxx += dx * dx
    end
    b = Sxy / Sxx
    a = ȳ - b * x̄
    return timeseries .- (a .+ b .* x)
end
