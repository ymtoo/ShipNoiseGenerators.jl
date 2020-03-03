using ShipNoiseGenerators
using DSP, FFTW, Statistics, Random, Test

function bandpassfilter(x, cutoff, fs; order=2)
    hp = digitalfilter(Bandpass(cutoff[1], cutoff[2]; fs=fs), Butterworth(order))
    filt(hp, x)
end

@testset "ShipNoiseGenerators.jl" begin

n = 96000
fs = 96000
g1 = PinkNoiseGenerator(n)
x = rand(g1)
p = welch_pgram(x, 1024; fs=fs)
xpts = log10.(freq(p))[2:end]
ypts = 10*log10.(power(p))[2:end]
β = sum((xpts.-mean(xpts)).*(ypts.-mean(ypts)))/sum((xpts.-mean(xpts)).^2)

@test β ≈ (10*log10(1/xpts[end])-10*log10(1/xpts[1]))/(log10(xpts[end])-log10(xpts[1])) atol=0.1


n = 96000
fs = 96000
As = [0.8]
frequencies = [200.0]
ϕs = [0.1]
g2 = ShipNoiseGenerator(n=n, fs=fs, As=As, frequencies=frequencies, ϕs=ϕs)
x = rand(g2)

cutoff = [10.0, 1000.0]
y = bandpassfilter(x, cutoff, fs; order=7)
env = abs.(hilbert(y))
rate = 1//80
fsnew = fs*rate
spec = abs.(rfft(resample(env, rate)))
spec[1] = 0.0
freqindices = FFTW.rfftfreq(n, fs)
@test freqindices[argmax(spec)] == frequencies[1]

end
