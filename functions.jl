
function get_x_mu(mst, Ms)
    # Get optimal investment decisions
    x0hat = value.(mst[:x0])

    # Fix optimal investment decisions
    for p in Ms.P for i0 in Ms.I0 fix(mst[:x0][p,i0],x0hat[p,i0];force=true) end end
    optimize!(mst)

    # Get gradients
    μ0  = convert(Array{Float64,2},dual.(FixRef.(mst[:x0][:,:])))

    # Undo variable fix
    for p in Ms.P for i0 in Ms.I0 unfix(mst[:x0][p,i0]), set_lower_bound(mst[:x0][p,i0], .0) end end

    x0hat = convert(Array{Float64,2},x0hat)

    return x0hat, μ0
end


# Function to get gradients of investment nodes (μ0) and investment decisions (x0) for each iteration
function gradient_AB(case)

    println("Solving case ", case, "...")

    μ0 = Vector{Array{Float64,2}}()
    x0 = Vector{Array{Float64,2}}()
    TI = Vector{Float64}()

    # Generate data structure
    Ms,Mp,Ps,Pp,U = generate_data(case)
    R,E,O,J,B,S,T = gen_structs_AB(Ms,Mp,Ps,Pp,U,ITmax)

    # Get initial gradient, i.e. inv_c and inv_fix per technology
    time = @elapsed x0hat, μ0_init = get_x_mu(R.m, Ms)
    push!(x0, x0hat), push!(μ0, μ0_init), push!(TI, time)

    # Adapt Bend algorithm step 0
    E,S,O,J,T = Adapt_Bend_step_0(Ms,Mp,U,E,S,O,J,T)

    # Solve case
    for it in 1:ITmax
        R,E,O,S,B,J,T = iter_AB(Mp,U,R,E,O,S,B,J,T)
        print_info_AB(J,B)

        time = @elapsed x1hat, μ1 = get_x_mu(R.m,Ms)
        push!(x0, x1hat), push!(μ0, μ1), push!(TI,time)

        (J.Δ <= ϵ) ? break : nothing
    end

    return Ms.I0, μ0, x0
end



function plot_investment(data, w)

    df = DataFrame(it = Int[], Coal = Float64[], Coalccs = Float64[], OCGT = Float64[], CCGT = Float64[], Diesel = Float64[], Nuclear = Float64[], PumpL = Float64[], PumpH = Float64[], Lithium = Float64[], Onwind = Float64[], Offwind = Float64[], PV = Float64[])

    for i in 1:length(data)
        push!(df, (i, data[i][1,w], data[i][2,w],data[i][3,w],data[i][4,w],data[i][5,w], data[i][6,w],data[i][7,w], data[i][8,w], data[i][9,w], data[i][10,w], data[i][11,w],data[i][12,w]))
    end

    tech = ["Coal","Coalccs","OCGT","CCGT","Diesel","Nuclear","PumpL","PumpH","Lithium","Onwind","Offwind","PV"]
    keys = ["black","grey60","red","orange","mediumpurple","green","pink","deepskyblue","gold","lightblue","blue","Yellow"]

    Coal = layer(df, x=:it, y=:Coal, Geom.line, Theme(default_color=keys[1]))
    Coalccs = layer(df, x=:it, y=:Coalccs, Geom.line, Theme(default_color=keys[2]))
    OCGT = layer(df, x=:it, y=:OCGT, Geom.line,Theme(default_color=keys[3]))
    CCGT = layer(df, x=:it, y=:CCGT, Geom.line,Theme(default_color=keys[4]))
    Diesel = layer(df, x=:it, y=:Diesel, Geom.line, Theme(default_color=keys[5]))
    Nuclear = layer(df, x=:it, y=:Nuclear, Geom.line, Theme(default_color=keys[6]))
    PumpL = layer(df, x=:it, y=:PumpL, Geom.line, Theme(default_color=keys[7]))
    PumpH = layer(df, x=:it, y=:PumpH, Geom.line, Theme(default_color=keys[8]))
    Lithium = layer(df, x=:it, y=:Lithium, Geom.line, Theme(default_color=keys[9]))
    Onwind = layer(df, x=:it, y=:Onwind, Geom.line, Theme(default_color=keys[10]))
    Offwind = layer(df, x=:it, y=:Offwind, Geom.line, Theme(default_color=keys[11]))
    PV = layer(df, x=:it, y=:PV, Geom.line, Theme(default_color=keys[12]))

    myplot = plot(Coal, Coalccs, OCGT,CCGT,Diesel,Nuclear,PumpL,PumpH,Lithium,Onwind,Offwind,PV, Guide.ylabel("Investment in GW"),Guide.xlabel("Iteration"), Guide.title("ω$w"), Coord.cartesian(xmin=0, xmax=length(data), ymin=0, ymax=30), Guide.manual_color_key("Technology", tech, keys))
    draw(SVG("investment_node$w.svg", 20cm,15cm), myplot)

