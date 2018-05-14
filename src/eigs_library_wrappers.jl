free(r::Ref{C_params}) = ccall((:primme_free, libprimme), Void, (Ptr{C_params},), r)

function initialize()
    r = Ref{C_params}()
    ccall((:primme_initialize, libprimme), Void, (Ptr{C_params},), r)
    finalizer(r, free)
    return r
end

function set_method!(r::Ref{C_params}, method::PresetMethod)
    ret = ccall((:primme_set_method, libprimme), Cint, (PresetMethod, Ptr{C_params}), method, r)
    if ret!=0
        error("Failed to setmethod")
    end
end

display_params(r::Ref{C_params}) = ccall((:primme_display_params, libprimme), Void, (C_params,), r[])
