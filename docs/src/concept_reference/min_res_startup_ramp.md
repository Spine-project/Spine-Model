A unit can provide spinning and nonspinning reserves to a [reserve node](@ref is_reserve_node). These reserves can be either [upward\_reserve](@ref) or [downward\_reserve](@ref).
Nonspinning upward reserves are provided to an [upward\_reserve](@ref) node by contracted offline units holding available to startup. If a unit is scheduled to provide nonspinning reserve, a limit on the minimum amount of reserves provided can be imposed by defining the parameter [min\_res\_startup\_ramp](@ref) on a [unit\_\_to\_node](@ref) relationship, which triggers the constraint [on minimum upward nonspinning reserve provision](@ref constraint_min_nonspin_ramp_up). The parameter [min\_res\_startup\_ramp](@ref) is given as a fraction of the [unit\_capacity](@ref) of the corresponding [unit\_\_to\_node](@ref) relationship.

Note that to include the provision of nonspinning upward reserves, the parameter [max\_res\_startup\_ramp](@ref) needs to be defined on the corresponding [unit\_\_to\_node](@ref) relationship, which triggers the generation of the variables [nonspin\_units\_started\_up and nonspin\_ramp\_up_unit_flow](@ref Variables).

A detailed description of the usage of ramps and reserves is given in the chapter [Ramping and Reserves](@ref Ramping-and-Reserves). The chapter [Ramping and reserve constraints](@ref) in the Mathematical Formulation presents the equations related to ramps and reserves.