return {
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  -- http://www.lazyvim.org/plugins/editor#neo-treenvim
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          -- https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/353
          -- true: all "hide" just mean "dimmed out"
          visible = true,
          hide_dotfiles = false,
          -- hide_gitignored = false,
        },
      },
    },
    keys = {
      {
        "<leader>g",
        function()
          require("neo-tree.command").execute({ toggle = false, dir = LazyVim.root() })
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = false, dir = vim.uv.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = false })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = false })
        end,
        desc = "Buffer Explorer",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      -- Pretends to be Xcode. Turn it off.
      -- https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
      dashboard = { enabled = false },
    },
  },
  -- Disable tab bar
  { "akinsho/bufferline.nvim", enabled = false },
  -- Put : command line back where it's supposed to be at the bottom of the window
  -- instead of in a pop-up
  { "folke/noice.nvim", opts = {
    cmdline = {
      view = "cmdline",
    },
  } },
}
