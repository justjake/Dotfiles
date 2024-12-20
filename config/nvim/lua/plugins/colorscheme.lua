-- https://lazy.folke.io/spec
return {
  {
    "RRethy/base16-nvim",
    main = "base16-colorscheme",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "base16-circus",
    },
  },
}
