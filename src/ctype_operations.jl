abstract type PrimmeCStruct end

function Base.setindex!(r::Ref{T}, x, sym::Symbol) where T<:PrimmeCStruct
    p  = Base.unsafe_convert(Ptr{T}, r)
    pp = convert(Ptr{UInt8}, p)
    i  = findfirst(t -> t == sym, fieldnames(r[]))
    if i==0
        throw(IndexError("No such property $sym for type $T"))
    end
    o  = fieldoffset(T, i)
    S = fieldtype(T, i)
    unsafe_store!(convert(Ptr{S}, pp + o), x)
    return x
end

function unsafe_array_unwrap(xp, ldxp, blockSizep)
    ldx = unsafe_load(ldxp)
    blockSize = Int(unsafe_load(blockSizep))
    x = unsafe_wrap(Array, xp, (ldx, blockSize))
    return x
end

function unsafe_vector_unwrap(xp, szp)
    sz = Int(unsafe_load(szp))
    x = unsafe_wrap(Array, xp, (sz,))
    return x
end
