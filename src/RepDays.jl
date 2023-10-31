module RepDays

greet() = print("Hello World!")

function generate_ldc(hours::Int, days::Int)
  hotday = round(days / 2)
  hothour = round(hours * 5 / 6)
  area_mean = rand()
  day = zeros(days)
  day[1] = 2 * area_mean / 3 + (cos(abs(1 - hotday) / hotday)) / 2 + rand()
  for i in 2:days
    day[i] = (day[i-1] + area_mean + cos(abs(i - hotday) / hotday)) / 3 # + rand()
  end
  return (day)
end

end # module RepDays
