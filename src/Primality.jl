module Primality

include("Arithmetic.jl")

export fermat_test, miller_rabin_test, is_prime, generate_prime,
       is_primitive_root, generate_primitive_root

# Fermat Test
# =============================================================================
"""
    fermat_test(n)
Perform a Fermat test against integer `n`.

Return: `indicator::Bool`, true if `n` passed the test, otherwise `false`.
"""
function fermat_test(n::BigInt)
    a = BigInt(rand(2:n-1))
    result = Arithmetic.fast_exponentiation(a, n-1, n) == 1
    return result
end

fermat_test(n::Integer) = fermat_test(BigInt(n))

# Miller-Rabin Test
# =============================================================================
"""
    miller_rabin_test(n)
Perform a discrete round of Miller-Rabin testing. This function does not
protect or validate the input, instead relying on the other module components
to do so.

Return: `indicator::Bool`, true if `n` passed the test, otherwise false.
"""
function miller_rabin_test(n::BigInt)
    ^ⁿ = Arithmetic.fexmod(n)

    # I saw this on GitHub
    s = trailing_zeros(n-1)
    d = (n - 1) >>> s

    a = BigInt(rand(2:n-1))
    while Arithmetic.cgcd(a, n) != 1
        a = BigInt(rand(2:n-1))
    end

    # Condition 1: a^d % m
    if a ^ⁿ d == 1
        return true
    end

    # Condition 2: a^(2ʳ * d), for some r ∈ [s]
    for r ∈ 0:s
        e = Arithmetic.fast_exponentiation(2, r) * d
        if a ^ⁿ e == n-1
            return true
        end
    end

    return false
end

miller_rabin_test(n::Integer) = miller_rabin_test(BigInt(n))

# is_prime
# =============================================================================
"""
    is_prime(n)

Use a combination of determinism and probabilistic approaches to say whether
`n` is likely to be prime or not.

Return: `indicator::Bool`, true if `n` is likely prime, false otherwise.
"""
function is_prime(n::BigInt)
    # First, check if `n` is divisible by a known small prime
    ℙ = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
        67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137,
        139, 149, 151, 157, 163, 167, 173, 179, 181]

    for p in ℙ
        if n % p == 0
            return false
        end
    end

    # Test `n` against a regimen of Fermat and 3 rounds of Miller-Rabin
    if !fermat_test(n)
        return false
    end

    for _ = 1:3
        if !miller_rabin_test(n)
            return false
        end
    end

    # Since `n` has passed all the tests, it is likely to be prime.
    return true
end

is_prime(n::Integer) = is_prime(BigInt(n))

# Generate Primes
# =============================================================================
"""
    generate_n_bit_number(num_bits)
Generate a `num_bits`-bit number.

Return: `n::BigInt`
"""
function generate_n_bit_number(num_bits::Integer)
    n = BigInt(0)
    for i in 1:num_bits
        n = n << 1
        n = n | rand(0:1)
    end
    return BigInt(n)
end

"""
    generate_prime(num_bits)
Generate a `num_bits`-bit number; continue generating the number until you get
one that passes the test suite.

Return: `p::BigInt`, a prime number
"""
function generate_prime(num_bits::Integer)
    candidate = generate_n_bit_number(num_bits)

    while !is_prime(candidate)
        candidate = generate_n_bit_number(num_bits)
    end

    return candidate
end

end # module Primality
