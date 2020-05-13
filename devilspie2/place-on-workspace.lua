-- PERSONAL_WORKSPACE = 1
-- PIVOTAL_WORKSPACE = get_workspace_count() -- last workspace

-- patterns = {}
-- patterns["^Telegram$"] = PERSONAL_WORKSPACE
-- patterns["- Discord$"] = PERSONAL_WORKSPACE
-- patterns["^Slack"] = PIVOTAL_WORKSPACE
-- patterns["Sococo"] = PIVOTAL_WORKSPACE

-- debug_print("place-on-workspace: examining '" .. get_application_name() .. "'")
-- for pattern, workspace in pairs(patterns) do
--    if (string.find(get_application_name(), pattern)) then
--       debug_print("place-on-workspace: PINNING '" .. get_application_name() .. "' to workspace " .. workspace)
--       set_window_workspace(workspace)
--    end
-- end
