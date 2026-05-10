-- v6: mason-lspconfig v2 + mason-tool-installer for installations
-- AstroNvim now drives Mason via mason-tool-installer

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
        "lua-language-server",
        "stylua",
        "debugpy",
      })
    end,
  },
}
