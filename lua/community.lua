-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.completion.copilot-cmp", enabled = true },
  { import = "astrocommunity.pack.python", enabled = true },
  { import = "astrocommunity.pack.svelte", enabled = true },
  { import = "astrocommunity.pack.terraform", enabled = true },
  { import = "astrocommunity.pack.yaml", enabled = true },
  { import = "astrocommunity.pack.typescript-all-in-one", enabled = true },
  { import = "astrocommunity.pack.sql", enabled = true },
  { import = "astrocommunity.pack.markdown", enabled = true },
  { import = "astrocommunity.pack.markdown", enabled = true },
  { import = "astrocommunity.pack.bash", enabled = true },
  { import = "astrocommunity.pack.docker", enabled = true },

  { import = "astrocommunity.debugging.nvim-chainsaw", enabled = true },
  { import = "astrocommunity.debugging.nvim-dap-repl-highlights", enabled = true },
  { import = "astrocommunity.debugging.telescope-dap-nvim", enabled = true },
  -- { import = "astrocommunity.editing.auto-save-nvim", enabled = true },

  { import = "astrocommunity.register.nvim-neoclip-lua", enabled = true },
  { import = "astrocommunity.project.projectmgr-nvim", enabled = true },

  { import = "astrocommunity.test.neotest", enabled = true },
  { import = "astrocommunity.test.nvim-coverage", enabled = true },

  { import = "astrocommunity.file-explorer.oil-nvim", enabled = true },
  { import = "astrocommunity.file-explorer.telescope-file-browser-nvim", enabled = true },

  { import = "astrocommunity.motion.before-nvim", enabled = true },
  { import = "astrocommunity.motion.nvim-spider", enabled = true },
  { import = "astrocommunity.motion.nvim-surround", enabled = true },
  { import = "astrocommunity.motion.nvim-tree-pairs", enabled = true },
  { import = "astrocommunity.motion.portal-nvim", enabled = true },
  { import = "astrocommunity.motion.tabout-nvim", enabled = true },
  { import = "astrocommunity.motion.vim-matchup", enabled = true },
  -- { import = "astrocommunity.motion.leap-nvim", enabled = true },

  { import = "astrocommunity.markdown-and-latex.markview-nvim" },

  { import = "astrocommunity.indent.indent-rainbowline", enabled = true },
  { import = "astrocommunity.indent.indent-tools-nvim", enabled = true },

  { import = "astrocommunity.syntax.hlargs-nvim", enabled = true },
  { import = "astrocommunity.syntax.vim-cool", enabled = true },
  { import = "astrocommunity.syntax.vim-easy-align", enabled = true },

  { import = "astrocommunity.search.grug-far-nvim", enabled = true },
  { import = "astrocommunity.search.nvim-hlslens", enabled = true },
  { import = "astrocommunity.search.nvim-spectre", enabled = true },

  { import = "astrocommunity.git.gitgraph-nvim", enabled = true },
  { import = "astrocommunity.git.openingh-nvim", enabled = true },
  { import = "astrocommunity.git.blame-nvim", enabled = true },
  { import = "astrocommunity.git.diffview-nvim", enabled = true },

  { import = "astrocommunity.diagnostics.trouble-nvim", enabled = true },

  { import = "astrocommunity.editing-support.multiple-cursors-nvim", enabled = true },
  { import = "astrocommunity.editing-support.wildfire-nvim", enabled = true },
  { import = "astrocommunity.editing-support.todo-comments-nvim", enabled = true },
  { import = "astrocommunity.docker.lazydocker" },
  -- import/override with your plugins folder
}
