last = nil
sums = {}
count = 0
index = 1
step = 0

function _init ()
  input = split(input, '\n')
end

function nextStep ()
  index = 1
  step += 1
end

function sumWindows ()
  if input[index] == nil or input[index+1] == nil or input[index+2] == nil then
    nextStep()
    return
  end

  sums[index] = input[index] + input[index+1] + input[index+2]

  index += 1
end

function countSums ()
  if index > #sums then
    nextStep()
    return
  end

  if last != nil then
    if sums[index] > last then
      count += 1
    end
  end
  last = sums[index]

  index += 1
end

function _update60 ()
  if step == 0 then
    sumWindows()
    return
  end
  if step == 1 then
    countSums()
    return
  end
end

function _draw ()
	cls()
  print('sums ..', 1, 1)

  for i = 1, #sums do
    print(sums[i], 1 + 8 * 4, 1 + (i - 1) * 6)
  end

  local str = 'count .. ' .. count
  local x = 127 - #tostr(str) * 4
  print(str, x, 1)
end
