patterns = {"^Google Play Music$"}

debug_print("always-on-top      : examining '" .. get_application_name() .. "'")
for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("always-on-top      : TOPPING '" .. get_application_name() .. "'")
      make_always_on_top()
   end
end
