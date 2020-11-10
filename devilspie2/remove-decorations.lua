patterns = {
   "^Slack",
   "^Terminal$",
   "^emacs$",
}


debug_print("remove-decorations: examining '" .. get_application_name() .. "'")
for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("remove-decorations: UNFRAMING '" .. get_application_name() .. "'")
      undecorate_window()
   end
end
