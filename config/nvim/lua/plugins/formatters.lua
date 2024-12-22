return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        shfmt = {
          prepend_args = { "--indent=2", "--keep-padding" },
        },
      },
    },
  },
}
