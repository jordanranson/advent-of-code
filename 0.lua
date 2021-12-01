last = nil
count = 0
index = 0

function _init ()
  input = split(input, '\n')
end

function _update60 ()
  if index > #input then return end

  if last != nil then
    if input[index] > last then
      count += 1
    end
  end
  last = input[index]

  index += 1
end

function _draw ()
	cls()
  print(count)
end
