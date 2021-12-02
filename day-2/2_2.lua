soln_step = 1
soln_horz = 0
soln_depth = 0
soln_aim = 0

segments = {}
segment_width = 2000
segment_length = 200
rumble_length = 3
track_length = nil
track_width = 3

fov = 90
camera_height = 1000
camera_depth = nil
camera_z = 0
draw_dist = 300
fog_density = 5

sub_x = 0
sub_z = nil
sub_speed = 20
sub_max_speed = segment_length / (1/60)

function find_segment (z)
  return segments[(flr(z/segment_length) % #segments) + 1]
end

function project (p, x, len)
  p.camera.x     = (p.world.x or 0) - x
  p.camera.y     = (p.world.y or 0) - camera_height
  p.camera.z     = (p.world.z or 0) - (camera_z - len)
  p.screen.scale = camera_depth/p.camera.z
  p.screen.x     = flr(64 + (p.screen.scale*p.camera.x*64))
  p.screen.y     = flr(64 - (p.screen.scale*p.camera.y*64))
  p.screen.w     = flr(     (p.screen.scale*segment_width*64))
end

function draw_polygon (points, col)
  local xl,xr,ymin,ymax={},{},129,0xffff
  for k,v in pairs(points) do
    local p2=points[k%#points+1]
    local x1,y1,x2,y2=v[1],flr(v[2]),p2[1],flr(p2[2])
    if y1>y2 then
      y1,y2,x1,x2=y2,y1,x2,x1
    end
    local d=y2-y1
    for y=y1,y2 do
      local xval=flr(x1+(x2-x1)*(d==0 and 1 or (y-y1)/d))
      xl[y],xr[y]=min(xl[y] or 32767,xval),max(xr[y] or 0x8001,xval)
    end
    ymin,ymax=min(y1,ymin),max(y2,ymax)
  end
  for y=ymin,ymax do
    rectfill(xl[y],y,xr[y],y,col)
  end
end

function draw_segment (x1, y1, w1, x2, y2, w2, color)
  rectfill(0, y2, 128, y1 + (y1-y2), 13)
  -- rectfill(x1-w1, y1, x1+w1, y1+1, color)
  draw_polygon(
    {
      {x1-w1, y1}, 
      {x1+w1, y1}, 
      {x2+w2, y2}, 
      {x2-w2, y2}
    }, 
    color
  )
end

function _init ()
  -- parse input
  input = split(input, '\n')

  local input_pairs = {}
  for i = 1, #input do
    add(input_pairs, split(input[i], ' '))
  end

  input = input_pairs

  -- prepare road segments
  for n = 1, 500 do
    -- local color = flr(n/rumble_length) % 2 == 0
    -- if color then color = 10 else color = 11 end
    local color = n % 16

    add(segments, {
      index = n,
      p1 = { 
        world = { z = n*segment_length }, 
        camera = {}, 
        screen = {}
      },
      p2 = { 
        world = { z = (n+1)*segment_length }, 
        camera = {}, 
        screen = {}
      },
      color = color
    })
  end

  -- computed values
  track_length = #segments * segment_length
  camera_depth = 1 / Math.tan((fov/2) * (3.1415/180))
  sub_z = camera_height * camera_depth
end

function increment (start, amount, max)
  local result = start + amount
  while (result >= max) do
    result -= max
  end
  while (result < 0) do
    result += max
  end
  return result
end

function _update60 ()
  camera_z = increment(camera_z, sub_speed, track_length)

  local dx = sub_speed/sub_max_speed

  -- if left
  --   sub_x -= dx
  -- else if right
  --   sub_x += dx

  -- if faster
  --   sub_speed += sub_accel
  -- else
  --   sub_speed += sub_decel

  sub_x = mid(-2, sub_x, 2)
  sub_speed = mid(0, sub_speed, sub_max_speed)

  -- solution step
  if input[step] == nil then return end

  local next_step = input[step]
  local command = next_step[1]
  local amount = next_step[2]

  if command == 'forward' then
    soln_horz += amount
    -- soln_depth += (soln_aim * amount) >> 16
  end

  if command == 'down' then
    soln_aim += amount
  end

  if command == 'up' then
    soln_aim -= amount
  end

  soln_step += 1
end

function _draw ()
	cls(1)

  -- segments
  local base_segment = find_segment(camera_z)
  local max_y = 128
  local segment

  for n = 1, draw_dist do
    segment = segments[((base_segment.index + n) % #segments) + 1]
    segment.looped = segment.index < base_segment.index

    local len = 0
    if segment.looped then len = track_length end
    project(segment.p1, sub_x*segment_width, len)
    project(segment.p2, sub_x*segment_width, len)

    if (
      (segment.p1.camera.z > camera_depth) and
      (segment.p2.screen.y < max_y)
    ) then
      draw_segment(
        segment.p1.screen.x,
        segment.p1.screen.y,
        segment.p1.screen.w,
        segment.p2.screen.x,
        segment.p2.screen.y,
        segment.p2.screen.w,
        segment.color
      )
      max_y = segment.p2.screen.y
    end
  end

  draw_polygon({
    {10, 10},
    {20, 10},
    {30, 20},
    {0, 20}
  }, 10)

  Draw.metalic_text('horz  '..soln_horz, 2, 2)
  Draw.metalic_text('depth '..Math.u32_tostr(soln_depth), 2, 2 + 7)
  Draw.metalic_text('aim   '..soln_aim..' ('..(soln_aim%360)..')', 2, 2 + 14)
end
