abstract type PrimmeCStruct end

# Julia API

function Base.setindex!(r::Ref{T}, x, sym::Symbol) where T<:PrimmeCStruct
    p  = Base.unsafe_convert(Ptr{T}, r)
    pp = convert(Ptr{UInt8}, p)
    i  = findfirst(t -> t == sym, fieldnames(r[]))
    o  = fieldoffset(T, i)
    S = fieldtype(T, i)
    unsafe_store!(convert(Ptr{S}, pp + o), x)
    return x
end
