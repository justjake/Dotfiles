return {
  -- https://github.com/mrjones2014/legendary.nvim?tab=readme-ov-file#installation
  {
    "mrjones2014/legendary.nvim",
    version = "v2.13.9",
    -- since legendary.nvim handles all your keymaps/commands,
    -- its recommended to load legendary.nvim before other plugins
    priority = 10000,
    lazy = false,
    -- sqlite is only needed if you want to use frecency sorting
    dependencies = { "kkharji/sqlite.lua" },
    opts = {
      extensions = {
        smart_splits = {
          directions = { "h", "j", "k", "l" },
          mods = {
            -- for moving cursor between windows
            move = "<C>",
            -- for resizing windows
            resize = "<M>",
            -- for swapping window buffers
            swap = false, -- false disables creating a binding
          },
        },
      },
    },
  },
  -- https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#key-mappings
  {
    "mrjones2014/smart-splits.nvim",
    -- for direct wezterm integration, can't be lazy-loaded
    lazy = false,
  },
}
