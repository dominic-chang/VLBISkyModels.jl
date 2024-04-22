abstract type AbstractNUFTPlan <: AbstractPlan end
abstract type NUFT <: FourierTransform end


"""
    $(TYPEDEF)

Internal type used to store the cache for a non-uniform Fourier transform (NUFT).

The user should instead create this using the [`create_cache`](@ref create_cache) function.
"""
struct NUFTPlan{A,P,M,PI,G} <: AbstractNUFTPlan
    alg::A # which algorithm to use
    plan::P #NUFT matrix or plan
    phases::M #FT phases needed to phase center things
end

function create_forward_plan(imagedomain::AbstractRectiGrid, visdomain::UnstructuredGrid, algorithm::NUFT, pulse::Pulse)
    plan = plan_nuft(algorithm, imagedomain, visdomain)
    phases = make_phases(algorithm, imagedomain, visdomain, pulse)
    return NUFTPlan(algorithm, plan, phases)
end

function inverse_plan(plan::NUFTPlan)
    return NUFTPlan(plan.alg, plan.plan', inv.(plan.phases))
end



@inline function nuft(A, b::AbstractArray)
    return _nuft(A, b)
end

@inline function nuft(A, b::IntensityMap)
    return nuft(A, baseimage(b))
end

@inline function nuft(A, b::AbstractArray{<:StokesParams})
    I = _nuft(A, stokes(b, :I))
    Q = _nuft(A, stokes(b, :Q))
    U = _nuft(A, stokes(b, :U))
    V = _nuft(A, stokes(b, :V))
    return StructArray{StokesParams{eltype(I)}}((;I, Q, U, V))
end

@inline function nuft(A, b::StokesIntensityMap)
    I = _nuft(A, stokes(b, :I))
    Q = _nuft(A, stokes(b, :Q))
    U = _nuft(A, stokes(b, :U))
    V = _nuft(A, stokes(b, :V))
    return StructArray{StokesParams{eltype(I)}}((;I, Q, U, V))
end










include(joinpath(@__DIR__, "nfft_alg.jl"))

include(joinpath(@__DIR__, "dft_alg.jl"))
