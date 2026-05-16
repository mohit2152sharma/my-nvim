-- Find nearest .venv walking up from cwd (uv monorepos keep one at workspace root).
local function find_venv()
  local found = vim.fs.find(".venv", {
    upward = true,
    type = "directory",
    path = vim.fn.getcwd(),
    stop = vim.loop.os_homedir(),
  })
  return found[1]
end

local function venv_python()
  local venv = find_venv()
  if venv then
    local p = venv .. (vim.fn.has "win32" == 1 and "/Scripts/python.exe" or "/bin/python")
    if vim.fn.executable(p) == 1 then return p end
  end
  return vim.fn.exepath "python"
end

-- Activate venv at file-load time (before LSP/DAP read PATH). Cwd is already final here.
local _venv = find_venv()
if _venv then
  vim.env.VIRTUAL_ENV = _venv
  vim.env.PATH = _venv .. "/bin:" .. vim.env.PATH
end

-- Locate an editor-managed debugpy installation (never from the project).
-- Priority: 1) uv tool install debugpy, 2) Mason's debugpy package.
-- Returns the path to the directory containing the `debugpy` package,
-- which we'll inject via PYTHONPATH so the project venv's python can find it.
local function find_debugpy_path()
  -- Option A: uv tool install debugpy
  local uv_tool = vim.fn.expand "~/.local/share/uv/tools/debugpy/lib"
  if vim.fn.isdirectory(uv_tool) == 1 then
    -- The actual package lives in lib/python3.X/site-packages
    local matches = vim.fn.glob(uv_tool .. "/python*/site-packages", false, true)
    if #matches > 0 then return matches[1] end
  end

  -- Option B: Mason's debugpy
  local ok, registry = pcall(require, "mason-registry")
  if ok and registry.is_installed "debugpy" then
    local install = vim.fn.expand "$MASON/packages/debugpy"
    local matches = vim.fn.glob(install .. "/venv/lib/python*/site-packages", false, true)
    if #matches > 0 then return matches[1] end
    matches = vim.fn.glob(install .. "/venv/Lib/site-packages", false, true)
    if #matches > 0 then return matches[1] end
  end

  return nil
end

