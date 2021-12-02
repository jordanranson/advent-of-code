Animate = {
  frame = 1
}

function Animate._update ()
  Animate.frame += 1
end

function Animate.spr (sprites, freq, x, y, w, h, flip_x, flip_y)
  local next_index = flr(Animate.frame / freq) % #sprites
  local next_sprite = sprites[next_index + 1]

  w = w or 1
  h = h or 1

  spr(
    next_sprite, 
    x, y, w, h, 
    flip_x, flip_y
  )
end

function Animate.sspr (points, freq, sw, sh, dx, dy, dw, dh, flip_x, flip_y)
  local next_index = flr(Animate.frame / freq) % #points
  local next_point = points[next_index + 1]

  dw = dw or sw
  dh = dh or sh

  sspr(
    next_point[1], 
    next_point[2], 
    sw, sh, dx, dy, dw, dh, 
    flip_x, flip_y
  )
end

function Animate.map (points, freq, dx, dy, celw, celh, layer)
  local next_index = flr(Animate.frame / freq) % #points
  local next_point = points[next_index + 1]

  celw = celw or 1
  celh = celh or 1

  map(
    next_point[1], next_point[2], 
    dx, dy, celw, celh, 
    layer
  )
end
