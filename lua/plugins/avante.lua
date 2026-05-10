return {
  "yetone/avante.nvim",
  opts = {
    provider = "claude",
    providers = {
      claude = {
        auth_type = "max",
      },
    },
    input = { provider = "snacks" },
    selector = { provider = "snacks" },
    file_selector = { provider = "snacks" },
  },
  dependencies = {
    "folke/snacks.nvim",
  },
  enabled = false,
}
