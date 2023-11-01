module RepDays

using Plots
greet() = print("Hello World!")

function generate_ldc(hours::Int, days::Int)
  hotday = round(days / 2)
  hothour = round(hours * 5 / 6)
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
    dh[i, j] = (day[i] + dh[i_prev, j_prev] + cos(2 * pi * (j / hours - 5 / 6))) / 3 + rand() / 3
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

dists = [rd.dist(dh[i, :], dh[j, :]) for i in 1:size(dh, 1), j in 1:size(dh, 1)]

end # module RepDays
