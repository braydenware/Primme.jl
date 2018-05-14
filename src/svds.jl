# matrix-vector product, y = a * x (or y = a^t * x), where
# (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
       # int *transpose, struct primme_svds_params *primme_svds, int *ierr);
const _A_ = Base.Ref{Any}()

function svd_matrixMatvec(xp, ldxp, yp, ldyp, blockSizep, trp, parp, ierrp)
    x = unsafe_array_unwrap(xp, ldxp, blockSizep)
    y = unsafe_array_unwrap(yp, ldyp, blockSizep)
    
    tr = unsafe_load(trp)
    par = unsafe_load(parp)

    if tr == 0
        A_mul_B!( view(y, 1:par.m, :), _A_[], view(x, 1:par.n, :))
    else
        Ac_mul_B!(view(y, 1:par.n, :), _A_[], view(x, 1:par.m, :))
    end
    unsafe_store!(ierrp, 0)
    return nothing
end
_fp_ = cfunction(svd_matrixMatvec, Void,
        (Ptr{Float64}, Ptr{Int}, Ptr{Float64}, Ptr{Int}, Ptr{Cint}, Ptr{Cint},
         Ptr{C_svds_params}, Ptr{Cint}))


function _svds(r::Ref{C_svds_params})
    m, n, k = r[].m, r[].n, r[].numSvals
    svals  = Vector{Float64}(k)
    svecs  = rand(Float64, m + n, k)
    rnorms = Vector{Float64}(k)

    err = ccall((:dprimme_svds, libprimme), Cint,
        (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{C_svds_params}),
         svals, svecs, rnorms, r)
    if err != 0
        warn("err = $err")
    end

    nConv = Int(r[].initSize)

    return reshape(svecs[r[].numOrthoConst*m + (1:(m*nConv))], m, nConv),
        svals,
        reshape(svecs[(r[].numOrthoConst + nConv)*m + r[].numOrthoConst*n + (1:(n*nConv))], n, nConv)
end

function svds(A::AbstractMatrix, k = 5; tol = 1e-12, maxBlockSize = 2k, debuglevel::Int = 0, method::Svds_operator = svds_op_AtA)
    r = svds_initialize()
    _A_[]            = A
    r[:m]            = size(A, 1)
    r[:n]            = size(A, 2)
    r[:matrixMatvec] = _fp_
    r[:numSvals]     = k
    r[:printLevel]   = debuglevel
    r[:eps]          = tol
    r[:maxBlockSize] = maxBlockSize
    r[:method]       = method
    if debuglevel > 0
        display_params(r)
    end
    out = _svds(r)
    if debuglevel > 0
        display_params(r)
    end
    return out
end
