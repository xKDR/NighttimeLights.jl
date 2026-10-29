# Supposition generators

# Example runs for cheap/costly runs
const CHEAP = 300
const COSTLY = 15

# Fixed seed and no example database by default, so every run and machine sees the same inputs.
# NTL_TEST_SEED=random draws fresh inputs (and replays stored failures); any integer picks another seed.
const SEED = get(ENV, "NTL_TEST_SEED", "1")
property_rng() = SEED == "random" ? Xoshiro(rand(RandomDevice(), UInt)) : Xoshiro(parse(UInt, SEED))

# Julia 1.10: @property wraps @check otherwise test doesn't count results.
# Logs the start (a hang while shrinking shows up as a start with no end) and the outcome.
macro property(args...)
    f = args[end]
    name = string(Meta.isexpr(f, :function) ? f.args[1].args[1] : "property")
    # gensyms: the expansion is escaped, so plain names would clobber the test's own variables
    res, t0, secs = gensym(:res), gensym(:t0), gensym(:secs)
    esc(quote
        steplog("start property ", $name)
        $t0 = time()
        $res = something((Supposition.@check rng=property_rng() db=(SEED == "random") $(args...)).result)
        $secs = round(time() - $t0; digits = 1)
        $res isa Supposition.Pass ? steplog("pass property ", $name, " (", $secs, "s)") :
            steplog("FAIL property ", $name, " (", $secs, "s): ", first(sprint(show, $res), 500))
        @test $res isa Supposition.Pass
    end)
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

# stand-in cloud model for the logic tests (see sum.md)
# seasonal clouds: 1 at the July monsoon peak, 0 in January
cloudiness(k) = (1 + cos(2pi * (k - 7) / 12)) / 2
# ncfobs ~6 in July, ~28 in January
cloud_free_days(rng, k) = clamp(round(Int, 28 - 22 * cloudiness(k)) + rand(rng, -2:2), 1, 30)
# radiance factor: 1 at ncfobs = 30, 1 - depth at 0
dimming(ncf, depth) = 1 - depth * (1 - ncf / 30)
