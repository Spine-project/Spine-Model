Used to implement unit startup fuel consumption where node 1 is assumed to be input fuel and node 2 is assumed to be output elecrical energy. This is a flow from node 1 that is incurred when the value of the variable units_started_up is 1 in the corresponding time period. This flow does not result in additional output flow at node 2. Used in conjunction with [unit\_incremental\_heat\_rate](@ref). `unit_start_flow` will is only currently considered if [unit\_incremental\_heat\_rate](@ref). A trivial [unit\_incremental\_heat\_rate](@ref) of zero can be defined if this is not relevant.