end


function plot_gradient(data, w)

    df = DataFrame(it = Int[], Coal = Float64[], Coalccs = Float64[], OCGT = Float64[], CCGT = Float64[], Diesel = Float64[], Nuclear = Float64[], PumpL = Float64[], PumpH = Float64[], Lithium = Float64[], Onwind = Float64[], Offwind = Float64[], PV = Float64[])

    for i in 1:length(data)
        push!(df, (i, data[i][1,w], data[i][2,w],data[i][3,w],data[i][4,w],data[i][5,w], data[i][6,w],data[i][7,w], data[i][8,w], data[i][9,w], data[i][10,w], data[i][11,w],data[i][12,w]))
    end

    tech = ["Coal","Coalccs","OCGT","CCGT","Diesel","Nuclear","PumpL","PumpH","Lithium","Onwind","Offwind","PV"]
    keys = ["black","grey60","red","orange","mediumpurple","green","pink","deepskyblue","gold","lightblue","blue","Yellow"]

    Coal = layer(df, x=:it, y=:Coal, Geom.line, Theme(default_color=keys[1]))
    Coalccs = layer(df, x=:it, y=:Coalccs, Geom.line, Theme(default_color=keys[2]))
    OCGT = layer(df, x=:it, y=:OCGT, Geom.line,Theme(default_color=keys[3]))
    CCGT = layer(df, x=:it, y=:CCGT, Geom.line,Theme(default_color=keys[4]))
    Diesel = layer(df, x=:it, y=:Diesel, Geom.line, Theme(default_color=keys[5]))
    Nuclear = layer(df, x=:it, y=:Nuclear, Geom.line, Theme(default_color=keys[6]))
    PumpL = layer(df, x=:it, y=:PumpL, Geom.line, Theme(default_color=keys[7]))
    PumpH = layer(df, x=:it, y=:PumpH, Geom.line, Theme(default_color=keys[8]))
    Lithium = layer(df, x=:it, y=:Lithium, Geom.line, Theme(default_color=keys[9]))
    Onwind = layer(df, x=:it, y=:Onwind, Geom.line, Theme(default_color=keys[10]))
    Offwind = layer(df, x=:it, y=:Offwind, Geom.line, Theme(default_color=keys[11]))
    PV = layer(df, x=:it, y=:PV, Geom.line, Theme(default_color=keys[12]))

    myplot = plot(Coal, Coalccs, OCGT,CCGT,Diesel,Nuclear,PumpL,PumpH,Lithium,Onwind,Offwind,PV, Guide.ylabel("λ"),Guide.xlabel("Iteration"), Guide.title("ω$w"), Coord.cartesian(ymin=-1*10^9,ymax=1*10^9, xmin=0, xmax=length(data)), Guide.manual_color_key("Technology", tech, keys))
    draw(SVG("gradient_node$w.svg", 20cm,15cm), myplot)

end
