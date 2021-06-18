@testset "testing size" begin
for i in 1:10
    testcube = rand(1:10, 10, 10, 10)
    test_sparsecube = NighttimeLights.sparse_cube(testcube)
    @test size(test_sparsecube) == (10, 10, 10) 
end
end