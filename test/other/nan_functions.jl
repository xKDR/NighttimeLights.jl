@testset "count missing" begin
    for i in 1:10
        x = rand(10:30)
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x))
        missings = unique(rand(1:x,rand(1:x)))
        rad[missings] .= missing
        @test NighttimeLights.count_missing(rad) == length(missings)
    end
end

@testset "max_missing" begin
    for i in 1:10
        x = rand(10:30)
        rad = Array{Union{Float64, Missing}}(rand(20:100.0, x))
        max = findmax(rad)
        missings = rand(1:20)
        for j in 1:missings
            missing_index = rand(1:x)
            if missing_index == max[2]
                continue
            else
                rad[missing_index] = missing
            end
        end
        @test NighttimeLights.max_missing(rad) == max[1]
    end
end