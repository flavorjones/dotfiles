-- Managed by chezmoi: home/dot_config/hypr/input.lua
--
-- Omarchy's real defaults:      /usr/share/omarchy/default/hypr/input.lua
-- Omarchy's commented template: /usr/share/omarchy/config/hypr/input.lua
--
-- This file loads after those defaults. Only the settings named below are
-- overridden; repeat rate, touchpad, follow_mouse and the rest still come
-- from Omarchy.

hl.config({
  input = {
    -- Omarchy ships "compose:caps,shift:both_capslock_cancel", which spends
    -- Caps Lock on the Compose key. Spend it on Ctrl instead and move Compose
    -- to Right Alt.
    --
    --   ctrl:nocaps                 Caps Lock acts as Ctrl
    --   compose:ralt                Right Alt is Compose (Multi_key), which is
    --                               the key ~/.XCompose sequences start with
    --   shift:both_capslock_cancel  both Shifts together turn Caps Lock on,
    --                               one Shift turns it off. Kept from Omarchy's
    --                               default, because Caps Lock no longer has a
    --                               key of its own.
    kb_options = "ctrl:nocaps,compose:ralt,shift:both_capslock_cancel",
  },
})
