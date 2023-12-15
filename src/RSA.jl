module RSA

include("Arithmetic.jl")

# KEYS
# =============================================================================
"""
    generate_keys(p, q)
Given two primes `p` and `q`, use them as the basis to create a public/private
key pair under the RSA scheme.

Return: (`n::BigInt`, `public_key::BigInt`, `private_key::BigInt`), the basis
and key pair
"""
function generate_keys(p::BigInt, q::BigInt)
    n = p * q

    ϕₙ = abs((p-1) * (q-1)) ÷ Arithmetic.cgcd(p-1, q-1)
    e = BigInt(rand(2:ϕₙ-1))
    d = Arithmetic.modular_inverse(e, p)
    # Using the EEA to generate the inverse means sometimes you get a negative
    # number, so we make sure it's positive with this addition
    d = (d + ϕₙ) % ϕₙ

    return (n, e, d)
end

# MESSAGES
# =============================================================================
"""
    encrypt(message, receiver_public_key, n)
Encrypt a message using the RSA scheme.

Return: `cyphertext::BigInt`, the encrypted message
"""
function encrypt(message::BigInt, receiver_public_key::BigInt, n::BigInt)
    ^ⁿ = Arithmetic.fexmod(n)

    cyphertext = message ^ⁿ receiver_public_key
    return cyphertext
end

encrypt(m::Integer, r::Integer, n::Integer) = encrypt(BigInt(m), BigInt(r), BigInt(n))

"""
    decrypt(cyphertext, receiver_secret_key, n)
Decrypt a message using the RSA scheme.

Return: `message::BigInt`, the decrypted message (as a number).
"""
function decrypt(message:BigInt, receiver_secret_key::BigInt, n::BigInt)
    ^ⁿ = Arithmetic.fexmod(n)

    message = cyphertext ^ⁿ receiver_secret_key
    return message
end

decrypt(m::Integer, r::Integer, n::Integer) = decrypt(BigInt(m), BigInt(r), BigInt(n))

end
