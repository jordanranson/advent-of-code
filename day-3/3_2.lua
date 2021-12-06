input_oxy = {}
input_co2 = {}

soln_bit_len = 0
soln_bit_counts = {}
soln_oxy_rating = '0b0'
soln_co2_rating = '0b0'

function filter_input (inp, x, val)
  local filtered = {}

  for y = 1, #inp do
    if sub(inp[y],x,x) == val then
      add(filtered, inp[y])
    end
  end

  return filtered
end

function _init ()
  -- prepare input
  input = input
  input_oxy = split(input, '\n', false)
  input_co2 = split(input, '\n', false)
  input = split(input, '\n', false)
  soln_bit_len = #input[1]

  -- filter
  local filtered
  for x = 1, soln_bit_len do

    soln_bit_counts = {}
    for i = 1, soln_bit_len do
      add(soln_bit_counts, {zero = 0, one = 0})
    end

    -- count them bits
    for y = 1, #input_oxy do
      if sub(input_oxy[y],x,x) == '0' then
        soln_bit_counts[x].zero += 1
      else
        soln_bit_counts[x].one += 1
      end
    end

    -- oxygen
    if soln_bit_counts[x].zero > soln_bit_counts[x].one then
      filtered = filter_input(input_oxy, x, '0')
    elseif soln_bit_counts[x].zero < soln_bit_counts[x].one then
      filtered = filter_input(input_oxy, x, '1')
    else
      filtered = filter_input(input_oxy, x, '1')
    end
    if #filtered > 0 then
      input_oxy = filtered
    end

    soln_bit_counts = {}
    for i = 1, soln_bit_len do
      add(soln_bit_counts, {zero = 0, one = 0})
    end

    -- count them bits again
    for y = 1, #input_co2 do
      if sub(input_co2[y],x,x) == '0' then
        soln_bit_counts[x].zero += 1
      else
        soln_bit_counts[x].one += 1
      end
    end

    -- co2
    if soln_bit_counts[x].zero > soln_bit_counts[x].one then
      filtered = filter_input(input_co2, x, '1')
    elseif soln_bit_counts[x].zero < soln_bit_counts[x].one then
      filtered = filter_input(input_co2, x, '0')
    else
      filtered = filter_input(input_co2, x, '0')
    end
    if #filtered > 0 then
      input_co2 = filtered
    end
  end

  -- total
  soln_oxy_rating = '0b' .. input_oxy[1]
  soln_co2_rating = '0b' .. input_co2[1]
end

function _draw ()
	cls(1)

  local color = 6

  print(soln_oxy_rating..' ('..tonum(soln_oxy_rating)..')', 0, 0, color)
  print(soln_co2_rating..' ('..tonum(soln_co2_rating)..')', 0, 6, color)
end
