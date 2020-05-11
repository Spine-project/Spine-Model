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

function preprocess_data_structure()
    add_connection_relationships()
    generate_network_components()
    generate_direction()
end

"""
    add_connection_relationships()

Add connection relationships for connection_type=:connection_type_lossless_bidirectional.

For connections with this parameter set, only a connection__from_node and connection__to_node need be set
and this function creates the additional relationships on the fly.
"""
function add_connection_relationships()
    conn_from_to = [
        (conn, first(connection__from_node(connection=conn)), first(connection__to_node(connection=conn)))
        for conn in connection(connection_type=:connection_type_lossless_bidirectional)
    ]
    isempty(conn_from_to) && return
    new_connection__from_node_rels = [(connection=conn, node=n) for (conn, _n, n) in conn_from_to]
    new_connection__to_node_rels = [(connection=conn, node=n) for (conn, n, _n) in conn_from_to]
    new_connection__node__node_rels = collect(
        (connection=conn, node1=n1, node2=n2) for (conn, x, y) in conn_from_to for (n1, n2) in ((x, y), (y, x))
    )
    add_relationships!(connection__from_node, new_connection__from_node_rels)
    add_relationships!(connection__to_node, new_connection__to_node_rels)
    add_relationships!(connection__node__node, new_connection__node__node_rels)
    value_one = parameter_value(1.0)
    new_connection__from_node_parameter_values = Dict(
        (conn, n) => Dict(:connection_conv_cap_to_flow => value_one) for (conn, n) in new_connection__from_node_rels
    )
    new_connection__to_node_parameter_values = Dict(
        (conn, n) => Dict(:connection_conv_cap_to_flow => value_one) for (conn, n) in new_connection__to_node_rels
    )
    new_connection__node__node_parameter_values = Dict(
        (conn, n1, n2) => Dict(:fix_ratio_out_in_connection_flow => value_one)
        for (conn, n1, n2) in new_connection__node__node_rels
    )
    merge!(connection__from_node.parameter_values, new_connection__from_node_parameter_values)
    merge!(connection__to_node.parameter_values, new_connection__to_node_parameter_values)
    merge!(connection__node__node.parameter_values, new_connection__node__node_parameter_values)
end

# Network stuff
"""
Generate has_ptdf and node_ptdf_threshold parameters associated to the node class.
"""
function generate_node_has_ptdf()
    for n in node()
        ptdf_comms = Tuple(
            c
            for c in node__commodity(node=n)
            if commodity_physics(commodity=c) in (:commodity_physics_lodf, :commodity_physics_ptdf)
        )
        node.parameter_values[n][:has_ptdf] = parameter_value(!isempty(ptdf_comms))
        node.parameter_values[n][:node_ptdf_threshold] = parameter_value(
            reduce(max, (commodity_ptdf_threshold(commodity=c) for c in ptdf_comms); init=0.0000001)
        )
    end
    has_ptdf = Parameter(:has_ptdf, [node])
    node_ptdf_threshold = Parameter(:node_ptdf_threshold, [node])
    @eval begin
        has_ptdf = $has_ptdf
        node_ptdf_threshold = $node_ptdf_threshold
    end
end

"""
Generate has_ptdf parameter associated to the connection class.
"""
function generate_connection_has_ptdf()
    for conn in connection()
        is_bidirectional = (
            length(connection__from_node(connection=conn)) == 2
            && Set(connection__from_node(connection=conn)) == Set(connection__to_node(connection=conn))
        )
        is_bidirectional_loseless = (
            is_bidirectional
            && fix_ratio_out_in_connection_flow(;
                connection=conn, zip((:node1, :node2), connection__from_node(connection=conn))..., _strict=false
            ) == 1
        )
        connection.parameter_values[conn][:has_ptdf] = parameter_value(
            is_bidirectional_loseless && all(has_ptdf(node=n) for n in connection__from_node(connection=conn))
        )
    end
    push!(has_ptdf.classes, connection)
end

"""
Generate has_lodf and connnection_lodf_tolerance parameters associated to the connection class.
"""
function generate_connection_has_lodf()
    for conn in connection(has_ptdf=true)
        lodf_comms = Tuple(
            c
            for c in commodity(commodity_physics=:commodity_physics_lodf)
            if issubset(connection__from_node(connection=conn), node__commodity(commodity=c))
        )
        connection.parameter_values[conn][:has_lodf] = parameter_value(!isempty(lodf_comms))
        connection.parameter_values[conn][:connnection_lodf_tolerance] = parameter_value(
            reduce(max, (commodity_lodf_tolerance(commodity=c) for c in lodf_comms); init=0.05)
        )
    end
    has_lodf = Parameter(:has_lodf, [connection])
    connnection_lodf_tolerance = Parameter(:connnection_lodf_tolerance, [connection])
    @eval begin
        has_lodf = $has_lodf
        connnection_lodf_tolerance = $connnection_lodf_tolerance
    end
end

