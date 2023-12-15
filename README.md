# Cryptography Coursework

## How to Run

The easiest way to use the code I've written is in "interactive mode". If you
just run the files, all you will do is load the module and then quit; they are
function libraries, not standalone scripts.

1. Install Julia; it should be available as `julia` on the command line.
2. Run `julia` without modifiers to open the REPL. Modules can be loaded by
   relative filepath. Ex.: After starting Julia from the root, run the command
   ```jl
   include("src/ElGamal.jl")
   ```
   to load the `ElGamal` module.
3. Run tests with `julia test/runtests.jl`.

## Notes on Syntax

```jl
"""
This is a docstring. Tools will use this as automatic documentation.
"""
function an_example_function(a::Type, b::Type)
    body...
end

"""
Docstrings can also modify things that aren't functions.
"""
struct AnExampleStruct
    # An abstract 'Integer' type, supertype of all other integers
    first_element::Integer

    # Specifically a fixed-size integer
    second_element::Int128

    # BigInt for arbitrary precision. Other integer types do NOT automatically
    # promote to BigInt, so it needs to be used explicitly; I use it ALL OVER
    # THE PLACE to make sure there's room for the integers we use.
    # NOTE: BigInt is a supertype of all fixed-size integers,
    #   Int16 <: Int32 <: ... <: BigInt <: Integer
    third_element::BigInt
end
```

### Weird Symbols

This is what I found oddest about Julia. You can use any Unicode symbol as a
valid identifier in Julia -- technically that inclues emoji, so 😆 could be a
variable if you want.

The more practical thing this enables is "math notation." According to my Julia
expert friends, it is considered good practice in Julia to try to represent
mathematics as close as possible to how it would be written in a paper. So for
example, it is encouraged to use the literal `ξ` rather than `xi` if you need to
represent a xi.

Another thing that is manifests in is subscripts and superscripts. It is _also_
considered generally idiomatic to use names like `(r₁, r₂)` rather than
`(r1, r2)` or `(r_1, r_2)`, when you are not dealing with complete additional
words in the same.

### Function Syntax

There are three different syntaxes for defining a function.

This is block syntax:
```jl
function name(args)
    body
end
```

You also have "math" syntax, which is typically used either for polynomials and
stuff like that, or for very short functions that fit on a single line:
```jl
"""
Define the function f:
"""
f(x) = x + 1
```

Anonymous functions, like for filtering a list:
```jl
(a, b) -> sqrt(a^2 + b^2)
```

### Multiple Dispatch

At compile time, a function is assigned an implementation based on the specific
types that are passed to it. That means that the same function will do
different things based on the types it is called on. This is called the
"multiple dispatch" paradigm; it is the coolest feature I learned about here.

For this project specifically, you'll see a lot of this:
```jl
function something(x::BigInt, p::BigInt, q::BigInt)
    body...
end

something(x::Integer, p::Integer, q::Integer) =
    something(BigInt(x), BigInt(p), BigInt(q))
```

This is me using multiple dispatch to make sure that everything gets parsed
properly as a `BigInt` type. A function call will be dispatched against the
most specific (furthest down the type inheritance tree) implentation that
matches the arguments it is passed. So this little snippet should be read as
"If you pass a generic integer that isn't a `BigInt`, cast all the numbers to
`BigInt` and return that value instead."

## Factorization

My factorization code is **very** slow. Apologies for that. If it looks like
it's frozen, it shouldn't be; I've tried to set it up so that if there is a
problem, it'll just raise an error and crash rather than loop forever.
