patterns = {"^Zoom.*Pro Account$"}

debug_print("always-minimize-on-creation: examining '" .. get_application_name() .. "'")
for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("always-on-workspace: MINIMIZING '" .. get_application_name() .. "'")
      minimize()
      -- because sometimes apps (like Zoom) explicitly maximize shortly after win creation
      os.execute("sleep " .. 1)
      minimize()
      os.execute("sleep " .. 1)
      minimize()
   end
end
