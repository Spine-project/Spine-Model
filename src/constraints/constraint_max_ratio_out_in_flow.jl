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
    constraint_max_ratio_out_in_flow(m::Model, flow)

Fix ratio between the output `flow` of a `commodity_group` to an input `flow` of a
`commodity_group` for each `unit` for which the parameter `max_ratio_out_in_flow`
is specified.
"""
function constraint_max_ratio_out_in_flow(m::Model, flow)
    for inds in indices(max_ratio_out_in_flow)
        time_slices_out = unique(
            x.t
            for x in flow_indices(;
                inds...,
                commodity=commodity_group__commodity(commodity_group=inds.commodity_group1)
            )
        )
        time_slices_in = unique(
            x.t
            for x in flow_indices(;
                inds...,
                commodity=commodity_group__commodity(commodity_group=inds.commodity_group2)
            )
        )
        # NOTE: `unique` is not really necessary but it reduces the timeslices for the next steps
        involved_timeslices = sort([time_slices_out; time_slices_in])
        overlaps = sort(t_overlaps_t(time_slices_in, time_slices_out))
        if involved_timeslices != overlaps
            @warn "Not all involved timeslices are overlapping, check your temporal_blocks"
            # NOTE: this is a check for plausibility.
            # If the user e.g. wants to oconstrain one commodity of a unit for a certain amount of time,
            # while the other commodity is constraint for a longer period, "overlaps" becomes active
            involved_timeslices = overlaps
        end
        for t in t_lowest_resolution(involved_timeslices)
            @constraint(
                m,
                + sum(
                    flow[x] * duration(x.t)
                    for x in flow_indices(;
                        inds...,
                        commodity=commodity_group__commodity(commodity_group=inds.commodity_group1),
                        t=t_in_t(t_long=t)
                    )
                )
                <=
                + max_ratio_out_in_flow(;inds..., t=t)
                * sum(
                    flow[x] * duration(x.t)
                    for x in flow_indices(;
                        inds...,
                        commodity=commodity_group__commodity(commodity_group=inds.commodity_group2),
                        t=t_in_t(t_long=t)
                    )
                )
            )
        end
    end
end