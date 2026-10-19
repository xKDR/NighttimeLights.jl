# Supposition generators

# Example runs for cheap/costly runs
const CHEAP = 300
const COSTLY = 15

# Julia 1.10: @property wraps @check otherwise test doesn't count results
macro property(args...)
    esc(:(@test something((Supposition.@check $(args...)).result) isa Supposition.Pass))
end

floats(lo, hi) = Data.Floats{Float64}(; nans = false, minimum = lo, maximum = hi)

# typical radiance ranges; small, negative, tests above the ceiling widen the range themselves.
radiance() = floats(-5.0, 200.0)
ncfobs() = Data.Integers(0, 31)

# missing ~ pct%.
maybe_missing(g, pct = 20) = map((x, u) -> u < pct ? missing : x, g, Data.Integers(0, 99))

function gappy_series(g; min_size = 1, max_size = 60)
    Data.bind(Data.Integers(0, 100)) do pct
        map(v -> Vector{Union{Missing, Float64}}(v), Data.Vectors(maybe_missing(g, pct); min_size, max_size))
    end
end

const cube_dims = map(tuple, Data.Integers(1, 3), Data.Integers(1, 3), Data.Integers(24, 36))

function cubes(elems...; dims = cube_dims, max_size = 3 * 3 * 36)
    vecs = map(e -> Data.Vectors(e; min_size = max_size, max_size), elems)
    map((d, vs...) -> map(v -> copyto!(similar(v, d), 1, v, 1, prod(d)), vs), dims, vecs...)
end

as_raster(a) = Raster(a, (X(1.0:size(a, 1)), Y(1.0:size(a, 2)), Ti(1:size(a, 3))))
as_missable(a) = Array{Union{Missing, eltype(a)}}(a)
