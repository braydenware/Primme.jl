@enum(Svds_target,
    svds_largest,
    svds_smallest,
    svds_closest_abs
)

@enum(Svds_operator,
    svds_op_none,
    svds_op_AtA,
    svds_op_AAt,
    svds_op_augmented
)

struct C_svds_stats <: PrimmeCStruct
    numOuterIterations::PRIMME_INT
    numRestarts::PRIMME_INT
    numMatvecs::PRIMME_INT
    numPreconds::PRIMME_INT
    numGlobalSum::PRIMME_INT         # times called globalSumR
    volumeGlobalSum::PRIMME_INT      # number of SCALARs reduced by globalSumReal
    numOrthoInnerProds::Cdouble      # number of inner prods done by Ortho
    elapsedTime::Cdouble
    timeMatvec::Cdouble              # time expend by matrixMatvec
    timePrecond::Cdouble             # time expend by applyPreconditioner
    timeOrtho::Cdouble               # time expend by ortho
    timeGlobalSum::Cdouble           # time expend by globalSumReal
end

struct C_svds_params <: PrimmeCStruct
    # Low interface: configuration for the eigensolver
    primme::C_params # Keep it as first field to access primme_svds_params from
                          # primme_params
    primmeStage2::C_params # other primme_params, used by hybrid

    # Specify the size of the rectangular matrix A
    m::PRIMME_INT # number of rows
    n::PRIMME_INT # number of columns

    # High interface: these values are transferred to primme and primmeStage2 properly
    matrixMatvec::Ptr{Void}
    # void (*matrixMatvec)
    #    (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
    #     int *transpose, struct primme_svds_params *primme_svds, int *ierr);
    applyPreconditioner::Ptr{Void}
    # void (*applyPreconditioner)
       # (void *x, PRIMME_INT *ldx, void *y, PRIMME_INT *ldy, int *blockSize,
        # int *transpose, struct primme_svds_params *primme_svds, int *ierr);

    # Input for the following is only required for parallel programs
    numProcs::Cint
    procID::Cint
    mLocal::PRIMME_INT
    nLocal::PRIMME_INT
    commInfo::Ptr{Void}
    globalSumReal::Ptr{Void}
    # void (*globalSumReal)
       # (void *sendBuf, void *recvBuf, int *count,
        # struct primme_svds_params *primme_svds, int *ierr);

    # Though primme_svds_initialize will assign defaults, most users will set these
    numSvals::Cint
    target::Svds_target
    numTargetShifts::Cint  # For primme_svds_augmented method, user has to
    targetShifts::Ptr{Cdouble} # make sure  at least one shift must also be set
    method::Svds_operator # one of primme_svds_AtA, primme_svds_AAt or primme_svds_augmented
    methodStage2::Svds_operator # hybrid second stage method; accepts the same values as method */

    # These pointers are not for users but for d/zprimme_svds function
    intWorkSize::Cint
    realWorkSize::Csize_t
    intWork::Ptr{Cint}
    realWork::Ptr{Void}

    # These pointers may be used for users to provide matrix/preconditioner
    matrix::Ptr{Void}
    preconditioner::Ptr{Void}

    # The following will be given default values depending on the method
    locking::Cint
    numOrthoConst::Cint
    aNorm::Cdouble
    eps::Cdouble

    precondition::Cint
    initSize::Cint
    maxBasisSize::Cint
    maxBlockSize::Cint
    maxMatvecs::PRIMME_INT
    iseed::NTuple{4,PRIMME_INT}
    printLevel::Cint
    outputFile::Ptr{Void}
    stats::C_svds_stats

    monitorFun::Ptr{Void}
    # void (*monitorFun)(void *basisSvals, int *basisSize, int *basisFlags,
       # int *iblock, int *blockSize, void *basisNorms, int *numConverged,
       # void *lockedSvals, int *numLocked, int *lockedFlags, void *lockedNorms,
       # int *inner_its, void *LSRes, primme_event *event, int *stage,
       # struct primme_svds_params *primme_svds, int *err);
    monitor::Ptr{Void}
end
