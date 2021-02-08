patterns = {
   "KeePassX",
   "emacs\d*",
   "Tomboy",
   "^Google Play Music$",
   "^YouTube Music$",
   "^Signal$",
   "^Slack",
   "Qt Client Leader Window", -- OBS Studio ¯\_(ツ)_/¯
   "flavorjones.*Obsidian",
   "Meet - ",
   "^Zoom Meeting$",
}

debug_print("always-on-workspace: examining '" .. get_application_name() .. "'")
for _, pattern in ipairs(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("always-on-workspace: PINNING '" .. get_application_name() .. "'")
      pin_window()
   end
end
