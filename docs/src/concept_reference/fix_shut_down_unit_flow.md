The [fix\_shut\_down\_unit\_flow](@ref) parameter fixes the value of the [shut\_down\_unit\_flow](@ref) to the provided value, if the parameter is defined.

Common uses for the parameter include e.g. providing initial values for the [shut\_down\_unit\_flow](@ref),
by fixing the value on the first modelled time step *(or the value before the first modelled time step)*
using a `TimeSeries` type parameter value with an appropriate timestamp.
Due to the way *SpineOpt* handles `TimeSeries` data,
the [shut\_down\_unit\_flow](@ref) variable is only fixed for time steps with defined [fix\_shut\_down\_unit\_flow](@ref) parameter values.

Other uses can include e.g. a constant or time-varying **exogenous** commodity flow from or to a unit.

Note that the mentioned [shut\_down\_unit\_flow](@ref) variable is only included if the parameter [max\_startup\_ramp](@ref) exist for the correspond [unit\_\_to\_node](@ref) or [unit\_\_from\_node](@ref) relationship. The usage of ramps is described in [Ramping and Reserves](@ref).
