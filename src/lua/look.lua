--[[
" figlet -f stampatello theovim-look
" .  .                           .          .
" |- |-. ,-. ,-. .  , . ,-,-.    |  ,-. ,-. | ,
" |  | | |-' | | | /  | | | | -- |  | | | | |<
" `' ' ' `-' `-' `'   ' ' ' '    `' `-' `-' ' `
--]]
-- {{{ Theme Settings
require("onedark").setup({
  style = "dark",
  transparent = false,
  toggle_style_key = "<leader>od",
  toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer" },
  code_style = {
    comments = "italic",
    keywords = "bold",
    functions = 'none',
    strings = 'none',
    variables = 'none'
  },
  colors_save = {
    black       = "#151820",
    bg0         = "#282A35",
    bg1         = "#2d3343",
    bg2         = "#343e4f",
    bg3         = "#363c51",
    bg_d        = "#1e242e",
    bg_blue     = "#6db9f7",
    bg_yellow   = "#f0d197",
    fg          = "#dcdede",
    purple      = "#ae79f2",
    green       = "#69c273",
    orange      = "#f29950",
    blue        = "#5ab0f6",
    yellow      = "#faeb89",
    cyan        = "#4dbdcb",
    red         = "#f26161",
    grey        = "#737373",
    light_grey  = "#7d899f",
    dark_cyan   = "#25747d",
    dark_red    = "#a13131",
    dark_yellow = "#9a6b16",
    dark_purple = "#8f36a9",
    diff_add    = "#303d27",
    diff_delete = "#3c2729",
    diff_change = "#18344c",
    diff_text   = "#265478",
  },
})
require("onedark").load()
-- }}}

-- {{{ Bufferline Settings
require("bufferline").setup({
  maximum_padding = 1,
  maximum_length = 30,
  icon_separator_active = '',
})
-- Compitability w/ nvim-tree --
local nvim_tree_events = require("nvim-tree.events")
local bufferline_api = require("bufferline.api")
local function get_tree_size()
  return require("nvim-tree.view").View.width
end
nvim_tree_events.subscribe("TreeOpen", function() bufferline_api.set_offset(get_tree_size()) end)
nvim_tree_events.subscribe("Resize", function() bufferline_api.set_offset(get_tree_size()) end)
nvim_tree_events.subscribe("TreeClose", function() bufferline_api.set_offset(0) end)
-- }}}

