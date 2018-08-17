"""
    @suppress_err expr
Suppress the STDERR stream for the given expression.
"""
# NOTE: Borrowed from Suppressor.jl
macro suppress_err(block)
    quote
        if ccall(:jl_generating_output, Cint, ()) == 0
            ORIGINAL_STDERR = STDERR
            err_rd, err_wr = redirect_stderr()
            err_reader = @schedule read(err_rd, String)
        end

        try
            $(esc(block))
        finally
            if ccall(:jl_generating_output, Cint, ()) == 0
                redirect_stderr(ORIGINAL_STDERR)
                close(err_wr)
            end
        end
    end
end


function find_nodes(con, add_permutation=true)
    """"
    finds pairs of nodes with the same commodity for a given connection "con"
        con: string
        return: list of connection lists (per commidity) e.g. [[["n1", "n2"], ["n2", "n1"]],[["n3", "n4"], ["n4", "n3"]]]
    """
    #giving relationship names as string -> todo: change
    rel_node_connection = "NodeConnectionRelationship"
    rel_commodity = "CommodityAffiliation"

    function find_node_com(nodes, com_nodes, com, add_permutation=false)
        """
        helperfunction
        """
        ind=find(com_nodes -> com_nodes == com,com_nodes)
        if length(ind) == 2
            if add_permutation
                return [[nodes[ind[1]],nodes[ind[2]]],[nodes[ind[2]],nodes[ind[1]]]]
            else
                return [[nodes[ind[1]],nodes[ind[2]]]]
            end
        elseif length(ind) == 0
            return NaN
        else
            error("found more than two nodes with the same commodity")
        end
    end
    nodes = eval(parse(:($rel_node_connection)))(con)
    com_nodes = [eval(parse(:($rel_commodity)))(n)[1] for n in nodes]
    nodepairs=[]
    for c in commodity()
        np = find_node_com(nodes, com_nodes, c, add_permutation)
        if  np !== NaN
            nodepairs=vcat(nodepairs,np)
        end
    end
    return nodepairs
end

function find_connections(node, add_permutation = false)
    """
    find all connection objects connected to the given node "node"
        node: string
        return: list of connections list of connection lists [["con1","n1", "n2"], ["con2","n1", "n4"],...]
    """
    rel_node_connection = "NodeConnectionRelationship"
    # rels = jfo[rel_node_connection]
    rels = eval(parse(:($rel_node_connection)))
    nodecons=[p for p in rels if p[1] == node]
    list_of_pairs=[]
    if add_permutation
        for p in nodecons
            for con in p.second
                push!(list_of_pairs, [con, rels[con][1],rels[con][2]])
                push!(list_of_pairs, [con, rels[con][2],rels[con][1]])
            end
        end
    else
        for p in nodecons
            for con in p.second
                push!(list_of_pairs, [con, rels[con][1],rels[con][2]])
            end
        end
    end
    return list_of_pairs
end

function get_all_connection_node_pairs(add_permutation=false)
    """"
    returns all pairs of nodes which are connected through a connections
        add_permutation: add an additional entry with permuted nodes e.g. ["con1","n1", "n2"], ["con1","n2", "n1"]
        return: list of connection lists [["con1","n1", "n2"], ["con2","n3", "n4"],...]
    """
    list_of_pairs=[]
    for c in connection()
        list_of_pairs=vcat(list_of_pairs, [vcat(c,p) for p in find_nodes(c,add_permutation)])
    end
    return list_of_pairs
end

function get_units_of_unitgroup(unitgroup)
    #giving relationship names as string -> todo: change
    unitgroup_unit_relationship_name="UnitGroup_Unit_rel"
    # jfo[relationship_name][unitgroup]
    eval(parse(:($unitgroup_unit_relationship_name)))(unitgroup)
end

function get_com_node_unit_in()
    """
        return list of connection list of all unit node connections [Commodity, Node, Unit, in/out]
        e.g. [["Coal", "BelgiumCoal", "CoalPlant", "in"], ["Electricity", "LeuvenElectricity", "CoalPlant", "out"],...]
    """
    #giving relationship names as string -> todo: change
    NodeUnitConnection_relationship_name = "NodeUnitConnection"
    CommodityAffiliation_relationship_name = "CommodityAffiliation"
    input_com_relationship_name = "input_com"
    output_com_relationship_name = "output_com"
    #
    list_of_connections = []
    for u in unit()
        for n in eval(parse(:($NodeUnitConnection_relationship_name)))(u)
            for c in eval(parse(:($CommodityAffiliation_relationship_name)))(n)
                if c in eval(parse(:($input_com_relationship_name)))(u)
                    push!(list_of_connections, [c,n,u,"in"])
                end
                if c in eval(parse(:($output_com_relationship_name)))(u)
                    push!(list_of_connections, [c,n,u,"out"])
                end
            end
        end
    end
    return list_of_connections
end
