using Documenter
using NighttimeLights

DocMeta.setdocmeta!(NighttimeLights, :DocTestSetup, :(using NighttimeLights); recursive=true)
makedocs(;
    modules=[NighttimeLights],
    authors="Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas",
    repo="https://github.com/xKDR/NighttimeLights.jl/blob/{commit}{path}#{line}",
    sitename="NighttimeLights.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/xKDR/NighttimeLights.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Basic concepts" => "concepts.md",
        "Polygons and shapefiles"=> "polygons.md",
        "Data Cleaning"=> "data_cleaning.md",
        "Tutorial" =>"tutorial.md",
    ],
)

deploydocs(;
    repo="github.com/xKDR/NighttimeLights.jl",
    target = "build",
    devbranch="main"
)
