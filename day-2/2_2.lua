step = 1
pos_x = 0
depth = 0
depth_i = 0
aim = 0

function _init ()
  input = split(input, '\n')

  local input_pairs = {}
  for i = 1, #input do
    add(input_pairs, split(input[i], ' '))
  end

  input = input_pairs
end

function _update60 ()
  -- Animate._update()

  if input[step] == nil then return end

  local next_step = input[step]
  local command = next_step[1]
  local amount = next_step[2]

  if command == 'forward' then
    pos_x += amount
    depth += (aim * amount) >> 16
  end

  if command == 'down' then
    aim += amount
  end

  if command == 'up' then
    aim -= amount
  end

  step += 1
end

function _draw ()
	cls()

  Draw.metalic_text('horz  '..pos_x, 2, 2)
  Draw.metalic_text('depth '..Math.u32_tostr(depth), 2, 2 + 7)
  Draw.metalic_text('aim   '..aim..' ('..(aim%360)..')', 2, 2 + 14)
end
