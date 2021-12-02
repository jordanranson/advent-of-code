Math = {}

function Math.u32_tostr (v)
  local s = ''
  repeat
    local t = v >>> 1
    s = (t % 0x0.0005 << 17) + (v << 16 & 1) .. s
    v = t / 5
  until v == 0
  return s
end

function Math.s32_tostr (v)
  if v < 0 then return '-' .. Math.u32_tostr(-v) end
  return Math.u32_tostr(v)
end

function Math.tan (v)
  return sin(v) / cos(v)
end
