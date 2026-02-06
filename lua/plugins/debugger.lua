-- Debugger setup
vim.pack.add({
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/mfussenegger/nvim-dap-python" },
    { src = "https://github.com/igorlfs/nvim-dap-view" },
})

require("dap-python").setup("uv")
require("dap-view").setup({
    winbar = {
        show = true,
        sections = { "watches", "scopes", "threads", "repl" },
        default_section = "scopes",
        show_keymap_hints = true,
        controls = {
            enabled = true,
            position = "right",
        },
    },
    windows = {
        size = 0.5,
        position = "right",
        terminal = {
            size = 0.35,
            position = "below",
        },
    },
})

-- Make DAP signs pretty
vim.fn.sign_define("DapBreakpoint", {
  text = "🔴",
  texthl = "DiagnosticError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "🟠",
  texthl = "DiagnosticWarn",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapLogPoint", {
  text = "📝",
  texthl = "DiagnosticInfo",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "➡️",
  texthl = "DiagnosticHint",
  linehl = "Visual",  -- highlight the whole line where execution stops (optional)
  numhl = "",
})

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local dap = require("dap")
local dapview = require("dap-view")

map("n", "<leader>dc",  dap.continue,          opts)
map("n", "<leader>j", dap.step_over,         opts)
map("n", "<leader>l", dap.step_into,         opts)
map("n", "<leader>h", dap.step_out,          opts)

-- Breakpoints
map("n", "<leader>db", dap.toggle_breakpoint, opts)
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, opts)
map("n", "<leader>dl", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, opts)

-- Automatically open dap-view when debug session launched
dap.listeners.after.event_initialized["dapview_open"] = function()
  dapview.open()
end

-- Set working directory for debugger
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file (choose cwd)",
    program = "${file}",
    cwd = function()
      return vim.fn.input(
        "CWD: ",
        vim.fn.getcwd(),
        "dir"
      )
    end,
    console = "integratedTerminal",
  },
}

local function any_dap_windows_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "dap-view" or ft == "dap-repl" or ft == "dap-terminal" then
      return true
    end
  end
  return false
end

local function focus_best_non_dap_window()
  -- Prefer a normal editing window (not dap-view, not terminals, not quickfix)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    if ft ~= "dap-view" and ft ~= "dap-repl" and ft ~= "dap-terminal"
      and bt ~= "terminal" and bt ~= "quickfix" then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end

local function dv_behavior()
  if any_dap_windows_open() then
    -- ensure :only keeps an editor window, not the dap window
    focus_best_non_dap_window()
    vim.cmd("only")
  else
    -- normal behavior when dap isn't open
    dapview.toggle()
  end
end

map("n", "<leader>dv", dv_behavior, opts)

