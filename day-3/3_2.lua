soln_bit_len = 0
soln_bit_counts = {}
soln_most_common_bits = {}
soln_gamma_rate = '0b0'
soln_epsilon_rate = '0b0'
soln_oxygen_generator_rating = '0b0'
soln_co2_scrubber_rating = '0b0'
soln_step = 1
soln_stage = 1

function filter_by_bit (bytes, val, pos) 
  local filtered = {}

  for i = 1, #bytes do
    if sub(bytes[i],pos,pos) == val then
      add(filtered, bytes[i])
    end
  end

  return filtered
end
 
function flip_bit (val) 
  return (val + 1) % 2
end

function _init ()
  -- prepare input
  input = split(input, '\n', false)
  soln_bit_len = #input[1]

  -- prepare tables
  for i = 1, soln_bit_len do
    add(soln_bit_counts, {zero = 0, one = 0})
    add(soln_most_common_bits, 0)
  end
end

function _update60 ()
  if input[soln_step] == nil then return end

  -- count them bits
  for x = 1, soln_bit_len do
    if sub(input[soln_step],x,x) == '0' then
      soln_bit_counts[x].zero += 1
    else
      soln_bit_counts[x].one += 1
    end
  end

  -- find most/least common
  for x = 1, soln_bit_len do
    if soln_bit_counts[x].zero > soln_bit_counts[x].one then
      soln_most_common_bits[x] = 0
    else
      soln_most_common_bits[x] = 1
    end
  end

  -- power rates
  soln_gamma_rate = '0b'
  soln_epsilon_rate = '0b'

  for i = 1, soln_bit_len do
    soln_gamma_rate = soln_gamma_rate .. tostr(soln_most_common_bits[i])
    soln_epsilon_rate = soln_epsilon_rate .. tostr(flip_bit(soln_most_common_bits[i]))
  end

  -- life support/co2 scrubber
  local next_input
  local filtered = {}
  
  -- oxygen generator rating
  for i = 1, soln_bit_len do
    if i == 1 or #filtered != 1 then
      filter_by = '0'
      if soln_most_common_bits[i] == 1 then filter_by = '1' end

      next_input = filtered
      if i == 1 then next_input = input end

      filtered = filter_by_bit(next_input, filter_by, i)

      if #filtered == 1 then
        soln_oxygen_generator_rating = '0b' .. filtered[1]     
      end 
    end
  end
  
  -- co2 scrubber rating
  for i = 1, soln_bit_len do
    if i == 1 or #filtered != 1 then 
      filter_by = '1'
      if flip_bit(soln_most_common_bits[i]) == 0 then filter_by = '0' end

      next_input = filtered
      if i == 1 then next_input = input end

      filtered = filter_by_bit(next_input, filter_by, i)

      if #filtered == 1 then
        soln_co2_scrubber_rating = '0b' .. filtered[1]     
      end 
    end
  end

  -- next
  soln_step += 1
end

function _draw ()
	cls(1)

  local color = 6
  if input[soln_step] == nil then color = 8 end

  print(soln_gamma_rate..' ('..tonum(soln_gamma_rate)..')', 0, 0, color)
  print(soln_epsilon_rate..' ('..tonum(soln_epsilon_rate)..')', 0, 6, color)
  print(soln_oxygen_generator_rating..' ('..tonum(soln_oxygen_generator_rating)..')', 0, 12, color)
  print(soln_co2_scrubber_rating..' ('..tonum(soln_co2_scrubber_rating)..')', 0, 18, color)
end