-- {{{ Lualine (Status bar) Settings
--[[
Inspired by examples/evil_lualine.lua in the plug-in repository, but utilizing position B and Y
+-------------------------------------------------+
| A | B | C                             X | Y | Z |
+-------------------------------------------------+
--]]
local lualine = require("lualine")

local colors = {
  bg           = "#282a36",
  current_line = "#6272a4",
  fg           = "#f8f8f2",
  comment      = "#6272a4",
  cyan         = "#8be9fd",
  green        = "#50fa7b",
  orange       = "#ffb86c",
  pink         = "#ff79c6",
  purple       = "#bd93f9",
  red          = "#ff5555",
  yellow       = "#f1fa8c",
  darkblue     = '#081633',
  violet       = '#a9a1e1',
  magenta      = '#c678dd',
  blue         = '#51afef',
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Default Lualine config table to remove defaults
local config = {
  options = {
    component_separators = '',
    section_separators = '',
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    lualine_a = { { "filename", file_status = true, path = 0 } }, --> 0 (default) file name, 1 relative path, 2 abs path
    lualine_b = {},
    lualine_c = {},
    lualine_x = { "diagnostics" },
  },
}

local function ins_far_left(component)
  table.insert(config.sections.lualine_b, component)
end

local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

local function ins_far_right(component)
  table.insert(config.sections.lualine_y, component)
end

-- Reminder that you can invoke Lua function without parentheses, but moving forward I prefer having them
ins_far_left {
  function()
    return ''
  end,
  color = { fg = colors.blue },
  padding = { left = 0, right = 1 },
}

ins_far_left({
  function()
    return ' ' .. vim.fn.mode()
  end,
  color = function()
    local mode_color = {
      n = colors.current_line,
      no = colors.current_line,
      i = colors.cyan,
      v = colors.yellow,
      [''] = colors.yellow,
      V = colors.yellow,
      R = colors.orange,
      rm = colors.orange,
      ['r?'] = colors.orange,
      t = colors.purple,
      ['!'] = colors.purple,
      c = colors.bg,
      ic = colors.bg,
      cv = colors.bg,
      ce = colors.bg,
      -- Modes that I'm not interested in are all rendered in comment color
      s = colors.comment,
      S = colors.comment,
      [''] = colors.comment,
    }
    return { fg = mode_color[vim.fn.mode()] }
  end,
  padding = { right = 1 },
})

ins_left({
  "filename",
  cond = conditions.buffer_not_empty,
  color = { fg = colors.magenta, gui = "bold" },
})

ins_left({
  "branch",
  icon = '',
  color = { fg = colors.violet, gui = "bold" },
})

ins_left({
  "diff",
  symbols = { added = ' ', modified = ' ', removed = ' ' },
  diff_color = {
    added = { fg = colors.green },
    modified = { fg = colors.orange },
    removed = { fg = colors.red },
  },
  cond = conditions.hide_in_width,
})

-- Making middle section
ins_left({
  function()
    return "%=" -- Big empty room so that ins_left inserts to the middle
  end,
})

ins_left({
  function()
    local no_msg = "No LSP"
    local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
    local clients = vim.lsp.get_active_clients()
    if next(clients) == nil then
      return no_msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return no_msg
  end,
  icon = " ",
  color = { fg = colors.cyan, gui = "bold" },
})

ins_left {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
  diagnostics_color = {
    color_error = { fg = colors.red },
    color_warn = { fg = colors.yellow },
    color_info = { fg = colors.cyan },
  },
}

ins_right({ "filetype", color = { fg = colors.orange, gui = "bold" } })

ins_right({
  "o:encoding",
  fmt = string.upper,
  cond = conditions.hide_in_width,
  color = { fg = colors.green, gui = "bold" },
})

ins_right({
  "fileformat",
  fmt = string.upper,
  icons_enabled = true, -- Prints out UNIX or penguin icon
  color = { fg = colors.green, gui = "bold" },
})

ins_far_right({ "location" })

ins_far_right({ "progress", color = { fg = colors.fg, gui = "bold" } })

ins_far_right({
  function()
    return ''
  end,
  color = { fg = colors.blue },
  padding = { left = 1 },
})

lualine.setup(config)
-- }}}

-- {{{ Dashboard Settings
local db = require("dashboard")
db.setup({
  theme = 'doom',
  config = {
    header = {
      "", "", "", "", "", "",
      "                                                                    ",
      "                             .---....___                            ",
      "                    __..--''``          `` _..._    __              ",
      "          /// //_.-'    .-/';  `         `<._  ``.''_ `. / // /     ",
      "         ///_.-' _..--.'_    ;                    `( ) ) // //      ",
      "         / (_..-' // (< _     ;_..__               ; `' / ///       ",
      "          / // // //  `-._,_)' // / ``--...____..-' /// / //        ",
      "                                                                    ",
      " ------------------------- Hi I'm Oliver -------------------------- ",
      "                                                                    ",
      "    ,--------.,--.                            ,--.                  ",
      "    '--.  .--'|  ,---.  ,---.  ,---.,--.  ,--.`--',--,--,--.        ",
      "       |  |   |  .-.  || .-. :| .-. |\\  `'  / ,--.|        |        ", --> Quote out of place bc of escape sequence
      "       |  |   |  | |  |\\   --.' '-' ' \\    /  |  ||  |  |  |        ",
      "       `--'   `--' `--' `----' `---'   `--'   `--'`--`--`--'        ",
      "                                                                    ",
      "",
      os.date("                 Today is %A, %d %B %Y                 "),
      "",
    },
    center = {
      {
        icon = "󰥨  ",
        desc = "Find File           ",
        key = "spc ff",
        action = "Telescope find_files",
      },
      {
        icon = "  ",
        desc = "Browse Files        ",
        key = "spc fb",
        action = "Telescope file_browser",
      },
      {
        icon = "  ",
        desc = "New File             ",
        key = "spc n",
        action = "enew",
      },
      {
        icon = "  ",
        desc = "Configure Theovim         ",
        action = "vim.notify(\"Coming soon!\")",
      },
      {
        icon = "  ",
        desc = "Exit Theovim              ",
        action = "quit",
      },
    },
    footer = { os.date("Theovim %Y") }
  }
})
-- }}}
