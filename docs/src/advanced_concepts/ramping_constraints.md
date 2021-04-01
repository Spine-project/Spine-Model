# Ramping concept

To enable the representation of units with a high level of technical detail, the ramping ability of units can be constrained in SpineOpt. This means that the user has the freedom to impose restrictions on the change in output of units between consecutive timesteps, for online (spinning) units, units starting up and units shutting down. In this section, the concept of ramps in SpineOpt will be introduced. Furthermore, the use of reserves will be explained.

## Relevant objects, relationships and parameters

Note: this is not entirely true, one can also implement ramps on the unit\__from node relationships. (Would move this to the list elements). Also I think it'd be important, when listing this, that it can be defined on both a unit - node relationship, but (similarly to the unit capacity) can be defined on a unit - node group aswell. This will be important for explaining how reserves work

Everything that is related to ramping is defined in parameters of either the [unit\_\_to\_node](@ref), [unit\_\_from\_node](@ref), or [unit\_\_to\_node_group](@ref) relationship. Generally speaking, the ramping constraints will impose restrictions on the change in the [`unit_flow`](@ref) variable between two consecutive timesteps.

All parameters that limit the ramping abilities of a unit are expressed as a fraction of the unit capacity. This means that a value of 1 indicates the full capacity of a unit.

 The discussion here will be kept conceptual, for the mathematical formulation the reader is referred to the [Ramping and reserve constraints](@ref)

### Constraining spinning ramps (would probably name this one first, as maybe most familiar to people)

 * [`unit_capacity`](@ref): limit the maximum value of the `unit_flow` variable for a unit which is currently online. Inclusion of this parameter will trigger the creation of the [technology capacity](@ref) constraint.
 * [`ramp_up_limit`](@ref) : limit the maximum increase in the `unit_flow` variable between two consecutive timesteps for which the unit is online. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on spinning upward ramps](@ref)
 * [`ramp_down_limit`](@ref) : limit the maximum decrease in the `unit_flow` variable between two consecutive timesteps for which the unit is online. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on spinning downward ramps](@ref)

 * [`ramp_up_cost`](@ref) : cost associated with upward ramping
 * [`ramp_down_cost`](@ref) : cost associated with downward ramping


### Constraining shutdown ramps
  * [`max_shutdown_ramp`](@ref) : limit the maximum of the `unit_flow` variable the timestep right before a shutdown. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on maximum downward shut down ramps](@ref)
  * [`min_shutdown_ramp`](@ref) : limit the minimum of the `unit_flow` variable the timestep right before a shutdown. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on minimum downward shut down ramps](@ref)

### Constraining startup ramps
  * [`max_start_up_ramp`](@ref) : limit the maximum of the `unit_flow` variable the timestep right after a start-up. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on maximum upward start up ramps](@ref)
  * [`min_start_up_ramp`](@ref) : limit the minimum of the `unit_flow` variable the timestep right after a start-up. The parameter is given as a fraction of the [unit\_flow\_capacity](@ref) parameter. Inclusion of this parameter will trigger the creation of the [Constraint on minimum upward start up ramps](@ref))

## General principle and example use cases
The general principle of the Spine modelling ramping constraints is that all of these parameters can be defined separately for each unit. This allows the user to incorporate different units (which can either represent a single unit or a technology type) with different flexibility characteristics.

It should be noted that it is perfectly possible to omit all of the constraining parameters mentioned above. However, once either of the ramping parameters is defined, it is necessary to also assign values to the other parameters. E.g. if a user only wants to restrict the spinning ramp up capability of a unit, one also has to assign values to the `max_startup_ramp`, `min_Shutdown_Ramp` etc.
### Illustrative examples
#### Step 1: Simple case of unrestricted unit
When none of the ramping parameters mentioned above are defined, the unit is considered to have full ramping flexibility. This means that in any given timestep, its output can be any value between 0 and its capacity, regardless of what the output of the unit was in the previous timestep, and regardless of the on- or offline status or the unit in the previous timestep. Provided that this does not conflict with the [unit_commitment](@ref) restrictions that are defined for this unit. Parameter values for a `unit__node` relationship are illustratively given below.
* `max_shutdown_ramp`  : 1
* `min_shutdown_ramp`  : 0
* `max_start_up_ramp`  : 1
* `min_start_up_ramp`  : 0
* `ramp_up_limit`      : 1
* `ramp_down_limit`    : 1
* `unit_capacity`      : 200

