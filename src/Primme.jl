module Primme

const libprimme = joinpath(dirname(@__FILE__()), "../deps/primme/lib/libprimme")

const PRIMME_INT = Int # might be wrong. Should be detected.

include("ctype_operations.jl")
include("eigs_types.jl")
include("eigs_library_wrappers.jl")
include("eigs.jl")

include("svds_types.jl")
include("svds_library_wrappers.jl")
include("svds.jl")

end # module
