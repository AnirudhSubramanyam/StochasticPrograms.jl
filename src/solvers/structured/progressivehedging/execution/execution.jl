abstract type AbstractExecution end
abstract type Execution end
# Execution API #
# ------------------------------------------------------------
init_subproblems!(ph::AbstractProgressiveHedgingSolver, subsolver::QPSolver) = init_subproblems!(ph, subsolver, ph.execution)
iterate!(ph::AbstractProgressiveHedgingSolver) = iterate!(ph, ph.execution)
start_workers!(ph::AbstractProgressiveHedgingSolver) = start_workers!(ph, ph.execution)
close_workers!(ph::AbstractProgressiveHedgingSolver) = close_workers!(ph, ph.execution)
resolve_subproblems!(ph::AbstractProgressiveHedgingSolver) = resolve_subproblems!(ph, ph.execution)
update_iterate!(ph::AbstractProgressiveHedgingSolver) = update_iterate!(ph, ph.execution)
update_subproblems!(ph::AbstractProgressiveHedgingSolver) = update_subproblems!(ph, ph.execution)
update_dual_gap!(ph::AbstractProgressiveHedgingSolver) = update_dual_gap!(ph, ph.execution)
calculate_objective_value(ph::AbstractProgressiveHedgingSolver) = calculate_objective_value(ph, ph.execution)
fill_submodels!(ph::AbstractProgressiveHedgingSolver, scenarioproblems::AbstractScenarioProblems) = fill_submodels!(ph, scenarioproblems, ph.execution)
# ------------------------------------------------------------
include("common.jl")
include("serial.jl")
include("distributed.jl")
include("channels.jl")
include("worker.jl")
include("synchronous.jl")
include("asynchronous.jl")
