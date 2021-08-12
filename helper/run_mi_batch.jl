using ArgParse
using Base.Filesystem
using Glob
import JSON
using Logging

function parse_cli()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--input", "-i"
            required = true
        "--output", "-o"
            required = true
    end
    parse_args(s)
end

function execute_mi(input, output)
    dir = mktempdir(".";cleanup=false)
    outdir = mktempdir(".";cleanup=false)
    @info "creating $dir and $outdir"
    for (i, l) in enumerate(readlines(input))
        name = joinpath(dir, "input$(i)d.tre")
        open(name, "w+") do f
            write(f, l)
        end
    end
    #run(`python scripts/prune_paralogs_MI.py $dir "" inf inf 4 $outdir`)
    scriptpath = joinpath(@__DIR__,"..","scripts","prune_paralogs_MI.py")
    try
        cmd = `python $scriptpath $dir "" inf inf 4 $outdir`
        @info "running with $cmd on $input"
        run(cmd)
    catch e
        bt = catch_backtrace()
        msg = sprint(showerror, e, bt)
        println(msg)
        println("on $input crashed!")
    end
    sizes = []
    open(output, "w+") do f
        for (i, l) in enumerate(readlines(input))
            inputs = glob("input$(i)d*.tre", outdir)
            decomposed = []
            for j=inputs
                push!(decomposed, rstrip(read(j, String)))
            end
            push!(sizes, length(decomposed))
            for d=decomposed
                println(f, d)
            end
        end
    end
    open(output * ".size.json", "w+") do f
        JSON.print(f, sizes)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    args = parse_cli()
    execute_mi(args["input"], args["output"])
end
