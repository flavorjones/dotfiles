patterns = {
   "KeePassX",
   "emacs\d*",
   "^YouTube Music$",
   "^Signal$",
   "^Slack",
   "^obs$",
   "flavorjones - Obsidian",
   "Meet - ",
   "^Zoom Meeting$",
   "^lofi.cafe.* - lofi music"
}

debug_print("always-on-workspace: examining '" .. get_application_name() .. "'")
for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("always-on-workspace: PINNING '" .. get_application_name() .. "'")
      pin_window()
   end
end
