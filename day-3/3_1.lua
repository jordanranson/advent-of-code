soln_bit_len = 0
soln_counts = {}
soln_common_bits = {}
soln_flipped_bits = {}
soln_step = 1

function _init ()
  input = split(input, '\n', false)
  soln_bit_len = #input[1]
  
  for i = 1, soln_bit_len do
    add(soln_counts, {0, 0})
    add(soln_common_bits, 0)
    add(soln_flipped_bits, 0)
  end
end

function _update60 ()
  -- todo
  -- Animate._update()
  
  if input[soln_step] == nil then return end

  for x = 1, soln_bit_len do
    if sub(input[soln_step],x,x) == '0' then
      soln_counts[x][1] += 1
    else
      soln_counts[x][2] += 1
    end
  end

  for x = 1, soln_bit_len do
    if soln_counts[x][1] > soln_counts[x][2] then
      soln_common_bits[x] = 0
      soln_flipped_bits[x] = 1
    else
      soln_common_bits[x] = 1
      soln_flipped_bits[x] = 0
    end
  end

  soln_step += 1
end

function _draw ()
	cls(1)

  local color = 6
  if input[soln_step] == nil then color = 8 end
  
  for i = 1, soln_bit_len do
    print(soln_common_bits[i], (i*4)-4, 0, color)
    print(soln_flipped_bits[i], (i*4)-4, 6, color)
  end
end
