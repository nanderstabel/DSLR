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

# Formulae
m(p) = 1 - p
n(x) = size(x)[1]
j(x, p) = Int(floor(n(x)*p + m(p)))
γ(x, p) = n(x)*p + m(p) - j(x, p)
Q(x, p) = (1-γ(x, p))*x[j(x, p)] + γ(x, p)*x[j(x, p)+1]

# Get all aggregates
for (i, column) in enumerate(eachcol(data))
    column = collect(skipmissing(sort!(column)))
    total = 0
    for val in column
        total += val
        desc[!, :Min][i] = (val < desc[!, :Min][i]) ? val : desc[!, :Min][i]
        desc[!, :Max][i] = (val > desc[!, :Max][i]) ? val : desc[!, :Max][i]
        desc[!, :Count][i] += 1
    end
    desc[!, :Mean][i] = total / desc[!, :Count][i]
	desc[!, :Std][i] = sqrt(sum((column .- desc[!, :Mean][i]).^2) / 
		(desc[!, :Count][i] - 1))
    desc[!, :"25%"][i] =  Q(column, 0.25)
    desc[!, :"50%"][i] = Q(column, 0.50)
	desc[!, :"75%"][i] = Q(column, 0.75)
end

for (i, column) in enumerate(eachcol(data))
	for val in column
		@print("$i", val)
	end
end

# desc = DataFrame(permutedims(convert(Matrix, desc)))
# for column in desc

