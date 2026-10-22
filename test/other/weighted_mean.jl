@testset "weighted_mean" begin
    observations = map(Data.Vectors(map(tuple, maybe_missing(radiance()), ncfobs()); max_size = 40)) do v
        Union{Missing, Float64}[first.(v)...], last.(v)
    end
    valid(x, w) = .!ismissing.(x) .& (w .> 0)

    @property max_examples=CHEAP function zero_without_weighted_observations(o = observations)
        x, w = o
        assume!(!any(valid(x, w)))
        NighttimeLights.weighted_mean(x, w) == 0
    end

    @property max_examples=CHEAP function lies_within_weighted_observations(o = observations)
        x, w = o
        v = valid(x, w)
        assume!(any(v))
        lo, hi = extrema(x[v])
        lo - 1e-9 <= NighttimeLights.weighted_mean(x, w) <= hi + 1e-9
    end

    @property max_examples=CHEAP function invariant_to_scaling_weights(o = observations, k = Data.Integers(2, 100))
        x, w = o
        isapprox(NighttimeLights.weighted_mean(x, w), NighttimeLights.weighted_mean(x, k .* w))
    end

    @property max_examples=CHEAP function float16_does_not_overflow(o = observations)
        x, w = o
        x16 = map(v -> ismissing(v) ? missing : Float16(300v), x)
        isapprox(NighttimeLights.weighted_mean(x16, w), NighttimeLights.weighted_mean(map(v -> ismissing(v) ? missing : Float64(v), x16), w))
    end
end
