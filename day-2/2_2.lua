soln_step = 1
soln_horz = 0
soln_cur_horz = 0
soln_depth = 0
soln_aim = 0

segments = {}
segment_width = 2000
segment_length = 100
rumble_length = 3
track_length = nil

fov = 100
camera_height = 1500
camera_depth = nil
camera_z = 0
draw_dist = 100
fog_density = 5

sub_x = 0
sub_z = nil
sub_speed = 60
sub_max_speed = segment_length / (1/60)

rad_constant = 0.01745329251994329576923690768489

col_bg = 1
col_ground = 2
col_track_0 = 3
col_track_1 = 4
col_track_2 = 5
col_track_3 = 6
col_gauge_0 = 7
col_silver_0 = 8
col_silver_1 = 9
col_gold_0 = 10
col_gold_1 = 11

bubbles = {}

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

function last_y ()
  if #segments == 0 then return 0 end
  return segments[#segments].p2.world.y
end

function add_segment (curve, y)
  local n = #segments

  add(segments, {
    index = n,
    p1 = {
      world = { y = last_y(), z = n*segment_length },
      camera = {},
      screen = {}
    },
    p2 = {
      world = { y = y, z = (n+1)*segment_length },
      camera = {},
      screen = {}
    },
    curve = curve,
    wiggle = rnd()
  })
end

function add_road (enter, hold, leave, curve, y)
  local start_y = last_y()
  local end_y = start_y + (y*segment_length)
  local total = enter + hold + leave

  for n = 0, enter do
    add_segment(Ease.ease_in(0, curve, n/enter), Ease.ease_in_out(start_y, end_y, n/total))
  end
  for n = 0, hold do
    add_segment(curve, Ease.ease_in_out(start_y, end_y, (enter+n)/total))
  end
  for n = 0, leave do
    add_segment(Ease.ease_in_out(curve, 0, n/leave), Ease.ease_in_out(start_y, end_y, (enter+hold+n)/total))
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
  add_road(20, 50, 20, -2, -20)
  add_road(20, 50, 20, 2, 20)

  -- computed values
  track_length = #segments * segment_length
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
  for i = 1, #bubbles do
    if bubbles[i] then
      bubbles[i].x -= bubbles[i].vx
      bubbles[i].y -= bubbles[i].vy
      if bubbles[i].x < -128 or bubbles[i].y < -128 then
        del(bubbles, bubbles[i])
      end
    end
  end

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

  soln_last_horz = soln_horz

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

  soln_cur_horz += (soln_horz - soln_cur_horz) * 0.025
  local speed = mid(0, soln_horz - soln_cur_horz, sub_max_speed)
  camera_z = increment(camera_z, speed, track_length)

  if soln_step % 5 == 0 then
    local colors = {8,9,12}
    add(bubbles, {
      x = rnd(128),
      y = 96,
      vx = 0.2 + rnd(4) - 2,
      vy = 0.1 + rnd(2),
      r = flr(rnd(4)),
      col = colors[1 + flr(rnd(#colors))]
    })
  end

  soln_step += 1
end

function _draw ()
	cls(col_bg)

  pal(2, 129, 1)
  pal(3, 5, 1)
  pal(5, 143, 1)
  pal(6, 15, 1)
  pal(7, 128, 1)
  pal(8, 6, 1)
  pal(9, 7, 1)
  pal(10, 9, 1)
  pal(11, 10, 1)

  rectfill(0, 0, 128, 128, col_ground)
  for y = 0, 127 do
    clip(0, y, 128, 1)
    circfill(64 + sin((time() + y) * 0.51) * 7, 64 + sin((time() + y) * 0.25) * 20, 52, col_bg)
  end
  clip(0, 0, 128, 128)

  -- segments
  local base_segment = find_segment(camera_z)
  local base_percent = (camera_z%segment_length) / segment_length
  local seg_dx = - (base_segment.curve * base_percent)
  local seg_x = 0
  local segment, max_y, camera_x, segment_index

  max_y = 128
  for n = 0, draw_dist do
    segment = segments[((base_segment.index + n) % #segments) + 1]
    segment.looped = segment.index < base_segment.index
    segment.clip = max_y

    local len = 0
    if segment.looped then len = track_length end

    camera_x = sub_x*segment_width
    project(segment.p1, camera_x - seg_x, len)
    project(segment.p2, camera_x - seg_x - seg_dx, len)

    seg_x = seg_x + seg_dx
    seg_dx = seg_dx + segment.curve

    if (
      (segment.p1.camera.z > camera_depth) and
      (segment.p2.screen.y < segment.p1.screen.y) and
      (segment.p2.screen.y < max_y)
    ) then
      rectfill(
        0, segment.p2.screen.y,
        128, segment.p1.screen.y + (segment.p1.screen.y-segment.p2.screen.y),
        col_ground
      )
      max_y = segment.p1.screen.y
    end
  end

  max_y = 128
  for n = 1, draw_dist do
    segment_index = ((base_segment.index + n) % #segments) + 1
    segment = segments[segment_index]

    if (
      (segment.p1.camera.z > camera_depth) and
      (segment.p2.screen.y < segment.p1.screen.y) and
      (segment.p2.screen.y < max_y)
    ) then
      if segment.index % 10 < 3 then
        draw_segment(
          segment.p1.screen.x,
          segment.p1.screen.y,
          segment.p1.screen.w * 5,
          segment.p2.screen.x,
          segment.p2.screen.y,
          segment.p2.screen.w * 5,
          col_bg
        )
      end
      if segment.index % 5 < 3 then
      draw_segment(
        segment.p1.screen.x,
        segment.p1.screen.y,
        segment.p1.screen.w*2.5 + segment.wiggle*20,
        segment.p2.screen.x,
        segment.p2.screen.y,
        segment.p2.screen.w*2.5 + segment.wiggle*20,
        col_track_0
      )
      end
      -- if segment.index % 5 < 4 then
        draw_segment(
          segment.p1.screen.x,
          segment.p1.screen.y,
          segment.p1.screen.w*1.5 + segment.wiggle*5,
          segment.p2.screen.x,
          segment.p2.screen.y,
          segment.p2.screen.w*1.5 + segment.wiggle*5,
          col_track_1
        )
      -- end
      -- if segment.index % 4 < 3 then
        draw_segment(
          segment.p1.screen.x,
          segment.p1.screen.y,
          segment.p1.screen.w*1.35,
          segment.p2.screen.x,
          segment.p2.screen.y,
          segment.p2.screen.w*1.35,
          col_track_2
        )
      -- end
      draw_segment(
        segment.p1.screen.x,
        segment.p1.screen.y,
        segment.p1.screen.w + segment.wiggle*7 - 3,
        segment.p2.screen.x,
        segment.p2.screen.y,
        segment.p2.screen.w + segment.wiggle*7 - 3,
        col_track_3
      )
      max_y = segment.p1.screen.y
    end
  end

  for i = 1, #bubbles do
    local x = bubbles[i].x
    local y = bubbles[i].y

    if x >= 0 and x <= 128 then
      circ(x, y, bubbles[i].r, bubbles[i].col)
    end
  end

  local palette = {col_silver_1,col_silver_0,col_silver_1}
  Draw.metalic_text('> horz  '..soln_horz, 2, 2, palette, 0)
  Draw.metalic_text('> depth '..Math.u32_tostr(soln_depth), 2, 2 + 7, palette, 0)
  Draw.metalic_text('> aim   '..soln_aim, 2, 2 + 14, palette, 0)
end

function sub_y ()
  return sin(time() * 0.4) * 6 + 30
end