#### Step 2: Spinning ramp restriction
A unit which is only restricted in spinning ramping can be created by changing the `ramp_up/down_limit` parameters: (btw, I like this example!)

 * `ramp_up_limit`      : **0.2**
 * `ramp_down_limit`    : **0.4**

 This parameter choice implies that the unit's output between two consecutive timesteps can change with no more than ``0.2  * 200`` and no less than ``0.4 * 200``. For example, when the unit is running at an output of ``100`` in some timestep ``t``, its output for the next timestep must be somewhere in the interval ``[20,140]``. Unless it shuts down completely.

#### Step 3: Shutdown restrictions

 By changing the parameter `max_shutdown_ramp` in the previous example, an additional restriction is imposed on the maximum output of the unit from which it can go offline.

 * `max_shutdown_ramp`      : **0.5**
 * `max_shutdown_ramp`    :   **0.3**

 When this unit goes offline in a given timestep ``t+1``, the output of the unit must be below ``0.5*200 = 100`` in the timestep ``t`` before that.
 Similarly, the parameter `min_shutdown_ramp` can be used to impose a minimum output value in the timestep  before a shutdown. For example, a value of ``0.3`` in this example would mean that the unit can not be running below an output of ``60`` in timestep ``t``.

#### Step 4: Startup restrictions

 The startup restrictions are very similar to the shutdown restrictions, but of course apply to units that are starting up. Consider for example the same unit as in the example above, but now with a `max_start_up_ramp` equal to ``0.4`` and `min_start_up_ramp` equal to ``0.2``:

 * `max_start_up_ramp`      : **0.4**
 * `min_start_up_ramp`    :   **0.2**

When the unit is offline in timestep ``t`` and comes online in timestep ``t+1``, its output in timestep ``t+1`` will be restricted to the interval ``[40,80]``.

# Reserve concept
To include a requirement of reserve provision in a model, SpineOpt offers the possibility of creating reserve nodes. Of course reserve provision is different from regular operation, because the reserved capacity does not actually get activated. In this section, we will take a look at the things that are particular for a reserve node.

## Defining a reserve node

To define a reserve node, the following parameters have to be defined for the relevant node:

* `is_reserve_node`  : this boolean parameter indicates that this node is a reserve node.
* `upward_reserve`  : this boolean parameter indicates that the demand for reserve provision of this node concerns upward reserves.
* `downward_reserve`  : this boolean parameter indicates that the demand for reserve provision of this node concerns downward reserves.
* `balance_type`: this parameter indicates the balance_type of the node
* `reserve_procurement_cost`: (optional) **to be checked how this enters the calculation, I can't see it in the objective**

## Defining a node group

SpineOpt allows the user to constrain ramping abilities of units that are linked to multiple nodes by defining node groups. This is especially relevant for reserve provision because a unit that provides reserves is linked to a regular, as well as a reserve node. It is then possible to constrain the unit's ramping for the combination of regular operation and reserve provision.

Since reserve provision in fact literally reserves part of the capacity of a unit, the demand of the reserve node will be subtracted from the part that is available for regular operation. The section below will discuss how this works in SpineOpt by means of an example.

Since the demand of the nodes is defined on the individual node level (and the node group has no demand), the balance type of the group node should be set to `balance_type_none`.

## Ramping constraints on a node group with one reserve node

### Reserves step 1: simple case of unrestricted unit

Let's assume that we have one unit and two nodes in a model, one for reserves and one for regular demand. The unit is then linked by the `unit__to_node` relationships to each node individually, and on top of that, it is linked to a node group containing both nodes.

The ramping of the unit can now be constrained by defining the same parameters as before, but now for the node group. As before, the simplest case is a unit that is only restricted by its capacity:

