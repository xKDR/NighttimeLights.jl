@testset "na_interp_linear" begin
    too_gappy(ts) = count(ismissing, ts) > 0.9 * length(ts)

    @property max_examples=CHEAP function too_gappy_series_become_zeros(ts = gappy_series(radiance()))
        assume!(too_gappy(ts))
        out = na_interp_linear(ts)
        eltype(out) == Float64 && length(out) == length(ts) && all(iszero, out)
    end

    @test na_interp_linear(Vector{Missing}(missing, 5)) == zeros(Float64, 5)

    @property max_examples=CHEAP function fills_every_gap_within_neighbours(ts = gappy_series(radiance()))
        assume!(!too_gappy(ts))
        out = na_interp_linear(ts)
        obs = findall(!ismissing, ts)
        length(out) == length(ts) && !any(ismissing, out) &&
            isequal(out[obs], ts[obs]) &&
            all(eachindex(ts)) do i
                prev = something(findlast(<=(i), obs), 1)
                next = something(findfirst(>=(i), obs), length(obs))
                lo, hi = minmax(ts[obs[prev]], ts[obs[next]])
                lo - 1e-9 <= out[i] <= hi + 1e-9
            end
    end

    @property max_examples=CHEAP function reconstructs_a_line(ts = gappy_series(Data.Just(1.0); min_size = 2),
                                                           a = floats(-100.0, 100.0), b = floats(-10.0, 10.0))
        assume!(!too_gappy(ts))
        line = a .+ b .* (1:length(ts))
        out = na_interp_linear(ifelse.(ismissing.(ts), missing, line))
        obs = findall(!ismissing, ts)
        inner = first(obs):last(obs)
        isapprox(out[inner], line[inner]; atol = 1e-8)
    end
end
