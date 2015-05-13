-- debug_print("Window Name: " .. get_window_name());
-- debug_print("Application name: " .. get_application_name());

-- OMG I'm sorry about this.
function list_iter (t)
   local i = 0
   local n = table.getn(t)
   return function ()
             i = i + 1
             if i <= n then return t[i] end
          end
end

patterns = {".* - KeePassX", "emacs\d*"}

for pattern in list_iter(patterns) do
   if (string.find(get_application_name(), pattern)) then
      debug_print("Pinning '" .. get_application_name() .. "'")
      pin_window()
   end
end
