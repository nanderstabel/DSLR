using CSV
using DataFrames

# filename = readline()
filename = "storage/dataset_train.csv"

if isfile(filename)
    data = CSV.read(filename, DataFrame)
end

data = sort(select(data, findall(col -> eltype(col) <: Union{Int64, Missing, Float64}, eachcol(data))))
# data = first(data, 5)
features = names(data)
metrics = [:Count, :Mean, :Std, :Min, :"25%", :"50%", :"75%", :Max]
stats = DataFrame(features = features)
for metric in metrics
    stats[!, metric] .= 0.0
end
stats[!, :Min] .= Inf
stats[!, :Max] .= -Inf

i = 1
for column in eachcol(data)
    total, empty = 0, 0
    for val in column
        if !ismissing(val)
            total += val
            stats[!, :Min][i] = min(stats[!, :Min][i], val)
            stats[!, :Max][i] = max(stats[!, :Max][i], val)
        else
            empty += 1
        end
        stats[!, :Count][i] += 1
    end
    stats[!, :Mean][i] = total / (stats[!, :Count][i] - empty)
    i += 1
end

i = 1
for column in eachcol(data)
    sum_of_squares, empty = 0, 0
    for val in column
        if !ismissing(val)
            sum_of_squares += (val - stats[!, :Mean][i])^2
        else
            empty += 1
        end
    end
    stats[!, :Std][i] = sqrt(sum_of_squares / (stats[!, :Count][i] - empty - 1))
    i += 1
end

println(stats)
print(describe(data))
# print(data)