function _ptdf_values()
    ps_busses_by_node = Dict(
        n => Bus(
            number=i,
            name=string(n.name),
            bustype=(node_opf_type(node=n) == :node_opf_type_reference) ? BusTypes.REF : BusTypes.PV,
            angle=0.0,
            voltage=0.0,
            voltagelimits=(min=0.0, max=0.0),
            basevoltage=nothing,
            area=nothing,
            load_zone=LoadZone(nothing),
            ext=Dict{String,Any}()
        )
        for (i, n) in enumerate(node(has_ptdf=true))
    )
    isempty(ps_busses_by_node) && return Dict()
    ps_busses = collect(values(ps_busses_by_node))
    PowerSystems.buscheck(ps_busses)
    PowerSystems.slack_bus_check(ps_busses)
    ps_lines_by_connection = Dict(
        conn => Line(;
            name=string(conn.name),
            available=true,
            activepower_flow=0.0,
            reactivepower_flow=0.0,
            arc=Arc((ps_busses_by_node[n] for n in connection__from_node(connection=conn))...),
            r=connection_resistance(connection=conn),
            x=max(connection_reactance(connection=conn), 0.00001),
            b=(from=0.0, to=0.0),
            rate=0.0,
            anglelimits=(min=0.0, max=0.0)
        )  # NOTE: always assume that the flow goes from the first to the second node in `connection__from_node`
        for conn in connection(has_ptdf=true)
    )
    ps_lines = collect(values(ps_lines_by_connection))
    ps_ptdf = PowerSystems.PTDF(ps_lines, ps_busses)
    Dict(
        (conn, n) => Dict(:ptdf => parameter_value(ps_ptdf[line.name, bus.number]))
        for (conn, line) in ps_lines_by_connection
        for (n, bus) in ps_busses_by_node
        if !isapprox(ps_ptdf[line.name, bus.number], 0; atol=node_ptdf_threshold(node=n))
    )
end

"""
Generate ptdf parameter.
"""
function generate_ptdf()
    ptdf_values = _ptdf_values()
    ptdf_rel_cls = RelationshipClass(
        :ptdf_connection__node,
        [:connection, :node],
        [(connection=conn, node=n) for (conn, n) in keys(ptdf_values)],
        ptdf_values
    )
    ptdf = Parameter(:ptdf, [ptdf_rel_cls])
    @eval begin
        ptdf = $ptdf
    end
end

"""
Generate lodf parameter.
"""
function generate_lodf()

    """
    Given a contingency connection, return a function that given the monitored connection, return the lodf.
    """
    function make_lodf_fn(conn_cont)
        n_from, n_to = connection__from_node(connection=conn_cont)
        denom = 1 - (ptdf(connection=conn_cont, node=n_from) - ptdf(connection=conn_cont, node=n_to))
        is_tail = isapprox(denom, 0; atol=0.001)
        if is_tail
            conn_mon -> ptdf(connection=conn_mon, node=n_to)
        else
            conn_mon -> (ptdf(connection=conn_mon, node=n_from) - ptdf(connection=conn_mon, node=n_to)) / denom
        end
    end

    lodf_values = Dict(
        (conn_cont, conn_mon) => Dict(:lodf => parameter_value(lodf_trial))
        for (conn_cont, lodf_fn, tolerance) in (
            (conn_cont, make_lodf_fn(conn_cont), connnection_lodf_tolerance(connection=conn_cont))
            for conn_cont in connection(connection_contingency=:value_true, has_lodf=true)
        )
        for (conn_mon, lodf_trial) in (
            (conn_mon, lodf_fn(conn_mon))
            for conn_mon in connection(connection_monitored=:value_true, has_lodf=true)
        )
        if conn_cont !== conn_mon && !isapprox(lodf_trial, 0; atol=tolerance)
    )  # NOTE: in my machine, a Dict comprehension is ~4x faster than a Dict built incrementally
    lodf_rel_cls = RelationshipClass(
        :lodf_connection__connection,
        [:connection1, :connection2],
        [(connection1=conn_cont, connection2=conn_mon) for (conn_cont, conn_mon) in keys(lodf_values)],
        lodf_values
    )
    lodf = Parameter(:lodf, [lodf_rel_cls])
    @eval begin
        lodf = $lodf
    end
end

function generate_network_components()
    generate_node_has_ptdf()
    generate_connection_has_ptdf()
    generate_connection_has_lodf()
    generate_ptdf()
    generate_lodf()
    # the below needs the parameters write_ptdf_file and write_lodf_file - we can uncomment when we update the template perhaps?
    # write_ptdf_file(model=first(model())) == Symbol(:true) && write_ptdfs()
    # write_lodf_file(model=first(model())) == Symbol(:true) && write_lodfs()
end

function generate_direction()
    from_node = Object(:from_node)
    to_node = Object(:to_node)
    direction = ObjectClass(:direction, [from_node, to_node])
    directions_by_class = Dict(
        unit__from_node => from_node,
        unit__to_node => to_node,
        connection__from_node => from_node,
        connection__to_node => to_node,
    )
    for cls in keys(directions_by_class)
        push!(cls.object_class_names, :direction)
    end
    for (cls, d) in directions_by_class
        map!(rel -> (; rel..., direction=d), cls.relationships, cls.relationships)
        key_map = Dict(rel => (rel..., d) for rel in keys(cls.parameter_values))
        for (key, new_key) in key_map
            cls.parameter_values[new_key] = pop!(cls.parameter_values, key)
        end
    end
    @eval begin
        direction = $direction
        export direction
    end
end