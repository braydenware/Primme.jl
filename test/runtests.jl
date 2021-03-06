using Base.Test
using Primme

@testset "svds" begin
    @testset "svds m=$m, n=$n, k=$k" for n in [200, 400],
                                         m in [200, 400],
                                         k = [10,20],
                                         method = [Primme.svds_op_AAt, Primme.svds_op_AtA, Primme.svds_op_augmented]
        A = randn(m, n)
        svdPrimme = Primme.svds(A, k, method = method)
        svdLAPACK = svd(A)
        @test svdLAPACK[2][1:k] ≈ svdPrimme[2]
        @test abs.(svdLAPACK[1][:, 1:k]'svdPrimme[1]) ≈ eye(k)
    end
end

@testset "eigs" begin
    @testset "eigs n=$n, nev=$nev, which=$which, method=$method" for n in [20, 40],
                                   nev = [1,2],
                                   which=[:SR, :LR],
                                   method = [nothing, Primme.JDQMR, Primme.GD]
        A = randn(n, n)
        A = (A+A')
        vals, vecs = Primme.eigs(A; nev=nev, which=which, method = method)
        vals2, vecs2 = eigs(A; which=which, nev=nev)

        p = sortperm(vals)
        p2 = sortperm(vals2)

        vals = vals[p]
        vecs = vecs[:, p]

        vals2 = vals2[p2]
        vecs2 = vecs2[:, p2]
        @test vals ≈ vals2
        @test abs.(vecs2'vecs) ≈ eye(nev)
    end
end