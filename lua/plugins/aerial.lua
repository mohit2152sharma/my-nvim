-- Drop treesitter backend; broken on nvim 0.12 match-table change
return {
  "stevearc/aerial.nvim",
  opts = { backends = { "lsp", "markdown", "asciidoc", "man" } },
}
