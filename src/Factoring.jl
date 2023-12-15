module Factoring

include("Arithmetic.jl")
include("Primality.jl")

export ϱ, rho, P, p_minus_one, factorize

# Rho Method
# =============================================================================
"""
    ϱ(n)
Extract a factor from `n` using the Pollard rho method.

Return: `p::Integer`, a factor of `n`;
Return: `1`, if no factor can be found.
"""
function ϱ(n::BigInt)
    # Often +1 or -1 alone will fail, so let's try both
    gₐ(t) = (Arithmetic.fast_exponentiation(t, 2) + 1) % n
    xₐ = BigInt(2)
    yₐ = BigInt(2)
    dₐ = BigInt(1)

    gₛ(t) = (Arithmetic.fast_exponentiation(t, 2) + 1) % n
    xₛ = BigInt(2)
    yₛ = BigInt(2)
    dₛ = BigInt(1)

    branch = 1
    # Can't let this run forever...
    for _ in 1:100_000
        if branch == 1
            xₐ = gₐ(xₐ)
            yₐ = gₐ(gₐ(yₐ))
            dₐ = BigInt(Arithmetic.cgcd(abs(xₐ - yₐ), n))
            branch = -1 * branch
        else
            xₛ = gₛ(xₛ)
            yₛ = gₛ(gₛ(yₛ))
            dₛ = BigInt(Arithmetic.cgcd(abs(xₛ - yₛ), n))
            branch = -1 * branch
        end
    end

    if dₐ != 1 && dₐ != n
        return dₐ
    end

    if dₛ != 1 && dₛ != n
        return dₛ
    end

    return 1
end

ϱ(n::Integer) = ϱ(BigInt(n))
rho(n::Integer) = ϱ(BigInt(n))

# P-1 Method
# =============================================================================
"""
    P(n)
Extract a single factor from `n` using Pollard's P-1 method.

Return: `p::Integer`, a factor of `n`;
Return: `1`, if no factor can be found.
"""
function P(n::BigInt)
    a = BigInt(2)
    ^ᵖ = Arithmetic.fexmod(n)

    for j in 2:100
        a = a ^ᵖ j
    end

    d = Arithmetic.cgcd(a-1, n)
    if 1 < d && d < n
        return d
    end

    # No luck...
    return 1
end

P(n::Integer) = P(BigInt(n))
p_minus_one(n::Integer) = P(BigInt(n))

# Sieve Method
# =============================================================================
"""
    sieve(n)
Use a slightly smarter Sieve of Eratosthenes approach to get a factor `p` out
of a particularly stubborn number. This is the fallback method when rho and
P-1 are not successful, so that the factorization is guaranteed to terminate.

Return: `p::BigInt`, a factor of `n`.
"""
function sieve(n::BigInt)
    # The sieve itself
    target = BigInt(floor(sqrt(n)))
    σ = ones(Bool, target)
    σ[1] = false

    # Sieve out known primes
    ℙ = BigInt[2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59,
        61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137,
        139, 149, 151, 157, 163, 167, 173, 179, 181]
    for p in ℙ
        if n % p == 0
            return p
        end

        σ[2p:p:end] .= false
    end

    # 191 is the next prime, and primes are all odd, so we can just step by 2
    println(">> Building primes list...")
    for i in 191:2:target
        if σ[i]
            σ[2i:i:end] .= false
        end
    end

    # Now we have a sieve, so we can filter down to just the primes...
    primes = filter(x -> σ[x], 1:target)
    println(">> Primes list is ready.")

    for p in primes
        if n % p == 0
            return p
        end
    end

    # The sieve is exhausted so n must be prime
    return 1
end

sieve(n::Integer) = sieve(BigInt(n))

# Factorization
# =============================================================================
"""
    get_factor(n)
Internal function. Get the next factor for `n`, using rho, P-1, or the sieve
if necessary.

Return: `p::BigInt`, a factor of `n`.
"""
function get_factor(n::BigInt)
    # Start with the rho test
    pᵣ = ϱ(n)
    println(">> ϱ is pᵣ=$pᵣ")
    if pᵣ != 1
        return pᵣ
    end

    # Fallback to the P-1 test
    pₚ = P(n)
    if pₚ != 1
        return pₚ
    end

    # If we can't get a result from either of those, and n is very large, we
    # may hit a memory constraint. So, if the number is bigger than a 64-bit
    # integer, we just evaluate the likely primacy and rely on that instead.
    MAX64INT = typemax(Int64)
    if n > MAX64INT
        if Primality.is_prime(n)
            return n
        end
    end

    # Sieve for a guaranteed factor
    pₛ = sieve(n)
    if pₛ != 1
        return pₛ
    end

    # Otherwise, `n` is prime
    return n
end

"""
    factorize(n)
Using all various methods available in these modules, factor `n` into
components.

Return: `F::BigInt[]`, an Array/Vector of factors of `n`. Factors appear in `F`
exactly as many times as in `n`. So `prod(F) == n` for any `n` in the naturals.
"""
function factorize(n::BigInt)
    println(">> factoring n=$n")
    p = get_factor(n)

    println(">> first factor is p=$p")
    R = n ÷ p

    if R == 1
        return [p]
    end

    return append!(factorize(p), factorize(R))
end

factorize(n::Integer) = factorize(BigInt(n))

end # module Factoring
