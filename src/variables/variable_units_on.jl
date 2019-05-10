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
    generate_units_on(m::Model)

#TODO: add model descirption here
"""
function variable_units_on(m::Model)
    m.ext[:variables][:units_on] = VariableDict(
        x => @variable(
            m, base_name="units_on[$(x.unit), $(x.t.JuMP_name)]", integer=true, lower_bound=0
        ) for x in units_on_indices()
    )
end


"""
    units_on_indices(filtering_options...)

A set of tuples for indexing the `units_on` variable. Any filtering options can be specified
for `unit` and `t`.
"""
function units_on_indices(;unit=anything, t=anything)
    [
        (unit=u, t=t1)
        for u in intersect(SpineModel.unit(), unit)
            for t1 in intersect(t_highest_resolution([x.t for x in flow_indices(unit=u)]), t)
    ]
end