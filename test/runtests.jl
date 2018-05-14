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
    @testset "eigs n=$n, nev=$nev, method=$method" for n in [20, 40], 
                                   nev = [1,2],
                                   method = [nothing, Primme.JDQMR, Primme.GD]
        A = randn(n, n)
        A = (A+A')
        eigPrimme = Primme.eigs(A; nev=nev, method = method)
        eigLAPACK = eigs(A; which=:SR, nev=nev)
        @test eigLAPACK[1] ≈ eigPrimme[1]
        @test abs.(eigLAPACK[2]'eigPrimme[2]) ≈ eye(nev)
    end
end