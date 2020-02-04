module ShipNoiseGenerators

using Distributions, DSP, Random

export ShipNoiseGenerator, PinkNoiseGenerator

Base.@kwdef struct ShipNoiseGenerator{T}
     n::Int64 = 96000
     fs::T = 96000.0
     As::AbstractArray{T, 1} = [0.5]
     frequencies::AbstractArray{T, 1} = [500.0]
     ϕs::AbstractArray{T, 1} = [0.0]
end

Base.@kwdef struct PinkNoiseGenerator
    n::Int64
end

"""
Synthesis of 1/F Noise (Pink Noise) based on https://ccrma.stanford.edu/~jos/sasp/Example_Synthesis_1_F_Noise.html
"""
function Random.rand!(rng::AbstractRNG, g::PinkNoiseGenerator)
    n=g.n
    B = [0.049922035, -0.095993537, 0.050612699, -0.004408786]
    A = [1.0, -2.494956002, 2.017265875, -0.522189400]
    nT60 = 1430
    v = randn(n+nT60)
    x = filt(B, A, v)/0.08680587859687908
    x[nT60+1:end]
end

Base.rand(rng::AbstractRNG, g::PinkNoiseGenerator) = rand!(rng, g)

function Random.rand!(rng::AbstractRNG, g::ShipNoiseGenerator)
    n=g.n; fs=g.fs; As=g.As; frequencies=g.frequencies; ϕs=g.ϕs
    x = rand(PinkNoiseGenerator(n=n))
    t = (1:n)./fs
    m = zeros(n)
    for (A, frequency, ϕ) in zip(As, frequencies, ϕs)
        ω = 2π*frequency
        m .+= A.*sin.(ω.*t.+ϕ)
    end
    x .*= 1.0 .+ m
    x ./ std(x)
end

Base.rand(rng::AbstractRNG, g::ShipNoiseGenerator) = rand!(rng, g)

end
