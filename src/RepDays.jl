module RepDays

using Plots
using DataFrames
greet() = print("Hello World!")

struct cluster
  elements::Array{Float64,2}
  n::Int
  centeroid::Array{Float64,2}
  representative::Int
end

function cluster(elements::Array{Float64,2})
  n = size(elements, 1)
  centeroid = sum(elements, dims=1) ./ size(elements, 1)
  dists = [sum((elements[i, :]' .- centeroid) .^ 2) for i in axes(elements, 1)]
  representative = argmin(dists)
  return cluster(elements, n, centeroid, representative)
end

function generate_ldc(hours::Int, days::Int)
  hotday = round(days / 2)
  hothour = 3 / 4
  area_mean = abs(rand()) * 4
  @show area_mean
  day = zeros(days)
  day[1] = (2 * area_mean + cos(pi * (1 / hotday - 1))) / 3 + rand()
  for i in 2:days
    day[i] = (day[i-1] + area_mean + cos(pi * (i / hotday - 1))) / 3 + rand()
  end
  # return (day)
  dh = zeros(days, hours)
  dh[1, 1] = (2 * day[1] + cos(2 * pi * (1 / hours - 1))) / 3 + rand() / 3
  for i in 1:days, j in 1:hours
    if j == 1
      j_prev = hours
      i_prev = max(i - 1, 1)
    else
      j_prev = j - 1
      i_prev = i
    end
    dh[i, j] = (day[i] + dh[i_prev, j_prev] + cos(2 * pi * (j / hours - hothour))) / 3 + rand() / 3
  end
  dh = dh .- minimum(dh)
  dh = dh ./ maximum(dh)
  return (dh)
end

function hm(data)
  heatmap(1:size(data, 1),
    1:size(data, 2), data,
    c=cgrad([:blue, :red]),
    xlabel="day", ylabel="hour")
end

function dist(A, B)
  return (sum((A .- B) .^ 2))
end

function findclosest(dh::Array)
  dists = [ifelse(i < j, dist(dh[i, :], dh[j, :]), missing) for i in 1:size(dh, 1), j in 1:size(dh, 1)]
  return (dists)
end

function find_clusters(dh, nclusters)
  dh_original = deepcopy(dh)
  ndays = size(dh, 1)
  clusters = zeros(Int, ndays, ndays - nclusters + 1)
  clusters[:, 1] = 1:ndays
  cluster_size = zeros(Int, ndays, ndays - nclusters + 1)
  cluster_size[:, 1] .= 1
  dists = findclosest(dh)

  for c in 2:(ndays-nclusters+1)
    # display(dists)
    cindex = argmin(skipmissing(dists))
    pair = [cindex[1]; cindex[2]]
    # @show pair
    centeroid = cluster_size[pair, c-1]' * dh[pair, :] ./ sum(cluster_size[pair, c-1])
    # @show centeroid
    # update clusters
    clusters[:, c] = clusters[:, c-1]
    clusters[clusters[:, c-1].==pair[2], c] .= pair[1]
    # update cluster_size
    cluster_size[:, c] = cluster_size[:, c-1]
    cluster_size[pair[1], c] += cluster_size[pair[2], c-1]
    cluster_size[pair[2], c] = 0
    # update points
    dh[pair[1], :] = centeroid
    # update dist
    for i in 1:(pair[1]-1)
      if cluster_size[i, c] > 0
        dists[i, pair[1]] = dist(dh[i, :], dh[pair[1], :])
      else
        dists[i, pair[1]] = missing
      end
    end
    for i in (pair[1]+1):ndays
      if cluster_size[i, c] > 0
        dists[pair[1], i] = dist(dh[i, :], dh[pair[1], :])
      else
        dists[pair[1], i] = missing
      end
    end
    dists[pair[2], :] .= missing
    dists[:, pair[2]] .= missing
  end
  for i in unique(clusters[:, end])
    @show i
    ind = findall(clusters[:, end] .== i)
    @show ind
    @show cluster(dh_original[ind, :])
  end
  output = [cluster(dh[findall(clusters[:, end] .== i), :]) for i in unique(clusters[:, end])]
  return (output)
end

end # module RepDays