return {
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      formatting = {
        format_on_save = false,
      },
      -- Disable redundant Python type checkers; keep basedpyright + ruff only.
      handlers = {
        pyrefly = false,
        ty = false,
      },
      ---@diagnostic disable: missing-fields
      config = {
        basedpyright = {
          before_init = function(_, c)
            if not c.settings then c.settings = {} end
            if not c.settings.python then c.settings.python = {} end
            c.settings.python.pythonPath = venv_python()
          end,
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                  reportUnusedImport = "information",
                  reportUnusedFunction = "information",
                  reportUnusedVariable = "information",
                  reportGeneralTypeIssues = "error",
                  reportOptionalMemberAccess = "information",
                  reportOptionalSubscript = "information",
                  reportPrivateImportUsage = "information",
                },
              },
            },
          },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    optional = true,
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "python", "toml" })
      end
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "basedpyright" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "python" })
      if not opts.handlers then opts.handlers = {} end
      opts.handlers.python = function() end -- nvim-dap-python handles this
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      -- debugpy still listed here as a Mason-managed install (fallback).
      -- If you prefer the uv tool approach, you can remove "debugpy" from here.
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "basedpyright", "ruff", "debugpy" })
    end,
  },
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    enabled = vim.fn.executable "fd" == 1 or vim.fn.executable "fdfind" == 1 or vim.fn.executable "fd-find" == 1,
    dependencies = {
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>lv"] = { "<Cmd>VenvSelect<CR>", desc = "Select VirtualEnv (manual override)" },
            },
          },
        },
      },
    },
    opts = {},
    cmd = "VenvSelect",
  },

  -- ============================================================
  -- DEBUGGING (DAP)
  -- ============================================================
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require "dap", require "dapui"
          dapui.setup()
          dap.listeners.before.attach.dapui_config = function() dapui.open() end
          dap.listeners.before.launch.dapui_config = function() dapui.open() end
          dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
          dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
        end,
      },
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    specs = {
      {
        "mfussenegger/nvim-dap-python",
        dependencies = "mfussenegger/nvim-dap",
        ft = "python",
        config = function()
          local dap = require "dap"
          local project_python = venv_python()

          local debugpy_path = find_debugpy_path()
          if not debugpy_path then
            vim.notify(
              "debugpy not found. Install via `uv tool install debugpy` or `:MasonInstall debugpy`",
              vim.log.levels.WARN
            )
          end

          -- Custom adapter: run project venv's python, but inject debugpy via PYTHONPATH
          -- so it's never installed in the project itself.
          dap.adapters.python = function(callback, config)
            local env = vim.fn.environ()
            if debugpy_path then env.PYTHONPATH = debugpy_path .. (env.PYTHONPATH and (":" .. env.PYTHONPATH) or "") end
            local python = config.pythonPath or project_python
            callback {
              type = "executable",
              command = python,
              args = { "-m", "debugpy.adapter" },
              options = { env = env },
            }
          end

          -- Configurations
          dap.configurations.python = {
            {
              type = "python",
              request = "launch",
              name = "Launch current file (project venv)",
              program = "${file}",
              pythonPath = project_python,
              justMyCode = false,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Launch module (-m)",
              module = function() return vim.fn.input "Module name: " end,
              pythonPath = project_python,
              justMyCode = false,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "launch",
              name = "Pytest: current file",
              module = "pytest",
              args = { "${file}", "-v" },
              pythonPath = project_python,
              justMyCode = false,
              console = "integratedTerminal",
            },
            {
              type = "python",
              request = "attach",
              name = "Attach to running process",
              connect = {
                host = "127.0.0.1",
                port = function() return tonumber(vim.fn.input "Port: ") end,
              },
              justMyCode = false,
            },
          }

          -- Wire up dap-python helper functions (test_method, test_class, etc.)
          -- using the project venv's python so they pick up your test dependencies.
          require("dap-python").setup(project_python)
        end,
      },
    },
  },

  -- ============================================================
  -- DAP KEYMAPS
  -- ============================================================
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<F5>"] = { function() require("dap").continue() end, desc = "Debug: Start/Continue" },
          ["<F10>"] = { function() require("dap").step_over() end, desc = "Debug: Step Over" },
          ["<F11>"] = { function() require("dap").step_into() end, desc = "Debug: Step Into" },
          ["<F12>"] = { function() require("dap").step_out() end, desc = "Debug: Step Out" },
          ["<S-F5>"] = { function() require("dap").terminate() end, desc = "Debug: Stop" },

          ["<Leader>db"] = { function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
          ["<Leader>dB"] = {
            function() require("dap").set_breakpoint(vim.fn.input "Condition: ") end,
            desc = "Conditional breakpoint",
          },
          ["<Leader>dc"] = { function() require("dap").continue() end, desc = "Continue" },
          ["<Leader>dC"] = { function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
          ["<Leader>do"] = { function() require("dap").step_over() end, desc = "Step over" },
          ["<Leader>di"] = { function() require("dap").step_into() end, desc = "Step into" },
          ["<Leader>dO"] = { function() require("dap").step_out() end, desc = "Step out" },
          ["<Leader>dr"] = { function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
          ["<Leader>dl"] = { function() require("dap").run_last() end, desc = "Run last" },
          ["<Leader>du"] = { function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
          ["<Leader>dt"] = { function() require("dap").terminate() end, desc = "Terminate" },
          ["<Leader>dh"] = { function() require("dap.ui.widgets").hover() end, desc = "Hover variable" },

          ["<Leader>dn"] = {
            function() require("dap-python").test_method() end,
            desc = "Debug Python test (method)",
          },
          ["<Leader>df"] = {
            function() require("dap-python").test_class() end,
            desc = "Debug Python test (class)",
          },
        },
        v = {
          ["<Leader>ds"] = { function() require("dap-python").debug_selection() end, desc = "Debug selection" },
        },
      },
    },
  },

  -- ============================================================
  -- TESTING
  -- ============================================================
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "nvim-neotest/neotest-python", config = function() end },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(
        opts.adapters,
        require "neotest-python" {
          python = venv_python(),
          runner = "pytest",
          dap = { justMyCode = false },
        }
      )
    end,
  },

  -- ============================================================
  -- FORMATTING
  -- ============================================================
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufRead" },
    optional = false,
    cmd = { "Conform" },
    opts = {
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 3000,
      },
      formatters_by_ft = {
        python = { "ruff_organize_imports", "ruff_format" },
      },
    },
  },
}
