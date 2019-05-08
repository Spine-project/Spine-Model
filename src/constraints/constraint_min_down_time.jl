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
    constraint_min_down_time(m::Model, units_online, units_available, units_shutting_down)

Constraint start-up by minimum down time.
"""

function constraint_min_down_time(m::Model, units_online, units_available, units_shutting_down)
    for inds in indices(min_down_time; value_filter=v->v!=0)
        for x in units_online_indices(;inds...)
            @constraint(
                m,
                + units_online[x]
                <=
                + units_available[x]
                - sum(
                    units_shutting_down[y]
                    for y in units_online_indices(;inds...)
                        if x.t.start - min_down_time(;inds...) < y.t.start <= x.t.start
                )
            )
        end
    end
end