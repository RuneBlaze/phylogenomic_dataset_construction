using Distributed

input = ARGS[1]


function sendto(p::Int; args...)
    for (nm, val) in args
        @spawnat(p, eval(Main, Expr(:(=), nm, val)))
    end
end


function sendto(ps::Vector{Int}; args...)
    for p in ps
        sendto(p; args...)
    end
end

#sendto(workers(), input=input)

#@everywhere println(input)

@everywhere begin
    using Logging
    include(joinpath(@__DIR__,"run_mi_batch.jl"))
    est = glob(joinpath($input, "*", "g_100.trees"))
    tru = glob(joinpath($input, "*", "g_true.trees"))
end

@distributed for i in vcat(est, tru)
    @info "executing on $i"
    flush(stdout)
    execute_mi(i, i * ".mi")
end
