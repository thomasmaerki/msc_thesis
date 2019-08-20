cd(dirname(@__FILE__))

println("loading packages...")
using JuMP,Gurobi,JLD2,CSV,LinearAlgebra, Gadfly, DataFrames

println("loading functions...")
# AdaptBend functions
include("functions/data_file.jl")
include("functions/functions.jl")
include("functions/functions_AB.jl")
include("functions/opt_models.jl")
# Functions by TM
include("functions.jl")

const ITmax = 1000
const ϵ = 10.01

# Solve case 3 of original paper / case 1 of MSc thesis
I0, μ0, x0 = gradient_AB(3)

# Plot investments and gradients w.r.t. investment decisions
for i0 in I0 plot_investment(x0,i0), plot_gradient(μ0,i0) end
