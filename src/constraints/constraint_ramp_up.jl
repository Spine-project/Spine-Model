#############################################################################
# Copyright (C) 2017 - 2018  Spine Project
#
# This file is part of Spine Model.
#
# Spine Model is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Spine Model is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################

"""
    add_constraint_ramp_up!(m::Model)

Limit the maximum ramp of `ramp_up_unit_flow` of a `unit` or `unit_group` if the parameters
`ramp_up_limit`,`unit_capacity`,`unit_conv_cap_to_unit_flow` exist.
"""
function add_constraint_ramp_up!(m::Model)
    @fetch units_on, units_started_up, ramp_up_unit_flow = m.ext[:variables]
    t0 = startref(current_window(m))
    m.ext[:constraints][:ramp_up] = Dict(
        (unit=u, node=ng, direction=d, stochastic_path=s, t=t) => @constraint(
            m,
            + sum(
                ramp_up_unit_flow[u, n, d, s, t]
                for (u, n, d, s, t) in ramp_up_unit_flow_indices(
                    m; unit=u, node=ng, direction = d, t=t, stochastic_scenario=s
                )
            )
            <=
            + sum(
                (units_on[u, s, t] - units_started_up[u, s, t])
                * ramp_up_limit[(unit=u, node=ng, direction=d, stochastic_scenario=s, analysis_time=t0, t=t)]
                * unit_conv_cap_to_flow[(unit=u, node=ng, direction=d, stochastic_scenario=s, analysis_time=t0, t=t)]
                * unit_capacity[(unit=u, node=ng, direction=d, stochastic_scenario=s, analysis_time=t0, t=t)]
                for (u,s,t) in units_on_indices(m; unit=u, stochastic_scenario=s, t=t_overlaps_t(m; t=t))
            )
        )
        for (u, ng, d, s, t) in constraint_ramp_up_indices(m)
    )
end

#COPY from unit_state_transition"

"""
    constraint_ramp_up_indices(m::Model; filtering_options...)

Form the stochastic indexing Array for the `:ramp_up` constraint.

Uses stochastic path indices due to potentially different stochastic scenarios between `t_after` and `t_before`.
Keyword arguments can be used to filter the resulting Array.
"""
function constraint_ramp_up_indices(
    m::Model; unit=anything, node=anything, direction=anything, stochastic_path=anything, t=anything
)
    unique(
        (unit=u, node=ng, direction=d, stochastic_path=path, t=t)
        for (u, ng, d) in indices(ramp_up_limit)
        if u in unit && ng in node && d in direction
        for t in t_lowest_resolution(time_slice(m; temporal_block=node__temporal_block(node=members(ng)), t=t))
        # How to deal with groups correctly?
        for path in active_stochastic_paths(
            unique(
                ind.stochastic_scenario
                for ind in Iterators.flatten(
                    (units_on_indices(m; unit=u, t=t), ramp_up_unit_flow_indices(m; unit=u, node=ng, direction=d, t=t))
                )
            )
        )
        if path == stochastic_path || path in stochastic_path
    )
end