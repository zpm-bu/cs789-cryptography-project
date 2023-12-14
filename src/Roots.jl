module PrimitiveRoots

include("Arithmetic.jl")
include("Factoring.jl")
include("Primality.jl")

# Primitive Roots
# # =============================================================================
"""
is_primitive_root(a, p)
By factoring `p`, determine if `a` is a primitive root of ℤₚ.

Return: `indicator::Bool`, true if `a` IS a primitive root, false otherwise.
"""
function is_primitive_root(a::BigInt, p::BigInt)
    # For cryptographic concerns, we only care about prime moduli
    if !Primality.is_prime(p)
        return false
    end

    ϕₚ = p - 1
    Q = Factoring.factorize(ϕₚ)

    for q ∈ Q
        if Arithmetic.fast_exponentiation(a, ϕₚ ÷ q, p) == 1
            return false
        end
    end

    return true
end

is_primitive_root(a::Integer, p::Integer) = is_primitive_root(BigInt(a), BigInt(p))

"""
generate_primitive_root(p)
Given a prime `p`, generate a primitive root for that `p`.

Return: `g::BigInt`, a generator and primitive root for ℤₚ
"""
function generate_primitive_root(p::BigInt)
    g = BigInt(rand(2:p-1))

    while !is_primitive_root(g, p)
        g = BigInt(rand(2:p-1))
    end

    return g
end

generate_primitive_root(p::Integer) = generate_primitive_root(BigInt(p))



end
