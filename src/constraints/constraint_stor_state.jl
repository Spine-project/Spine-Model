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
    constraint_stor_state(m::Model, stor_state)

Balance for storage level.
"""
function constraint_stor_state(m::Model, stor_state,trans,flow, timeslicemap)
    @butcher for (c, stor) in commodity__storage(), t=2:number_of_timesteps(time_stage=:timer)
        all([
            frac_state_loss(commodity=c,storage=stor) != nothing
            eff_stor_charg(storage=stor) != nothing
            eff_stor_discharg(storage=stor) != nothing
        ]) || continue
        @constraint(
            m,
            + stor_state[c,stor,t]
            ==
            + stor_state[c,stor,t-1]
                *(1-frac_state_loss(commodity=c,storage=stor))
            - reduce(+,
                flow[a,b,d, :out, t-1]*eff_stor_discharg(storage=stor)
                    for (a,b,d) in filter(t -> in(t[3],storage__unit(storage=stor)), commodity__node__unit__direction(direction=:out)))
            + reduce(+,
                flow[a,b,d, :in, t-1]*eff_stor_charg(storage=stor)
                    for (a,b,d) in filter(t -> in(t[3],storage__unit(storage=stor)), commodity__node__unit__direction(direction=:in)))
            - reduce(+,
                trans[a,b,d, :out, t-1]*eff_stor_discharg(storage=stor)
                    for (a,b,d) in filter(t -> in(t[3],storage__connection(storage=stor)), commodity__node__connection__direction(direction=:out)))
            - reduce(+,
                trans[a,b,d, :in, t-1]*eff_stor_charg(storage=stor) #TO DO: EFF STOR ALS FKT von unit
                    for (a,b,d) in filter(t -> in(t[3],storage__connection(storage=stor)), commodity__node__connection__direction(direction=:in)))
        )
    end
end
