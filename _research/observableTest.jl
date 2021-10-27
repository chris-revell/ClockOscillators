using GLMakie

fig = Figure()

ax = Axis(fig[1, 1])

lsgrid = labelslidergrid!(
    fig,
    ["ϕF", "ϕM", "μ"],
    [0:0.1:2π, 0:0.1:2π, 0:0.1:1.0];
    formats = [x -> "$(round(x, digits = 1))$s" for s in ["V", "A", "Ω"]],
    width = 350,
    tellheight = false)

fig[1, 2] = lsgrid.layout

sliderobservables = [s.value for s in lsgrid.sliders]
bars = lift(sliderobservables...) do slvalues...
    [slvalues...]
end

barplot!(ax, bars, color = [:yellow, :orange, :red])
ylims!(ax, 0, 30)

set_close_to!(lsgrid.sliders[1], 5.3)
set_close_to!(lsgrid.sliders[2], 10.2)
set_close_to!(lsgrid.sliders[3], 15.9)

fig
