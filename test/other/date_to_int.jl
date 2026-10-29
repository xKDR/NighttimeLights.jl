@testset "yearmon" begin
    @property max_examples=CHEAP function formats_year_and_month(y = Data.Integers(1000, 9999), m = Data.Integers(1, 12), d = Data.Integers(1, 28))
        yearmon(Date(y, m, d)) == string(y) * lpad(m, 2, '0')
    end
end
