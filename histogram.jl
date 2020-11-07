using CSV
using DataFrames
using Plots

# filename = readline()
filename = "storage/dataset_train.csv"

if isfile(filename)
    data = CSV.read(filename, DataFrame)
end

println(names(data))

p1 = histogram(data[:"Hogwarts House"], data[:"Arithmancy"])
plot(p1)