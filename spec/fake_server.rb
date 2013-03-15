count = 0

get "/" do
  200
end

delete "/" do
  count = 0
  200
end

get "/unreliable/:max" do |max|
  max = Integer(max)
  count += 1
  if count <= max
    sleep 5
    "slow"
  else
    "fast"
  end
end
