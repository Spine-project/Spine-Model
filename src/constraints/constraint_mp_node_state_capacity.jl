#############################################################################
# Copyright (C) 2017 - 2018  Spine Project
#
# This file is part of SpineOpt.
#
# SpineOpt is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SpineOpt is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################

"""
    add_constraint_mp_node_state_capacity!(m::Model)

Limit the maximum value of a `mp_node_state` variable under `node_state_cap`, if it exists.
"""
function add_constraint_mp_node_state_capacity!(m::Model)
    @fetch mp_node_state, storages_invested_available = m.ext[:variables]
    t0 = startref(current_window(m))
    m.ext[:constraints][:mp_node_state_capacity] = Dict(
        (node=ng, stochastic_scenario=s, t=t) => @constraint(
            m,
            + expr_sum(
                    +mp_node_state[ng, s, t]            
                    for (ng, s, t) in mp_node_state_indices(m; node=ng, stochastic_scenario=s, t=t);                    
                    init=0,
                )            
            <=
            +node_state_cap[(node=ng, stochastic_scenario=s, analysis_time=t0, t=t)]
            *( (candidate_storages(node=ng) != nothing) ?
                + expr_sum(
                    storages_invested_available[n, s, t1]
                    for
                    (n, s, t1) in
                    storages_invested_available_indices(m; node=ng, stochastic_scenario=s, t=t_in_t(m; t_short=t));
                    init=0,
                ) : 1
            )
        ) for (ng, s, t) in constraint_mp_node_state_capacity_indices(m)
    )
end


"""
    constraint_node_state_capacity_indices(m::Model; filtering_options...)

Form the stochastic index array for the `:constraint_node_state_capacity` constraint.

Uses stochastic path indices of the `node_state` variables. Keyword arguments can be used to filter the resulting 
"""
function constraint_mp_node_state_capacity_indices(
    m::Model;    
    node=anything,    
    stochastic_path=anything,
    t=anything,
)
    unique(
        (node=ng, stochastic_path=path, t=t)                       
        for (ng, s, t) in mp_node_state_indices(m; node=node)
        if ng in indices(node_state_cap)
        for
        path in active_stochastic_paths(unique(
            ind.stochastic_scenario for ind in _constraint_mp_node_state_capacity_indices(m, ng, t)            
        )) if path == stochastic_path || path in stochastic_path
        
    )
end


"""
    _constraint_node_state_capacity_indices(model, node, t)

Gather the indices of the relevant `node_state` and `storages_invested_available` variables.
"""
function _constraint_mp_node_state_capacity_indices(m, node, t)
    (m, node, t)
    Iterators.flatten((
        mp_node_state_indices(m; node=node, t=t),        
        storages_invested_available_indices(m; node=node, t=t_in_t(m; t_short=t))
    ))     
end