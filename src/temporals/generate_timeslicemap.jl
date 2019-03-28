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
    generate_timeslicemap()

"""
function generate_timeslicemap()
    @butcher list_timeslicemap = []
    list_duration = []
    list_timeslicemap_detail = []
    list_timesliceblock = Dict()
    for k in temporal_block()
        list_timesliceblock[k]=[]
        if time_slice_duration()[k][2] == nothing
            for x in collect(start_date(k):Minute(time_slice_duration()[k][1]):end_date(k)-Minute(time_slice_duration()[k][1]))
                time_slice_symbol = Symbol("t_$(year(x))_$(month(x))_$(day(x))_$(hour(x))_$(minute(x))__$(year(x+Minute(time_slice_duration()[k][1])))_$(month(x+Minute(time_slice_duration()[k][1])))_$(day(x+Minute(time_slice_duration()[k][1])))_$(hour(x+Minute(time_slice_duration()[k][1])))_$(minute(x+Minute(time_slice_duration()[k][1])))")
                list_timeslicemap = push!(list_timeslicemap,time_slice_symbol)
                list_timesliceblock[k] = push!(list_timesliceblock[k],time_slice_symbol)
                list_duration = push!(list_duration,Tuple([time_slice_symbol, (Minute(time_slice_duration()[k][1]))]))
                list_timeslicemap_detail = push!(list_timeslicemap_detail,Tuple([time_slice_symbol,x,x+Minute(time_slice_duration()[k][1])]))
            end
        else
            x = start_date(k)
            for j = 1:(length(time_slice_duration()[k])-1)
                time_slice_symbol = Symbol("t_$(year(x))_$(month(x))_$(day(x))_$(hour(x))_$(minute(x))__$(year(x+Minute(time_slice_duration()[k][j])))_$(month(x+Minute(time_slice_duration()[k][j])))_$(day(x+Minute(time_slice_duration()[k][j])))_$(hour(x+Minute(time_slice_duration()[k][j])))_$(minute(x+Minute(time_slice_duration()[k][j])))")
                list_timeslicemap = push!(list_timeslicemap,time_slice_symbol)
                list_timesliceblock[k] = push!(list_timesliceblock[k],time_slice_symbol)
                list_duration = push!(list_duration,Tuple([time_slice_symbol, (Minute(time_slice_duration()[k][j]))]))
                list_timeslicemap_detail = push!(list_timeslicemap_detail,Tuple([time_slice_symbol,x,x+Minute(time_slice_duration()[k][1])]))
                x = x+Minute(time_slice_duration()[k][j])
            end
            if x != end_date(k)
                @warn "WARNING: Last timeslice of $k doesn't coinside with defined enddate for temporalblock $k"
            end
        end
    end
    unique!(list_timeslicemap)
    unique!(list_timeslicemap_detail)
    unique!(list_duration)
    function timeslicemap(;kwargs...)
        if length(kwargs) == 0
            list_timeslicemap
        elseif length(kwargs) == 1
            key, value = iterate(kwargs)[1]
            if key == :temporal_block
                timeslicesblock = list_timesliceblock[value]
                timeslicesblock
            end
        end
    end
    timeslicemap_detail() = list_timeslicemap_detail
    duration() = list_duration
    timeslicemap,timeslicemap_detail,duration
end
