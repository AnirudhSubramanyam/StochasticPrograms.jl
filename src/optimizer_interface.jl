# Structured optimizer interface
# ========================== #
"""
    supports_structure(optimizer::StochasticProgramOptimizerType, structure::AbstractStochasticStructure)

Return a `Bool` indicating whether `optimizer` supports the stochastic `structure`. That is, `load_structure!(optimizer, structure)` will not throw `UnsupportedStructure`
"""
function supports_structure(optimizer::StochasticProgramOptimizerType, structure::AbstractStochasticStructure)
    return false
end
"""
    check_loadable(optimizer::AbstractStructuredOptimizer, structure::AbstractStochasticStructure)

Throws an `UnloadableStructure` exception if `structure` is not loadable by `optimizer`.

    See also: [`load_structure!`](@ref)
"""
function check_loadable(optimizer::AbstractStructuredOptimizer)
    throw(MethodError(is_loadable, optimizer))
end
"""
    load_structure!(optimizer::AbstractStructuredOptimizer, structure::AbstractStochasticStructure, x₀::AbstractVector)

Instantiate the `optimizer` with the stochastic program represented in memory by the given `structure` and initial decision `x₀`.

See also: [`optimize!`](@ref)
"""
function load_structure!(optimizer::AbstractStructuredOptimizer, structure::AbstractStochasticStructure, x₀::AbstractVector)
    throw(MethodError(load_structure!, optimizer, structure, x₀))
end
"""
    restore_structure!(optimizer::AbstractStructuredOptimizer)

Restore the stochastic program to the state it was in before a call to `optimize!`

See also: [`load_structure!`](@ref)
"""
function restore_structure!(optimizer::AbstractStructuredOptimizer)
    throw(MethodError(restore_structure!, optimizer))
end
"""
    optimize!(optimizer::AbstractStructuredOptimizer)

Start the solution procedure for `optimizer` after a call to [`load_structure!`](@ref).

See also: [`load_structure!`](@ref)
"""
function optimize!(optimizer::AbstractStructuredOptimizer)
    throw(MethodError(optimize_structured!, optimizer))
end
"""
    optimizer_name(optimizer::AbstractStructuredOptimizer)

Optionally, return a string identifier of `AbstractStructuredOptimizer`.
"""
function optimizer_name(::AbstractStructuredOptimizer)
    return "SolverName() attribute not implemented by the optimizer."
end
"""
    master_optimizer(optimizer::AbstractStructuredOptimizer)

Return a MOI optimizer constructor
"""
function master_optimizer(optimizer::AbstractStructuredOptimizer)
    return throw(MethodError(master_optimizer, optimizer))
end
"""
   subproblem_optimizer(optimizer::AbstractStructuredOptimizer)

Return a MOI optimizer constructor for solving subproblems
"""
function subproblem_optimizer(optimizer::AbstractStructuredOptimizer)
    return throw(MethodError(subproblem_optimizer, optimizer))
end
# Sample-based solver interface
# ========================== #
"""
    load_model!(optimizer::AbstractSampledOptimizer, model::StochasticModel, x₀::AbstractVector)

Instantiate the `optimizer` with the stochastic model and initial decision `x₀`.

See also: [`optimize!`](@ref)
"""
function load_model!(optimizer::AbstractSampledOptimizer, model::StochasticModel, sampler::AbstractSampler, x₀::AbstractVector)
    throw(MethodError(load_model!, optimizer, sampler, model, x₀))
end
"""
    optimizer_name(optimizer::AbstractSampledOptimizer)

Optionally, return a string identifier of `AbstractSampledOptimizer`.
"""
function optimizer_name(::AbstractSampledOptimizer)
    return "SolverName() attribute not implemented by the optimizer."
end
"""
    optimal_instance(optimizer::AbstractSampledOptimizer)

Return a stochastic programming instance of the stochastic model after a call to [`optimize!`](@ref).
"""
function optimal_instance(::AbstractSampledOptimizer)
    return throw(MethodError(instance, optimizer))
end
