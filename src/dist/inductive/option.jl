
export Opt

module Opt
    using Alea
    @type T{A} = OptNone() | OptSome(A)

    function bind(f, T, x::Opt.T)
        @match x [
            OptNone() -> OptNone(T),
            OptSome(x) -> f(x)
        ]
    end

    function map(f, T, x::Opt.T)
        @match x [
            OptNone() -> OptNone(T),
            OptSome(x) -> OptSome(T, f(x))
        ]
    end
end