* `max_shutdown_ramp`  : 1
* `min_shutdown_ramp`  : 0
* `max_start_up_ramp`  : 1
* `min_start_up_ramp`  : 0
* `ramp_up_limit`      : 1
* `ramp_down_limit`    : 1
* `unit_capacity`      : 200

The capacity restriction now implies that the sum of the reserve demand and regular demand cannot exceed the capacity of the unit. For example: when the reserve node has a demand of ```10``` in timestep ```t```, the `unit_flow` variable to the regular node must be smaller than or equal to ```190```.

#### Reserves step 2: Spinning ramp restriction

The unit can be restricted only in spinning ramping, as in the previous example, by defining the `ramp_up/down_limit` parameters in the `unit__to_node` relationship **for the node group**:

 * `ramp_up_limit`      : **0.2**
 * `ramp_down_limit`    : **0.4**

 This parameter choice implies that the unit's flow to the regular demand node between two consecutive timesteps can change with no more than ``0.2  * 200 - upward_reserve_demand`` and no less than ``0.4 * 200 - downward_reserve_demand``. For example, when the unit is running at an output of ``100`` in some timestep ``t``, and there is an upward reserve demand of ```10``` its output for the next timestep must be somewhere in the interval ``[20,130]``.

 It can be seen in this example that the demand for reserves is subtracted from both the generation capacity, and the ramping capacity of the unit that is available for regular operation. This stems from the fact that in providing reserve capacity, the unit is expected to be able to provide the demanded reserve within one timestep.

#### Reserves Step 3: Non-spinning reserves

Units can also be allowed to provide non-spinning reserves, through shutdowns and startups. This can be done by using the following parameters in the `unit__to_node` relationship **for the reserve node** :  

  * `max_res_startup_ramp`
  * `min_res_startup_ramp`

  * `max_res_shutdown_ramp`
  * `min_res_shutdown_ramp`

  * `unit_capacity`

These parameters are constraining reserve provision in exactly the same way as their equivalents for regular operation. Note that it is now necessary to define a capacity of the unit with respect to the reserve node. The ramping parameters will then be interpreted as fractions of this specific capacity, which can be taken different than the units overall capacity with respect to the node group.

A unit which can provide both spinning and non-spinning reserves can be defined as follows:

**Parameters to be defined for unit to node group relationship**
* `max_shutdown_ramp`  : 1
* `min_shutdown_ramp`  : 0
* `max_start_up_ramp`  : 1
* `min_start_up_ramp`  : 0
* `ramp_up_limit`      : 0.2
* `ramp_down_limit`    : 0.4
* `unit_capacity`      : 200

**Parameters to be defined for unit to reserve node relationship**

* `max_res_startup_ramp`: 0.5
* `min_res_startup_ramp`: 0.1
* `unit_capacity`: 150

The spinning reserve and ramping restrictions now remain the same as above, but on top of that the unit is able to provide non-spinning upward reserves when it is offline. In this particular example, the contribution of the offline unit to upward reserves can be anything in the interval ```[15,75]```.

# Using node_groups for both combined and individual restrictions

It can be seen from the example above that when a node group is defined, ramping restrictions can be imposed both on the group level (thus for the nit as a whole) as well as for the individual nodes. If, for example a `ramp-up-limit` is defined for the node group, the sum of upward ramping of the two nodes will be restricted by this parameter, but it is still possible to limit the individual flows to the nodes as well. We will now discuss an example of this for the `ramp_up_limit`, but this also holds for other parameters.

Let's continue with the example above, where an online unit is capable of ramping up by 20% of its capacity and down by 40%. We might want to impose tighter restrictions for upward reserve provision than the ramping in overall operation (e.g. because the reserved capacity has to be available in a shorter time than the duration_unit). One can then simply define an additional parameter for the unit to reserve node relationship as follows.

* `ramp_up_limit`  : 0.15

Which now restricts the spinning upward ramping provision of the unit to 15% of its capacity, as defined for the reserve node. In this case, the `change in the unit's flow to the regular demand node` between two consecutive timesteps is still limited to the interval ```[0.2  * 200 - upward_reserve_demand, 0.4 * 200 - downward_reserve_demand]```. But the upward reserves that it can provide has an upper bound of ```150 * 0.15``.
