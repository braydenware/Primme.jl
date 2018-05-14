module Primme

const libprimme = joinpath(dirname(@__FILE__()), "../deps/primme/lib/libprimme")

const PRIMME_INT = Int # might be wrong. Should be detected.

include("ctype_operations.jl")
include("eigs.jl")
include("svds.jl")

end # module
