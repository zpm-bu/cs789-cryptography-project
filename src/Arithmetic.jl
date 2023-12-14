module Arithmetic

export fast_exponentiation, fexmod, cgcd, egcd, modular_inverse, dlog,
       baby_step_giant_step

# Fast Exponentiation
# =============================================================================
"""
    fex(x, e[, m])
Internal function. Do xᵉ % m. Does not check typing or edge cases because it is
internal.

Return: `Y::BigInt`, the value calculated
"""
function fex(x::BigInt, e::BigInt, m::BigInt)
    Y = BigInt(1)

    while e != 0
        if iseven(e)
            x = x * x % m
            e = e >>> 1
        else
            Y = Y * x % m
            e = e - 1
        end
    end

    return Y
end

function fex(x::BigInt, e::BigInt)
    Y = BigInt(1)

    while e != 0
        if iseven(e)
            x = x * x
            e = e >>> 1
        else
            Y = Y * x
            e = e - 1
        end
    end

    return Y
end

"""
    fast_exponentiation(x, e[, m])
Raise `x` to power `e`, with or without modulus `m`. Uses the fast
exponentiation algorithm, so it takes less memory and recursion depth than
naive exponentiation.

Return: `Y::BigInt`, the value calculated
"""
function fast_exponentiation(x::Integer, e::Integer, m::Integer)
    if e < 0
        error("Negative exponent e=$e is not allowed in fast exponentiation")
    end
    if m < 0
        error("Negative modulus m=$m is not allowed in fast exponentiation")
    end

    return fex(BigInt(x), BigInt(e), BigInt(m))
end

function fast_exponentiation(x::Integer, e::Integer)
        if e < 0
            error("Negative exponent e=$e is not allowed in fast exponentiation")
        end
        if m < 0
            error("Negative modulus m=$m is not allowed in fast exponentiation")
        end

        return fex(BigInt(x), BigInt(e))
end

"""
    fexmod(m)
A higher-order function which takes the modulus `m` and creates an anonymous
function appropriate for binding to an operator.

Return: `λₘ::Function`, which takes two arguments and performs exponentiation
modulo `m`.
"""
fexmod(m) = (x, e) -> fast_exponentiation(x, e, m)

# Cryptography GCD
# =============================================================================
"""
    cgcd(a, b)
Custom reimplementation of the GCD function. Uses recursion rather than a loop
because of how concise it is.

Return: `x::BigInt`, the gcd of `a` and `b`.
"""
function cgcd(a::BigInt, b::BigInt)
    if b == 0
        return a
    end

    r = a % b
    return cgcd(b, r)
end

# Extended GCD
# =============================================================================
"""
    egcd(a, b)
Perform the extended GCD algorithm and find the coefficients such that
c₁a + c₂b = gcd(`a`, `b`). Uses cgcd instead of `Base.gcd`.

Return: `(c₁::BigInt, c₂::BigInt, g::BigInt)`, where `g` = gcd(`a`, `b`).
"""
function egcd(a, b)
    if b == 0
        return (1, 0, a)
    end

    r = a % b
    c₁, c₂, G = egcd(b, r)
    return (c₂, c₁ - (a ÷ b) * c₂, G)
end

# Modular Inverse
# =============================================================================
"""
    modular_inverse(a, p)
For element a ∈ ℤₚ, return the inverse element a⁻¹. Uses the extended GCD
algorithm to find quick inversion.

Return: `a⁻¹`, the mutiplicative inverse of a in the group.
"""
function modular_inverse(a, p)
    if cgcd(a, p) != 1
        error("Cannot calculate modular inverse because a=$a and p=$p are not mutually prime.")
    end

    a⁻¹, _, _ = egcd(a, p)

    return a⁻¹
end

# Discrete Log
# =============================================================================
"""
    baby_step_giant_step(α, β, m)
generator for G. Then there necessarily exists some `k` such that aᵏ = β for
any β ∈ G. This function finds `k`.

Return: `k::Integer`, the power to which α needs to be raised to get β from the
group.
"""
function baby_step_giant_step(α, β, m)
    m = ceil(sqrt(n))
    ⋆ = fexmod(n)
    α⁻ᵐ = modular_inverse(α ⋆ m, n)
    steps = Dict()

    # Baby steps
    for j ∈ 1:m-1
        αʲ = α ⋆ j
        steps[αʲ] = j
    end

    # Giant steps
    α⁽⁻ᵐ⁾ⁱ = 1
    for i in 0:m-1
        if haskey(steps, α⁽⁻ᵐ⁾ⁱ)
            j = steps[α⁽⁻ᵐ⁾ⁱ]
            return i * m + j
        end

        α⁽⁻ᵐ⁾ⁱ = (α⁽⁻ᵐ⁾ⁱ * a⁻ᵐ) % n
    end

    # No log found...
    return nothing
end

dlog(base::Integer, modulus::Integer) = x -> baby_step_giant_step(base, x, modulus)

end # module Arithmetic
