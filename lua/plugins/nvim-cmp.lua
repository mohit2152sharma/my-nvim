-- v5+ replaced nvim-cmp with blink.cmp
-- Disable nvim-cmp; configure blink instead via separate file or override
return {
  { "hrsh7th/nvim-cmp", enabled = false },
  { "saghen/blink.lib" },
  {
    "saghen/blink.cmp",
    dependencies = { "saghen/blink.lib" },
    opts = {
      completion = { ghost_text = { enabled = true } },
    },
  },
}
