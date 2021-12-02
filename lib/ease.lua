Ease = {}

function Ease.ease_in (a, b, t)
  return a + (b-a) * (t^2)
end

function Ease.ease_out (a, b, t)
  return a + (b-a) * (1 - (t^2))
end

function Ease.ease_in_out (a, b, t)
  return a + (b-a) * (t * t * (3 - 2 * t))
end
