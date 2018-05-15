using Base.Test
using Primme

function diag_precond!(y, B, x, shifts)
    d = diag(B)
    for i in 1:size(y, 2)
        y[:, i] = x[:, i]./(d-shifts[i])
    end
end

@testset "eigs" begin
    @testset "eigs n=$n, nev=$nev, ε=$ε, which=$which, method=$method" for 
                    n in [16, 64, 256, 512, 1024],
                    nev = [1],
                    ε = [0., 0.01, 0.1],
                    which=[:SR],
                    method = [nothing, Primme.JDQMR, Primme.GD]

        f = 5/n
        x = sort!(rand(n))
        y = ε/2*sprandn(n, n, f)
        A = spdiagm(x)+y+y'

        println("n=$n, method=$method, which=$which")
        @time vals, vecs = Primme.eigs(A; precond=diag_precond!, nev=nev, which=which, method = method)
        @time vals2, vecs2 = eigs(A; which=which, nev=nev)
        println("-")

        # repermute vals and vecs 
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
