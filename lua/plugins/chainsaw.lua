---@type LazySpec
return {
  "chrisgrieser/nvim-chainsaw",
  dependencies = {
    { "AstroNvim/astroui", opts = { icons = { Chainsaw = "󰷉" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        local prefix = "<Leader>v"
        maps.n[prefix] = { desc = require("astroui").get_icon("Chainsaw", 1, true) .. "Log" }
        maps.n[prefix .. "p"] = { function() require("chainsaw").variableLog() end, desc = "Log Variable" }
        maps.n[prefix .. "i"] = { function() require("chainsaw").objectLog() end, desc = "Inspect Variable" }
        maps.n[prefix .. "m"] = { function() require("chainsaw").messageLog() end, desc = "Create log statement" }
        maps.n[prefix .. "t"] = { function() require("chainsaw").timeLog() end, desc = "Wrap within time logs" }
        maps.n[prefix .. "y"] = { function() require("chainsaw").typeLog() end, desc = "Type of" }
        maps.n[prefix .. "c"] =
          { function() require("chainsaw").removeLogs() end, desc = "Remove all logs by chainsaw" }
      end,
    },
  },
  -- cmd = "Neogen",
  -- opts = {
  --   snippet_engine = "luasnip",
  --   languages = {
  --     lua = { template = { annotation_convention = "ldoc" } },
  --     typescript = { template = { annotation_convention = "tsdoc" } },
  --     typescriptreact = { template = { annotation_convention = "tsdoc" } },
  --   },
  -- },
  opts = {
    marker = "🪚",

    ---@type string|false -- false to disable
    logHighlightGroup = "Visual",

    -- emojis used for `emojiLog`
    logEmojis = { "🔵", "🟩", "⭐", "⭕", "💜", "🔲" },
  },
}
