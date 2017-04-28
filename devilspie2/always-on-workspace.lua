patterns = {"KeePassX", "emacs\d*"}

for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print(">> PINNING '" .. get_application_name() .. "'")
      pin_window()
   end
end
