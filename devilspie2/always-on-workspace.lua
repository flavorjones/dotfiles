patterns = {"KeePassX", "emacs\d*"}

for _, pattern in ipairs(patterns) do
   debug_print(">> EXAMINING '" .. get_application_name() .. "'")
   if (string.find(get_application_name(), pattern)) then
      debug_print(">> PINNING '" .. get_application_name() .. "'")
      pin_window()
   end
end
