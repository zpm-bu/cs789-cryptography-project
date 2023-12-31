using Test

# The following have been verified as prime by checking against Wolfram|Alpha
p₁₆ = Int16(26893)
p₃₂ = Int32(1973705399)
p₆₄ = Int64(1444191769131458227)

q₁₆ = Int16(2131)
q₃₂ = Int32(76420979)
q₆₄ = Int64(8668330227278800147)

e₁₆ = Int16(30964)
e₃₂ = Int32(1575944192)
e₆₄ = Int64(8720682644193752797)

# ARITHMETIC MODULE
# =============================================================================
include("../src/Arithmetic.jl")

# Because the `fex` function is internal and type-restricted, there isn't too
# much to test here
function test_fex()
    @testset "`fex` function tests" begin
        @test Arithmetic.fex(BigInt(0), BigInt(0), BigInt(0)) == 1 # Should just return Y
        @test Arithmetic.fex(BigInt(1), BigInt(1), BigInt(1)) == 0 # x % 1 is always 0
        @test Arithmetic.fex(BigInt(p₃₂), BigInt(2), BigInt(q₃₂)) == 29514085
    end
end
test_fex()

function test_fast_exponentiation()
    @testset "`fast_exponentiation` function tests" begin
        @test Arithmetic.fast_exponentiation(p₁₆, 2) == 723233449
        @test Arithmetic.fast_exponentiation(p₁₆, q₁₆, 3) == 1
        @test Arithmetic.fast_exponentiation(p₃₂, 2) == 3895513002041749201
        @test Arithmetic.fast_exponentiation(p₃₂, q₃₂, p₁₆) == 2062
        @test Arithmetic.fast_exponentiation(p₆₄, 2) == 2085689866027051139818748391445983529
        @test Arithmetic.fast_exponentiation(p₆₄, q₆₄, p₁₆*q₁₆) == 12418
    end
end
test_fast_exponentiation()

function test_cgcd()
    @testset "`cgcd` function tests" begin
        @test Arithmetic.cgcd(e₁₆, e₃₂) == 4
        @test Arithmetic.cgcd(71, 142) == 71
        @test Arithmetic.cgcd(p₆₄, q₆₄) == 1
    end
end
test_cgcd()

function test_egcd()
    @testset "`egcd` function tests" begin
        @test Arithmetic.egcd(e₁₆, e₃₂) == (-151262955, 2972, 4)
        @test Arithmetic.egcd(71, 142) == (1, 0, 71)
        @test Arithmetic.egcd(p₆₄, q₆₄) == (-3224448959376806939, 537211034307623382, 1)
    end
end
test_egcd()

function test_modular_inverse()
    @testset "`modular_inverse` function tests" begin
        @test Arithmetic.modular_inverse(7, 31) == 9
        @test_throws "Cannot calculate modular inverse" Arithmetic.modular_inverse(2, 14)
        @test_throws "Cannot calculate modular inverse" Arithmetic.modular_inverse(0, 14)
    end
end
test_modular_inverse()

function test_discrete_log()
    @testset "`baby_step_giant_step` function tests" begin
        @test Arithmetic.baby_step_giant_step(3, 2, 29) == 17
        @test Arithmetic.baby_step_giant_step(2543202, 795304, 9530657) == 3929680
    end
end
test_discrete_log()

# FACTORING MODULE
# =============================================================================
include("../src/Factoring.jl")

function test_rho()
    @testset "`rho` function tests" begin
        @test_throws DivideError Factoring.ϱ(0)
        @test Factoring.ϱ(1) == 1
        @test Factoring.ϱ(-1) == 1

        r = Factoring.ϱ(2 * q₁₆)
        @test r == 2 || r == q₁₆
    end
end
test_rho()

function test_P()
    @testset "`P` function tests, Pollard P-1" begin
        @test_throws DivideError Factoring.P(0)
        @test Factoring.P(1) == 1
        @test_throws "not allowed" Factoring.P(-1) == -1

        r = Factoring.P(2 * p₁₆)
        @test r == 2 || r == p₁₆
    end
end
test_P()

function test_seive()
    @testset "`sieve` function tests" begin
        @test_throws BoundsError Factoring.sieve(0)
        @test Factoring.sieve(1) == 1
        @test_throws DomainError Factoring.sieve(-1)
        @test Factoring.sieve(p₁₆ * 6701) == 6701
    end
end
test_seive()

function test_factorize()
    @testset "`factorize` function tests" begin
        @test 3469 in Factoring.factorize(7919 * 3469)
        @test p₃₂ in Factoring.factorize(3709 * BigInt(p₃₂))
    end
end
test_factorize()

# PRIMALITY
# =============================================================================
include("../src/Primality.jl")

function test_fermat()
    @testset "`fermat_test` function tests" begin
        # Works for primes
        @test fermat_test(13) == true
        @test fermat_test(17) == true
        # Edges
        @test_throws Error fermat_primes(0)
        @test_throws Error fermat_primes(1)
        @test_throws Error fermat_primes(-1)
    end
end
