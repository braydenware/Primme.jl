@enum(Target,
    smallest,        # leftmost eigenvalues */
    largest,         # rightmost eigenvalues */
    closest_geq,     # leftmost but greater than the target shift */
    closest_leq,     # rightmost but less than the target shift */
    closest_abs,     # the closest to the target shift */
    largest_abs      # the farthest to the target shift */
)

@enum(Init,         # Initially fill up the search subspace with: */
    init_default,
    init_krylov, # a) Krylov with the last vector provided by the user or random */
    init_random, # b) just random vectors */
    init_user    # c) provided vectors or a single random vector */
)

@enum(Projection,
    proj_default,
    proj_RR,          # Rayleigh-Ritz */
    proj_harmonic,    # Harmonic Rayleigh-Ritz */
    proj_refined      # refined with fixed target */
)
const C_projection_params = Projection

@enum(Restartscheme,
    thick,
    dtr
)

struct C_restarting_params <: PrimmeCStruct
    scheme::Restartscheme
    maxPrevRetain::Cint
end

struct JD_projectors
    LeftQ::Cint
    LeftX::Cint
    RightQ::Cint
    RightX::Cint
    SkewQ::Cint
    SkewX::Cint
end

@enum(Convergencetest,
    full_LTolerance,
    decreasing_LTolerance,
    adaptive_ETolerance,
    adaptive
)

struct C_correction_params <: PrimmeCStruct
    precondition::Cint
    robustShifts::Cint
    maxInnerIterations::Cint
    projectors::JD_projectors
    convTest::Convergencetest
    relTolBase::Cdouble
end

struct C_stats <: PrimmeCStruct
    numOuterIterations::PRIMME_INT
    numRestarts::PRIMME_INT
    numMatvecs::PRIMME_INT
    numPreconds::PRIMME_INT
    numGlobalSum::PRIMME_INT         # times called globalSumReal
    volumeGlobalSum::PRIMME_INT      # number of SCALARs reduced by globalSumReal
    numOrthoInnerProds::Cdouble      # number of inner prods done by Ortho
    elapsedTime::Cdouble
    timeMatvec::Cdouble              # time expend by matrixMatvec
    timePrecond::Cdouble             # time expend by applyPreconditioner
    timeOrtho::Cdouble               # time expend by ortho
    timeGlobalSum::Cdouble           # time expend by globalSumReal
    estimateMinEVal::Cdouble         # the leftmost Ritz value seen
    estimateMaxEVal::Cdouble         # the rightmost Ritz value seen
    estimateLargestSVal::Cdouble     # absolute value of the farthest to zero Ritz value seen
    maxConvTol::Cdouble              # largest norm residual of a locked eigenpair
    estimateResidualError::Cdouble   # accumulated error in V and W
end

struct C_params <: PrimmeCStruct

    # The user must input at least the following two arguments
    n::PRIMME_INT
    matrixMatvec::Ptr{Void}
    # void (*matrixMatvec)
       # ( void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
         # struct primme_params *primme, int *ierr);

    # Preconditioner applied on block of vectors (if available)
    applyPreconditioner::Ptr{Void}
    # void (*applyPreconditioner)
       # ( void *x, PRIMME_INT *ldx,  void *y, PRIMME_INT *ldy, int *blockSize,
         # struct primme_params *primme, int *ierr);

    # Matrix times a multivector for mass matrix B for generalized Ax = xBl
    massMatrixMatvec::Ptr{Void}
    # void (*massMatrixMatvec)
       # ( void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
         # struct primme_params *primme, int *ierr);

    # input for the following is only required for parallel programs */
    numProcs::Cint
    procID::Cint
    nLocal::PRIMME_INT
    commInfo::Ptr{Void}
    globalSumReal::Ptr{Void}
    # void (*globalSumReal)
       # (void *sendBuf, void *recvBuf, int *count, struct primme_params *primme,
        # int *ierr );

    # Though Initialize will assign defaults, most users will set these
    numEvals::Cint
    target::Target
    numTargetShifts::Cint             # For targeting interior epairs,
    targetShifts::Ptr{Cdouble}        # at least one shift must also be set

    # the following will be given default values depending on the method
    dynamicMethodSwitch::Cint
    locking::Cint
    initSize::Cint
    numOrthoConst::Cint
    maxBasisSize::Cint
    minRestartSize::Cint
    maxBlockSize::Cint
    maxMatvecs::PRIMME_INT
    maxOuterIterations::PRIMME_INT
    intWorkSize::Cint
    realWorkSize::Csize_t
    iseed::NTuple{4,PRIMME_INT}
    intWork::Ptr{Cint}
    realWork::Ptr{Void}
    aNorm::Cdouble
    eps::Cdouble

    printLevel::Cint
    outputFile::Ptr{Void}

    matrix::Ptr{Void}
    preconditioner::Ptr{Void}
    ShiftsForPreconditioner::Ptr{Cdouble}
    initBasisMode::Init
    ldevecs::PRIMME_INT
    ldOPs::PRIMME_INT

    projectionParams::C_projection_params
    restartingParams::C_restarting_params
    correctionParams::C_correction_params
    stats::C_stats

    convTestFun::Ptr{Void}
    # void (*convTestFun)(double *eval, void *evec, double *rNorm, int *isconv, 
          # struct primme_params *primme, int *ierr);
    convtest::Ptr{Void}
    monitorFun::Ptr{Void}
    # void (*monitorFun)(void *basisEvals, int *basisSize, int *basisFlags,
       # int *iblock, int *blockSize, void *basisNorms, int *numConverged,
       # void *lockedEvals, int *numLocked, int *lockedFlags, void *lockedNorms,
       # int *inner_its, void *LSRes, primme_event *event,
       # struct primme_params *primme, int *err);
    monitor::Ptr{Void}
end

