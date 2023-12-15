module ElGamal

include("Arithmetic.jl")

# Keys
# =============================================================================
"""
    generate_keys(p, g)
"""
function generate_keys(p::BigInt, g::BigInt)
    ^ᵖ = Arithmetic.fexmod(p)

    n = rand(2:p-1)
    return (g ^ᵖ n, n)
end

# Messages
# =============================================================================
"""
    encrypt(message, receiver_key, sender_key, p)
Encrypt a message under the ElGamal scheme.

Return: `cyphertext::BigInt`, the encrypted message as a number
"""
function encrypt(message::BigInt,
                 receiver_key::BigInt,
                 sender_secret::BigInt,
                 p::BigInt)
    ^ᵖ = Arithmetic.fexmod(p)
    shared_key = receiver_key ^ᵖ sender_secret

    cyphertext = message * shared_key % p
    return cyphertext
end

encrypt(m::Integer, r::Integer, s::Integer, p::Integer) =
    encrypt(BigInt(m), BigInt(r), BigInt(s), BigInt(p))

"""
    decrypt(cyphertext, sender_key, receiver_secret, p)
Decrypt a cyphertext under the ElGamal scheme.

Return: `message::BigInt`, the 'text' of the message
"""
function decrypt(cyphtertext::BigInt,
                 sender_key::BigInt,
                 receiver_secret::BigInt,
                 p::BigInt)
    ^ᵖ = Arithmetic.fexmod(p)

    shared_key = sender_key ^ᵖ receiver_secret
    shared_key_inverse = Arithmetic.modular_inverse(shared_key, p)

    message = cyphertext * shared_key_inverse % p
    return message
end

decrypt(c::Integer, s::Integer, r::Integer, p::Integer) =
    decrypt(BigInt(c), BigInt(s), BigInt(r), BigInt(p))

end
