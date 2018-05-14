# http://www.cs.wm.edu/~andreas/software/doc/svdsc.html
function svds_initialize()
    r = Ref{C_svds_params}()
    ccall((:primme_svds_initialize, libprimme), Void, (Ptr{C_svds_params},), r)
    finalizer(r, free)
    return r
end

display_params(r::Ref{C_svds_params}) = ccall((:primme_svds_display_params, libprimme), Void, (C_svds_params,), r[])
free(r::Ref{C_svds_params}) = ccall((:primme_svds_free, libprimme), Void, (Ptr{C_svds_params},), r)
