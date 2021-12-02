last = nil
count = 0
index = 1
offset_x = 0
offset_y = 0
points = {}
bubbles = {}

function iteration ()
  local limit = input[#input]
  local peak = false
  local height = 0

  if last != nil then
    if input[index] > last then
      count += 1
      peak = true
    end
  end

  height = input[index] / limit
  height = 32 + height * 1024

  add(points, {
    height = height,
    peak = peak,
    detail = 2 + rnd(2)
  })

  last = input[index]

  index += 1
end

function _init ()
  input = split(input, '\n')
  for i = 1, 128 do
    iteration()
  end
end

function _update60 ()
  for i = 1, #bubbles do
    if bubbles[i] then
      bubbles[i].x -= bubbles[i].vx
      bubbles[i].y -= bubbles[i].vy
      if bubbles[i].x < -128 or bubbles[i].y < -128 then
        del(bubbles, bubbles[i])
      end
    end
  end

  if index > #input then return end

  iteration()

  offset_x += 1

  if points[index-1] and points[index-2] and points[index-2].height < points[index-1].height then
    if points[index-2].height - offset_y > 116 then
      offset_y += 1
    end
  end

  if index % 10 == 0 then
    local colors = {12,13,6,7}
    add(bubbles, {
      x = 0,
      y = 0,
      vx = 0.2 + rnd(),
      vy = 0.1 + rnd(),
      r = flr(rnd(2)),
      col = colors[1 + flr(rnd(#colors))]
    })
  end
end

function draw_map ()
  local x = -(offset_x % 128)
  local y = -(offset_y % 128)

  map(0, 0, x, y, 8, 8)
  map(0, 0, x + 64, y + 64, 8, 8)
  map(0, 0, x + 64, y, 8, 8)
  map(0, 0, x, y + 64, 8, 8)

  map(0, 0, x + 128, y, 8, 8)
  map(0, 0, x + 128 + 64, y + 64, 8, 8)
  map(0, 0, x + 128 + 64, y, 8, 8)
  map(0, 0, x + 128, y + 64, 8, 8)

  map(0, 0, x + 128, y + 128, 8, 8)
  map(0, 0, x + 128 + 64, y + 64 + 128, 8, 8)
  map(0, 0, x + 128 + 64, y + 128, 8, 8)
  map(0, 0, x + 128, y + 64 + 128, 8, 8)

  map(0, 0, x, y + 128, 8, 8)
  map(0, 0, x + 64, y + 64 + 128, 8, 8)
  map(0, 0, x + 64, y + 128, 8, 8)
  map(0, 0, x, y + 64 + 128, 8, 8)
end

function subY ()
  return sin(time() * 0.4) * 6 + 30
end

function _draw ()
  clip(0, 0, 128, 128)

	cls(0)

  fillp(0b0101101001011010)
  rectfill(0, 0, 128, 128, 1)

  fillp(0b0000000000000000)
  circfill(64, 64, 52, 1)

  for i = 1, #points do
    local x = i - offset_x
    local y = points[i].height - offset_y

    if x >= 0 and x <= 128 then
      clip(x, y, 1, 128)
      draw_map()
    end
  end

  clip(0, 0, 128, 128)

  for i = 1, #bubbles do
    local x = bubbles[i].x + 64 - 9
    local y = bubbles[i].y + subY() + 9

    if x >= 0 and x <= 128 then
      circ(x, y, bubbles[i].r, bubbles[i].col)
    end
  end

  for i = 1, #points do
    local x = i - offset_x
    local y = points[i].height - offset_y

    if x >= 0 and x <= 128 then
      line(x, y, x, y + points[i].detail + 3, 14)
      line(x, y, x, y + points[i].detail + 1, 4)
      line(x, y, x, y + points[i].detail, 10)

      fillp(0b0101101001011010)
      rectfill(x, y - points[i].detail * 2, x, y, 1)
      fillp(0b0000000000000000)

      if points[i].peak then
        line(x, y - points[i].detail * 0.5, x, y + 1, 3)
      end
    end
  end


  for i = 1, #points do
    local x = i - offset_x
    local y = points[i].height - offset_y + 4

    if x >= -16 and x <= 128 + 16 then
      if not points[i].peak and i % 12 == 0 then
        for k = 1, flr(points[i].detail * 2) do
          local ox = sin((time() + k + i) * 0.9) * (k * 0.5)
          if k == flr(points[i].detail * 2) then
            spr(9, x + ox, y - (k * 7))
          else
            spr(25, x + ox, y - (k * 7))
          end
        end
      end
    end
  end

  local y = subY()
  pal(1, 0)
  sspr(24, 8, 16, 16, 64 - 8 + 1, y + 3)
  pal(1, 1)
  if index % 20 > 10 then
    sspr(8, 8, 16, 16, 64 - 8, y)
  else
    sspr(40, 8, 16, 16, 64 - 8, y)
  end

  print('- ' .. count .. ' -', 4, 4, 0)
  print('- ' .. count .. ' -', 2, 2, 9)
  clip(0, 3, 128, 1)
  print('- ' .. count .. ' -', 2, 2, 10)
  clip(0, 6, 128, 1)
  print('- ' .. count .. ' -', 2, 2, 4)
end
