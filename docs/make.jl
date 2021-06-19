using Documenter
push!(LOAD_PATH,"src/")
using NighttimeLights

DocMeta.setdocmeta!(NighttimeLights, :DocTestSetup, :(using NighttimeLights); recursive=true)

makedocs(;
    modules=[NighttimeLights],
    authors="Ayush Patnaik, Ajay Shah, Anshul Tayal, Susan Thomas",
    repo="https://github.com/ayushpatnaikgit/NighttimeLights.jl/blob/{commit}{path}#{line}",
    sitename="NighttimeLights.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ayushpatnaikgit.github.io/NighttimeLights.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ayushpatnaikgit/NighttimeLights.jl",
)
