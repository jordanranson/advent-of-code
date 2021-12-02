Draw = {
  metalic_text_palettes = {
    red = {2, 8, 14},
    blue = {13, 12, 6},
    green = {3, 11, 10},
    rose_gold = {2, 14, 15},
    gold = {4, 9, 10},
    silver = {13, 6, 7}
  }
}

function Draw.dither (should_dither) 
  if should_dither then
    fillp(0b0101101001011010)
  else
    fillp(0b0000000000000000)
  end
end

function Draw.clr_clip ()
  clip(0, 0, 128, 128)
end

function Draw.metalic_text (str, x, y, col, shadow)
  local palette = Draw.metalic_text_palettes[col]

  if shadow != nil then print(str, x + 2, y + 2, shadow) end
  print(str, x, y, palette[2])
  clip(0, y + 1, 128, 1)
  print(str, x, y, palette[3])
  clip(0, y + 4, 128, 1)
  print(str, x, y, palette[1])
  clip(0, 0, 128, 128)
end
