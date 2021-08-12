@everywhere begin
    using Logging
    include("run_mi_batch.jl")
    s = ArgParseSettings()
    @add_arg_table s begin
        "--input", "-i"
            required = true
    end
    args = parse_args(s)
    est = glob(joinpath(args["input"], "*", "g_100.trees"))
    tru = glob(joinpath(args["input"], "*", "g_true.trees"))
end

@distributed for i in vcat(est, tru)
    @info "executing on $i"
    # execute_mi(i, i * ".mi")
end