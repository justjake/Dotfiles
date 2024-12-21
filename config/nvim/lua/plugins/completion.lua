return {
  {
    "saghen/blink.cmp",
    opts = {
      -- https://cmp.saghen.dev/configuration/keymap.html
      -- With preset super-tab, manual mode, and possibly LazyVim config,
      -- enter no longer accepts the first completion item but will select
      -- if you arrow-down into the menu, and tab still does perform the
      -- first completion. This is the most VS Code like (and intuitive!)
      keymap = {
        -- On tab, accept the top completion
        preset = "super-tab",
        -- Acceptable as long as `selection = "manual"`
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        list = {
          -- https://cmp.saghen.dev/configuration/reference.html#completion-list
          selection = "manual",
        },
      },
    },
  },
}
