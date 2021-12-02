soln_step = 1
soln_horz = 0
soln_depth = 0
soln_aim = 0

segments = {}
segment_width = 1500
segment_length = 100
rumble_length = 3
track_length = nil

fov = 100
camera_height = 1000
camera_depth = nil
camera_z = 0
draw_dist = 64
fog_density = 5

sub_x = 0
sub_z = nil
sub_speed = 50
sub_max_speed = segment_length / (1/60)

rad_constant = 0.01745329251994329576923690768489

function find_segment (z)
  return segments[(flr(z/segment_length) % #segments) + 1]
end

function project (p, x, len)
  p.camera.x     = (p.world.x or 0) - x
  p.camera.y     = (p.world.y or 0) - camera_height
  p.camera.z     = (p.world.z or 0) - (camera_z - len)
  p.screen.scale = camera_depth/p.camera.z
  p.screen.x     = 64 + (p.screen.scale*p.camera.x*64)
  p.screen.y     = 64 - (p.screen.scale*p.camera.y*64)
  p.screen.w     =      (p.screen.scale*segment_width*64)
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

function add_segment (curve)
  local n = #segments

  local colors = {15,13,6,13}
  local color = colors[(flr(n/rumble_length) % 4) + 1]

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
    curve = curve,
    color = color
  })

  track_length = #segments * segment_length
end

function add_road (enter, hold, leave, curve)
  for n = 0, enter do
    add_segment(Ease.ease_in(0, curve, n/enter))
  end
  for n = 0, hold do
    add_segment(curve)
  end
  for n = 0, leave do
    add_segment(Ease.ease_in_out(curve, 0, n/leave))
  end
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
  add_road(20, 50, 20, -2)
  add_road(20, 50, 20, 2)

  -- computed values
  camera_depth = 1 / Math.tan((fov/2) * rad_constant)
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
  if input[soln_step] == nil then return end

  local next_step = input[soln_step]
  local command = next_step[1]
  local amount = next_step[2]

  if command == 'forward' then
    soln_horz += amount
    soln_depth += (soln_aim * amount) >> 16
  end

  if command == 'down' then
    soln_aim += amount
  end

  if command == 'up' then
    soln_aim -= amount
  end

  -- if soln_step % 30 == 0 then
  --   add_road(30, 30, 30, ((soln_aim % 360) / 360) * 6)
  -- end

  soln_step += 1
end

function _draw ()
	cls(1)

  -- segments
  local base_segment = find_segment(camera_z)
  local base_percent = (camera_z%segment_length) / segment_length
  local seg_dx = - (base_segment.curve * base_percent)
  local seg_x = 0
  local segment, max_y, camera_x

  max_y = 128
  for n = 1, draw_dist do
    segment = segments[((base_segment.index + n) % #segments) + 1]
    segment.looped = segment.index < base_segment.index

    local len = 0
    if segment.looped then len = track_length end

    camera_x = sub_x*segment_width
    project(segment.p1, camera_x - seg_x, len)
    project(segment.p2, camera_x - seg_x - seg_dx, len)

    seg_x = seg_x + seg_dx
    seg_dx = seg_dx + segment.curve

    if (
      (segment.p1.camera.z > camera_depth) and
      (segment.p2.screen.y < max_y)
    ) then
      rectfill(
        0, segment.p2.screen.y,
        128, segment.p1.screen.y + (segment.p1.screen.y-segment.p2.screen.y),
        13
      )
      max_y = segment.p2.screen.y
    end
  end

  max_y = 128
  for n = 1, draw_dist do
    segment = segments[((base_segment.index + n) % #segments) + 1]

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

  Draw.metalic_text('horz  '..soln_horz, 2, 2)
  Draw.metalic_text('depth '..Math.u32_tostr(soln_depth), 2, 2 + 7)
  Draw.metalic_text('aim   '..soln_aim..' ('..(soln_aim%360)..')', 2, 2 + 14)
end
