function evaluate_decision(structure::VerticalBlockStructure, decision::AbstractVector)
    # Evalaute decision stage-wise
    cᵀx = _eval_first_stage(structure, decision)
    𝔼Q = _eval_second_stages(structure, decision, objective_sense(structure.first_stage))
    return cᵀx + 𝔼Q
end

function statistically_evalute_decision(structure::VerticalBlockStructure, decision::AbstractVector)
    # Evalaute decision stage-wise
    cᵀx = _eval_first_stage(structure, decision)
    𝔼Q, σ = _stat_eval_second_stages(structure, decision, objective_sense(structure.first_stage))
    return cᵀx + 𝔼Q, σ
end

function _eval_first_stage(structure::VerticalBlockStructure, decision::AbstractVector)
    # Update decisions (checks handled by first-stage model)
    take_decisions!(structure.first_stage,
                    all_decision_variables(structure.first_stage),
                    decision)
    # Optimize first_stage model
    optimize!(structure.first_stage)
    # Return result
    status = termination_status(structure.first_stage)
    if status != MOI.OPTIMAL
        if status == MOI.INFEASIBLE
            return objective_sense(structure.first_stage) == MOI.MAX_SENSE ? -Inf : Inf
        elseif status == MOI.DUAL_INFEASIBLE
            return objective_sense(structure.first_stage) == MOI.MAX_SENSE ? Inf : -Inf
        else
            error("First-stage model could not be solved, returned status: $status")
        end
    end
    return objective_value(structure.first_stage)
end

function _eval_second_stages(structure::VerticalBlockStructure{2,1,Tuple{SP}},
                             decision::AbstractVector,
                             sense::MOI.OptimizationSense) where SP <: ScenarioProblems
    update_known_decisions!(structure.decisions[2], decision)
    map(subprob -> update_known_decisions!(subprob), subproblems(structure))
    return outcome_mean(subproblems(structure), probability.(scenarios(structure)), sense)
end
function _eval_second_stages(structure::VerticalBlockStructure{2,1,Tuple{SP}},
                             decision::AbstractVector,
                             sense::MOI.OptimizationSense) where SP <: DistributedScenarioProblems
    Qs = Vector{Float64}(undef, nworkers())
    sp = scenarioproblems(structure)
    @sync begin
        for (i,w) in enumerate(workers())
            @async Qs[i] = remotecall_fetch(
                w,
                sp[w-1],
                sp.decisions[w-1],
                decision,
                sense) do sp, d, x, sense
                    scenarioproblems = fetch(sp)
                    decisions = fetch(d)
                    num_scenarios(scenarioproblems) == 0 && return 0.0
                    update_known_decisions!(decisions, x)
                    map(subprob -> update_known_decisions!(subprob), subproblems(scenarioproblems))
                    return outcome_mean(subproblems(scenarioproblems),
                                        probability.(scenarios(scenarioproblems)),
                                        sense)
                end
        end
    end
    return sum(Qs)
end

function _stat_eval_second_stages(structure::VerticalBlockStructure{2,1,SP},
                                  decision::AbstractVector,
                                  sense::MOI.OptimizationSense) where SP <: ScenarioProblems
    update_known_decisions!(structure.decision, decision)
    map(subprob -> update_known_decisions!(subprob), subproblems(structure))
    return welford(subproblems(structure), probability.(scenarios(structure)), sense)
end
function _stat_eval_second_stages(structure::VerticalBlockStructure{2,1,SP},
                                  decision::AbstractVector,
                                  sense::MOI.OptimizationSense) where SP <: DistributedScenarioProblems
    partial_welfords = Vector{Tuple{Float64,Float64,Float64,Int}}(undef, nworkers())
    sp = scenarioproblems(structure)
    @sync begin
        for (i,w) in enumerate(workers())
            @async partial_welfords[i] = remotecall_fetch(
                w,
                sp[w-1],
                sp.decisions[w-1],
                decision,
                sense) do sp, d, x, sense
                    scenarioproblems = fetch(sp)
                    decisions = fetch(d)
                    num_scenarios(scenarioproblems) == 0 && return zero(eltype(x)), zero(eltype(x)), zero(eltype(x)), zero(Int)
                    update_known_decisions!(decisions, x)
                    map(subprob -> update_known_decisions!(subprob), subproblems(scenarioproblems))
                    return welford(subproblems(scenarioproblems), probability.(scenarios(scenarioproblems)), sense)
                end
        end
    end
    𝔼Q, σ², _ = reduce(aggregate_welford, partial_welfords)
    return 𝔼Q, sqrt(σ²)
end
