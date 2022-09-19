"""
```julia
dates = collect(Date(2012,4):Month(1):Date(2022, 06))
timestamps = yearmon.(dates)
```
"""
function yearmon(x)                                                                                                                        
    function two_digit_month(x)                                                                                                                
        if length(string(month(x))) == 1                                                                                                       
            return "0" * string(month(x))                                                                                                      
        else                                                                                                                                   
            return string(month(x))                                                                                                            
        end                                                                                                                                    
    end
    parse(Int, string(year(x)) * two_digit_month(x))                                                                                           
end