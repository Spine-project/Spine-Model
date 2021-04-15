`online_variable_type` is a method parameter closely related to the [number\_of\_units](@ref) and can take the values "unit\_online\_variable\_type\_binary", "unit\_online\_variable\_type\_integer", "unit\_online\_variable\_type\_linear". If the binary value is chosen, the units status is modelled as a binary (classic UC). For clustered unit commitment units, the integer type is applicable. Note that if the parameter is not defined, the default will be linear. If the units status is not crucial, this can reduce the computational burden.