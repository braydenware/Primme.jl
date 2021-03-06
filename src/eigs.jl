# matrix-vector product, y = a * x, where
# (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
       # struct primme_params *primme, int *ierr);
const _B_ = Base.Ref{Any}()

function _matvec(xp, ldxp, yp, ldyp, blockSizep, parp, ierrp)
    x = unsafe_array_unwrap(xp, ldxp, blockSizep)
    y = unsafe_array_unwrap(yp, ldyp, blockSizep)
    par = unsafe_load(parp)
    A_mul_B!( view(y, 1:par.n, :), _B_[], view(x, 1:par.n, :))
    unsafe_store!(ierrp, 0)
    return nothing
end

c_matvec = cfunction(_matvec, Void,
        (Ptr{Float64}, Ptr{Int}, Ptr{Float64}, Ptr{Int}, Ptr{Cint}, Ptr{C_params}, Ptr{Cint}))

function make_c_prevec(func::Function)
    function _prevec(xp, ldxp, yp, ldyp, blockSizep, parp, ierrp)
        x = unsafe_array_unwrap(xp, ldxp, blockSizep)
        y = unsafe_array_unwrap(yp, ldyp, blockSizep)
        par = unsafe_load(parp)
        shiftsp = par.ShiftsForPreconditioner
        shifts = unsafe_vector_unwrap(xp, blockSizep)
        func( view(y, 1:par.n, :), _B_[], view(x, 1:par.n, :), shifts)
        unsafe_store!(ierrp, 0)
        return nothing
    end
    return cfunction(_prevec, Void, (Ptr{Float64}, Ptr{Int}, Ptr{Float64}, Ptr{Int}, Ptr{Cint}, Ptr{C_params}, Ptr{Cint}))
end

function eigs(A::AbstractMatrix{Float64}; precond=nothing, debuglevel::Int=0, kwargs...)
    @assert issymmetric(A)
    n = size(A, 2)
    _B_[] = A

    if precond!=nothing
        c_prevec = make_c_prevec(precond)
    else
        c_prevec = nothing
    end

    r, evecs = setup_eigs(n; prevec = c_prevec, kwargs...)
    evals, evecs, resnorms, err, r = _eigs(r, evecs; debuglevel=debuglevel)
    if err!=0
        throw(error("Primme.eigs failed with error-code $err"))
    end

    stats = r[].stats
    nmults = stats.numMatvecs
    # extract details from r and stats
    return evals, evecs, nmults
end

function setup_eigs(n::Int, matvec=c_matvec;
                    prevec=nothing, maxiter::Int=300,
                    which::Symbol=:SR, v0::Matrix{Float64}=zeros(Float64, 0, 0),
                    nev::Int=6, tol::Float64 = eps(), ncv::Int = min(2nev, n-2),
                    debuglevel::Int=0, method=nothing)
    # if !(nev<=ncv<=n-2)
    #     throw(error("n=$n, nev=$nev, ncv=$ncv does not satisfy nev<=ncv<=n-2"))
    # end
    r = initialize()
    r[:n] = n
    r[:matrixMatvec] = matvec

    if prevec!=nothing
        r[:applyPreconditioner] = prevec
    end

    if !isempty(v0)
        evecs = rand(Float64, n, nev)
        r[:initBasisMode] = init_user

        k = min(nev, size(v0, 2))
        r[:initSize] = k
        evecs[:, 1:k] = v0[:, 1:k]
    else
        evecs = rand(Float64, n, nev)
    end

    if which==:SR
        r[:target] = smallest
    elseif which==:LR
        r[:target] = largest
    elseif which==:LM
        # throw(error("which=$which Not Implemented Yet"))
        r[:target] = largest_abs
        r[:targetShifts] = Base.unsafe_convert(Ptr{Float64}, Ref([0.]))
        r[:numTargetShifts] = 1
    elseif which==:SM
        # throw(error("which=$which Not Implemented Yet"))
        r[:target] = closest_abs
        r[:targetShifts] = Base.unsafe_convert(Ptr{Float64}, Ref([0.]))
        r[:numTargetShifts] = 1
    end

    r[:numEvals] = nev
    r[:printLevel] = debuglevel
    r[:eps] = tol
    r[:maxOuterIterations] = maxiter

    if method!=nothing
        set_method!(r, method)
    end

    if debuglevel > 0
        display_params(r)
    end
    return r, evecs
end

function _eigs(r::Ref{C_params}, evecs::Matrix{Float64}; debuglevel::Int=0)
    n, k = r[].n, r[].numEvals
    evals = Vector{Float64}(k)
    resnorms = Vector{Float64}(k)
    err = ccall((:dprimme, libprimme), Cint,
        (Ptr{Float64}, Ptr{Float64}, Ptr{Float64}, Ptr{C_params}), 
        evals, evecs, resnorms, r)
    if debuglevel > 0
        display_params(r)
    end
    return evals, evecs, resnorms, err, r
end
