var documenterSearchIndex = {"docs":
[{"location":"#SpineModel.jl-1","page":"Home","title":"SpineModel.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"The Spine Model generator.","category":"page"},{"location":"#","page":"Home","title":"Home","text":"A package to generate and run the Spine Model for energy system integration problems.","category":"page"},{"location":"#Package-features-1","page":"Home","title":"Package features","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Builds the model entirely from a database using Spine Model specific data structure.\nUses JuMP.jl to build and solve the optimization model.\nWrites results to the same input database or to a different one.\nThe model can be extended with additional constraints written in JuMP.\nSupports Julia 1.0.","category":"page"},{"location":"#Library-outline-1","page":"Home","title":"Library outline","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"Pages = [\"library.md\"]\r\nDepth = 3","category":"page"},{"location":"library/#Library-1","page":"Library","title":"Library","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"Documentation for SpineModel.jl.","category":"page"},{"location":"library/#Contents-1","page":"Library","title":"Contents","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"Pages = [\"library.md\"]\r\nDepth = 3","category":"page"},{"location":"library/#Index-1","page":"Library","title":"Index","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"","category":"page"},{"location":"library/#Public-interface-1","page":"Library","title":"Public interface","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"run_spinemodel(::String, ::String)\r\nrun_spinemodel(::String)","category":"page"},{"location":"library/#SpineModel.run_spinemodel-Tuple{String,String}","page":"Library","title":"SpineModel.run_spinemodel","text":"run_spinemodel(\n    url_in, url_out;\n    optimizer=Cbc.Optimizer,\n    cleanup=true,\n    extend=m->nothing,\n    result=\"\"\n)\n\nRun the Spine model from url_in and write results to url_out. At least url_in must point to valid Spine database. A new Spine database is created at url_out if it doesn't exist.\n\nOptional keyword arguments\n\noptimizer is the constructor of the optimizer used for building and solving the model.\n\ncleanup tells run_spinemodel whether or not convenience function callables should be set to nothing after completion.\n\nextend is a function for extending the model. run_spinemodel calls this function with the internal JuMP.Model object before calling JuMP.optimize!.\n\nresult is the name of the result object to write to url_out when saving results. An empty string (the default) gets replaced by \"result\" with the current time appended.\n\n\n\n\n\n","category":"method"},{"location":"library/#SpineModel.run_spinemodel-Tuple{String}","page":"Library","title":"SpineModel.run_spinemodel","text":"run_spinemodel(\n    url;\n    optimizer=Cbc.Optimizer,\n    cleanup=true,\n    extend=m->nothing,\n    result=\"\"\n)\n\nRun the Spine model from url and write results to the same url. Keyword arguments have the same purpose as for run_spinemodel.\n\n\n\n\n\n","category":"method"},{"location":"library/#Internals-1","page":"Library","title":"Internals","text":"","category":"section"},{"location":"library/#Variables-1","page":"Library","title":"Variables","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"variable_flow\r\nvariable_trans\r\nvariable_units_on\r\nflow_indices\r\nvar_flow_indices\r\nfix_flow_indices\r\ntrans_indices\r\nvar_trans_indices\r\nfix_trans_indices\r\nunits_on_indices\r\nvar_units_on_indices\r\nfix_units_on_indices","category":"page"},{"location":"library/#SpineModel.variable_flow","page":"Library","title":"SpineModel.variable_flow","text":"variable_flow(m::Model)\n\nCreate the flow variable for the model m.\n\nThis variable represents the (average) instantaneous flow of a commodity between a node and a unit in a certain direction and within a certain time slice.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.variable_trans","page":"Library","title":"SpineModel.variable_trans","text":"variable_trans(m::Model)\n\nCreate the trans variable for model m.\n\nThis variable represents the (average) instantaneous flow of a commodity between a node and a connection in a certain direction and within a certain time slice.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.variable_units_on","page":"Library","title":"SpineModel.variable_units_on","text":"variable_units_on(m::Model)\n\nCreate the units_on variable for model m.\n\nThis variable represents the number of online units for a given unit within a certain time slice.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.flow_indices","page":"Library","title":"SpineModel.flow_indices","text":"flow_indices(\n    commodity=anything,\n    node=anything,\n    unit=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to indices of the flow variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.var_flow_indices","page":"Library","title":"SpineModel.var_flow_indices","text":"var_flow_indices(\n    commodity=anything,\n    node=anything,\n    unit=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to non-fixed indices of the flow variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.fix_flow_indices","page":"Library","title":"SpineModel.fix_flow_indices","text":"fix_flow_indices(\n    commodity=anything,\n    node=anything,\n    unit=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to fixed indices of the flow variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.trans_indices","page":"Library","title":"SpineModel.trans_indices","text":"trans_indices(\n    commodity=anything,\n    node=anything,\n    connection=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to indices of the trans variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.var_trans_indices","page":"Library","title":"SpineModel.var_trans_indices","text":"var_trans_indices(\n    commodity=anything,\n    node=anything,\n    connection=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to non-fixed indices of the trans variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.fix_trans_indices","page":"Library","title":"SpineModel.fix_trans_indices","text":"fix_trans_indices(\n    commodity=anything,\n    node=anything,\n    connection=anything,\n    direction=anything,\n    t=anything\n)\n\nA list of NamedTuples corresponding to fixed indices of the trans variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.units_on_indices","page":"Library","title":"SpineModel.units_on_indices","text":"units_on_indices(unit=anything, t=anything)\n\nA list of NamedTuples corresponding to indices of the units_on variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.var_units_on_indices","page":"Library","title":"SpineModel.var_units_on_indices","text":"var_units_on_indices(unit=anything, t=anything)\n\nA list of NamedTuples corresponding to non_fixed indices of the units_on variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#SpineModel.fix_units_on_indices","page":"Library","title":"SpineModel.fix_units_on_indices","text":"fix_units_on_indices(unit=anything, t=anything)\n\nA list of NamedTuples corresponding to fixed indices of the units_on variable. The keyword arguments act as filters for each dimension.\n\n\n\n\n\n","category":"function"},{"location":"library/#Constraints-1","page":"Library","title":"Constraints","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"TODO","category":"page"},{"location":"library/#Objectives-1","page":"Library","title":"Objectives","text":"","category":"section"},{"location":"library/#","page":"Library","title":"Library","text":"TODO","category":"page"}]
}
