-- Disable none-ls; replaced by conform.nvim (formatting) + nvim-lint (linting)
-- via astrocommunity.editing-support.conform-nvim and astrocommunity.lsp.nvim-lint

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
}
