using CSV
using DataFrames

# filename = readline()
filename = "storage/dataset_train.csv"

if isfile(filename)
    data = CSV.read(filename, DataFrame)
end




data = select(data, findall(col -> eltype(col) <: Union{Int64, Missing, Float64}, eachcol(data)))
# stats = DataFrame(Metric = ["Count", "Mean", "Std", "Min", "25%", "50%", "75%", "Max"])
# n = size(stats)[2]
column_names = names(data)
# for name in columns
#     stats[!, name] = zeros(8)
# end
#
# count = 0.0
# for row in eachrow(data)
#     i = 1
#     for val in row
#         stats[!, columns[i]][1] += 1.0
#         i += 1
#     end
# end

stats = DataFrame(features = column_names)
stats[!, :Count] .= 0.0
stats[!, :Mean] .= 0.0
stats[!, :Std] .= 0.0

i = 1
for column in eachcol(data)
    count = 0
    total = 0
    empty = 0
    for val in column
        if !ismissing(val)
            total += val
        else
            empty += 1
        end
        count += 1
    end
    mean = (total - empty) / count
    stats[stats[!, :features] .== column_names[i], :Count] = count
    stats[stats[!, :features] .== column_names[i], :Mean] = mean
    i += 1
end

i = 1
for column in eachcol(data)
    sum_of_squares = 0.0
    for val in column
        if !ismissing(val)
            sum_of_squares += (val - stats[!, :Mean][i])^2
        end
    end
    stats[stats[!, :features] .== column_names[i], :Std] .= sum_of_squares / stats[!, :Count][i]
    i += 1
end

println(stats)

print(describe(data))
print(head(data))
