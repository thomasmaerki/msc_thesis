# MSc Thesis
### Scenario Generation and Reduction for Stochastic Investment Planning

This code is used as part of the disseration project presented for the degree of Msc in Opertional Research with Data Science at the University of Edinburgh.


### Prerequisites
The code requires [Julia 1.1](https://julialang.org/downloads/), [JuMP.jl 0.19](https://github.com/JuliaOpt/JuMP.jl), [Gurobi.jl](https://github.com/JuliaOpt/Gurobi.jl), [JLD2.jl](https://github.com/JuliaIO/JLD2.jl), [CSV.jl](https://github.com/JuliaData/CSV.jl), [Gadfly.jl](https://github.com/GiovineItalia/Gadfly.jl), [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) and [Gurobi 7.5](http://www.gurobi.com/downloads/gurobi-optimizer). 
In addition, the Benders algorithm with adaptive oracles is required to run the code: [AdaptBend](https://github.com/nimazzi/Stand_and_Adapt_Bend). Note that the linked code is currently not updated to JuMP 0.19.
