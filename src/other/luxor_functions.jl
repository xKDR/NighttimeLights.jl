# These are functions and structs taken from Luxor.jl: https://github.com/JuliaGraphics/Luxor.jl
# We couldn't use Luxor.jl directly since it doesn't compile on Arm64 so far. 

struct Point
    x::AbstractFloat
    y::AbstractFloat
end

mutable struct BoundingBox
    corner1::Point
    corner2::Point
 end

function BoundingBox(pointlist::Array{Point, 1})
    lowx, lowy = pointlist[1].x, pointlist[1].y
    highx, highy = pointlist[end].x, pointlist[end].y
    for p in pointlist
        p.x < lowx  && (lowx  = p.x)
        p.y < lowy  && (lowy  = p.y)
        p.x > highx && (highx = p.x)
        p.y > highy && (highy = p.y)
    end
    return [Point(lowx, lowy), Point(highx, highy)]
end

function det3p(q1::Point, q2::Point, p::Point)
    (q1.x - p.x) * (q2.y - p.y) - (q2.x - p.x) * (q1.y - p.y)
end

function isinside(p::Point, pointlist::Array{Point, 1};
    allowonedge::Bool=false)
c = false
@inbounds for counter in eachindex(pointlist)
    q1 = pointlist[counter]
    # if reached last point, set "next point" to first point
    if counter == length(pointlist)
        q2 = pointlist[1]
    else
        q2 = pointlist[counter + 1]
    end
    if q1 == p
        allowonedge || error("isinside(): VertexException a")
        continue
    end
    if q2.y == p.y
        if q2.x == p.x
            allowonedge || error("isinside(): VertexException b")
            continue
        elseif (q1.y == p.y) && ((q2.x > p.x) == (q1.x < p.x))
            allowonedge || error("isinside(): EdgeException")
            continue
        end
    end
    if (q1.y < p.y) != (q2.y < p.y) # crossing
        if q1.x >= p.x
            if q2.x > p.x
                c = !c
            elseif ((det3p(q1, q2, p) > 0) == (q2.y > q1.y))
                c = !c
            end
        elseif q2.x > p.x
            if ((det3p(q1, q2, p) > 0) == (q2.y > q1.y))
                c = !c
            end
        end
    end
end
return c
end