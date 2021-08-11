using ArgParse
using Base.Filesystem
using Glob

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

args = parse_cli()
dir = tempdir()
outdir = tempdir()
mkdir(dir)
for (i, l) in enumerate(readlines(args.input))
    name = joinpath(dir, "input$(i)d.tre")
    open(name, "w+") do f
        write(f, l)
    end
end

run(`python scripts/prune_paralogs_MI.py $dir "" inf inf 4 $outdir`)
sizes = []
open(args.output, "w+") do f
    for (i, l) in enumerate(readlines(args.input))
        inputs = glob("outdir/input$(i)d*.tre")
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

open(args.output + ".size.json", "w+") do f
    JSON.print(f, sizes)
end

rm(dir; recursive = true)
rm(outdir; recursive = true)