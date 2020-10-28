using CSV
using DataFrames

# filename = readline()
filename = "storage/dataset_train.csv"

if isfile(filename)
    data = CSV.read(filename, DataFrame)
end

# Collect data and build desc dataframe
selection = findall(col -> eltype(col) <: Union{Number, Missing}, eachcol(data))
select!(data, selection)
desc = DataFrame(features = names(data))
for agg in [:Count, :Mean, :Std, :Min, :"25%", :"50%", :"75%", :Max]
    desc[!, agg] .= 0.0
end
desc[!, :Min] .= Inf
desc[!, :Max] .= -Inf

# Get all aggregates
for (i, column) in enumerate(eachcol(data))
    column = skipmissing(sort!(column))
    total = 0
    for val in column
        total += val
        desc[!, :Min][i] = (val < desc[!, :Min][i]) ? val : desc[!, :Min][i]
        desc[!, :Max][i] = (val > desc[!, :Max][i]) ? val : desc[!, :Max][i]
        desc[!, :Count][i] += 1
    end
    desc[!, :Mean][i] = total / desc[!, :Count][i]
    desc[!, :Std][i] = sqrt(sum((column .- desc[!, :Mean][i]).^2) / (desc[!, :Count][i] - 1))
    desc[!, :"25%"][i] = column[floor(Int, desc[!, :Count][i] * 0.25)]
    desc[!, :"50%"][i] = column[floor(Int, desc[!, :Count][i] * 0.50)]
    desc[!, :"75%"][i] = column[floor(Int, desc[!, :Count][i] * 0.75)]
end

println(desc)
print(describe(data))
print(first(data, 20))
