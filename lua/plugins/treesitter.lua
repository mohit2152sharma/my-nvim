-- v6: AstroNvim already pins nvim-treesitter to `main` branch
-- and auto-installs parsers as needed. Just add user extras.

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
    },
  },
}
