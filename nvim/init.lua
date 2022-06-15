-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })

vim.api.nvim_create_autocmd('BufWritePost', { command = 'source <afile> | PackerCompile', group = packer_group, pattern = 'init.lua' })

require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'
	-- Menu
	use "justinmk/vim-dirvish"
  -- UI to select things (files, grep results, open buffers...)
  use {'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' },}
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  -- Icons
  use "kyazdani42/nvim-web-devicons"
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
	use "p00f/nvim-ts-rainbow"
  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  -- Autocompletion plugin
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  -- Snippets
  use 'L3MON4D3/LuaSnip' --plugin
  use 'johnpapa/vscode-angular-snippets'
  use 'andys8/vscode-jest-snippets'
  -- IDE
  use 'alvan/vim-closetag'
  use 'tpope/vim-surround'
  use 'tpope/vim-repeat'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'editorconfig/editorconfig-vim'
	use "norcalli/nvim-colorizer.lua" --css colors
  use 'mfussenegger/nvim-lint'
  -- Git
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  -- Theme
  use "EzequielLo/custom_git.nvim"
end)

vim.cmd[[
runtime lua/autopairs.vim
let g:closetag_filenames = '*.html,*.js,*.jsx,*.ts,*.tsx'
" Remap surround to lowercase s so it does not add an empty space
xmap s <Plug>VSurround
filetype plugin indent on
]]

vim.o.laststatus=3
vim.o.hlsearch = false
vim.wo.number = true
vim.o.mouse = 'a'
vim.o.breakindent = true
vim.opt.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.showmode = false
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.cmdheight=0
--Set colorscheme
vim.o.background = "light"
vim.o.termguicolors = true
vim.cmd [[
syntax enable
colorscheme custom_git
]]
vim.g.netrw_banner = 0

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
vim.cmd[[let $FZF_DEFAULT_COMMAND = 'rg --files --hidden']]

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

--Enable Comment.nvim
require('Comment').setup()

-- CSS colors
require'colorizer'.setup()

-- Lint
require('lint').linters_by_ft = {
  typescript = {'eslint'},
  javascript = {'eslint'},
}

local augroups = {}

augroups.misc = {
	trigger_nvim_lint = {
		event = {"BufEnter", "BufNew", "InsertLeave", "TextChanged"},
		pattern = "<buffer>",
		callback = function ()
			require("lint").try_lint()
		end,
	},
}

for group, commands in pairs(augroups) do
	local augroup = vim.api.nvim_create_augroup("AU_"..group, {clear = true})

	for _, opts in pairs(commands) do
		local event = opts.event
		opts.event = nil
		opts.group = augroup
		vim.api.nvim_create_autocmd(event, opts)
	end
end

-- Indent blankline
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}

--Telescope
require('telescope').setup {
  defaults = {
		sorting_strategy = "ascending",
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
  extensions = {
    fzf = {
      override_generic_sorter = true, --override the generic sorter
      override_file_sorter = true, --override the file sorter
      case_mode = 'smart_case', --or "ignore_case" or "respect_case"
    },
	}
}
require('telescope').load_extension 'fzf'

--Add leader shortcuts
function TelescopeFiles()
  local telescope_opts = { previewer = false }
  local ok = pcall(require('telescope.builtin').git_files, telescope_opts)
  if not ok then
    require('telescope.builtin').find_files(telescope_opts)
  end
end

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
	  rainbow = {
    enable = true,
		disable = { "jsx", "tsx", "html" },
    extended_mode = true,
    max_file_lines = nil, -- Do not enable for files with more than n lines, int
	},
  incremental_selection = {
    enable = true,
		    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

--Diagnostic settings
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  update_in_insert = true,
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Native LSP Setup
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.settings({
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(client, bufnr)

	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	-- Mappings.
	local opts = { noremap = true, silent = true }
	-- leaving only what I actually use...
	buf_set_keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
	buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
	buf_set_keymap("n", "<C-j>", "<cmd>Telescope lsp_document_symbols<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<leader>D", "<cmd>Telescope lsp_type_definitions<CR>", opts)
	buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "<leader>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, {buffer=0})
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {buffer=0})
	vim.keymap.set("n", "<leader>dj", vim.diagnostic.goto_next, {buffer=0})
	vim.keymap.set("n", "<leader>dk", vim.diagnostic.goto_prev, {buffer=0})
	vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", {buffer=0})
	vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, {buffer=0})
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {buffer=0})
  vim.api.nvim_buf_create_user_command(bufnr, "Format", vim.lsp.buf.format, {})

  local rc = client.resolved_capabilities
  if client.name == "angularls" then
    rc.rename = false
  end

	if client.server_capabilities.document_formatting then
		vim.cmd([[
			augroup formatting
				autocmd! * <buffer>
				autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
				autocmd BufWritePre <buffer> lua OrganizeImports(1000)
			augroup END
		]])
	end

	-- Set autocommands conditional on server_capabilities
	if client.server_capabilities.document_highlight then
		vim.cmd([[
			augroup lsp_document_highlight
				autocmd! * <buffer>
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup END
		]])
	end
end

-- organize imports
function OrganizeImports(timeoutms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeoutms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

lsp_installer.setup{}
local lspconfig = require('lspconfig')
local util = lspconfig.util

lspconfig.angularls.setup{
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
    debounce_text_changes = 150,
  },
}

lspconfig.html.setup{
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
    debounce_text_changes = 150,
  },
}

lspconfig.emmet_ls.setup{
	capabilities = capabilities,
	filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
	 flags = {
    debounce_text_changes = 150,
  },
}

lspconfig.cssls.setup{
	capabilities = capabilities,
	on_attach = on_attach,
 	flags = {
    debounce_text_changes = 150,
  },
}

lspconfig.tsserver.setup{
	capabilities = capabilities,
	on_attach = on_attach,
	 flags = {
    debounce_text_changes = 150,
  },
}

lspconfig.jsonls.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
	filetypes = {"json", "jsonc"},
  settings = {
    json = {
      -- Schemas https://www.schemastore.org
      schemas = {
        {
          fileMatch = {"package.json"},
          url = "https://json.schemastore.org/package.json"
        },
        {
          fileMatch = {"tsconfig*.json"},
          url = "https://json.schemastore.org/tsconfig.json"
        },
        {
          fileMatch = {
            ".prettierrc",
            ".prettierrc.json",
            "prettier.config.json"
          },
          url = "https://json.schemastore.org/prettierrc.json"
        },
        {
          fileMatch = {".eslintrc", ".eslintrc.json"},
          url = "https://json.schemastore.org/eslintrc.json"
        },
        {
          fileMatch = {".babelrc", ".babelrc.json", "babel.config.json"},
          url = "https://json.schemastore.org/babelrc.json"
        },
        {
          fileMatch = {"now.json", "vercel.json"},
          url = "https://json.schemastore.org/now.json"
        },
        {
          fileMatch = {
            ".stylelintrc",
            ".stylelintrc.json",
            "stylelint.config.json"
          },
          url = "http://json.schemastore.org/stylelintrc.json"
        },
      }
    }
  }
}

lspconfig.eslint.setup{
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
  handlers = {
    ['window/showMessageRequest'] = function(_, result, _) return result end,
  },
}

lspconfig.clangd.setup{
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
    debounce_text_changes = 150,
  },
}

local luasnip = require 'luasnip'
require("luasnip.loaders.from_vscode").lazy_load()

--nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--Add move line shortcuts
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true})

--Git
vim.keymap.set('n', '<leader>ga', ':Git add %:p<CR><CR>', { silent = true })
vim.keymap.set('n', '<leader>gg', ':GBrowse<CR>', { silent = true })
vim.keymap.set('n', '<leader>gd', ':Gdiff<CR>', { silent = true })
vim.keymap.set('n', '<leader>ge', ':Gedit<CR>', { silent = true })
vim.keymap.set('n', '<leader>gr', ':Gread<CR>', { silent = true })
vim.keymap.set('n', '<leader>gw', ':Gwrite<CR><CR>', { silent = true })
vim.keymap.set('n', '<leader>gl', ':silent! Glog<CR>:bot copen<CR>', { silent = true })
vim.keymap.set('n', '<leader>gm', ':Gmove<Space>', { silent = true })
vim.keymap.set('n', '<leader>go', ':Git checkout<Space>', { silent = true })

--vim.keymap.set("n","<C-t>",":Telescope file_browser<CR>",{ noremap = true })
vim.keymap.set('n', '<C-p>', TelescopeFiles)
vim.keymap.set('n', '<leader><space>', function()
  require('telescope.builtin').buffers { sort_lastused = true }
end)

vim.keymap.set(
  'n',
  '<C-f>',
  function()
  require('telescope.builtin').current_buffer_fuzzy_find()
  end
)
vim.keymap.set('n', '<leader>h', function() require('telescope.builtin').help_tags() end)
vim.keymap.set('n', '<leader>st', function() require('telescope.builtin').tags() end)
vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').oldfiles() end)
vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').grep_string() end)
vim.keymap.set('n', '<leader>sp', function() require('telescope.builtin').live_grep() end)

vim.keymap.set('n', '<leader>so', function() require('telescope.builtin').tags { only_current_buffer = true } end)

vim.keymap.set('n', '<leader>gc', function() require('telescope.builtin').git_commits() end)
vim.keymap.set('n', '<leader>gb', function() require('telescope.builtin').git_branches() end)
vim.keymap.set('n', '<leader>gs', function() require('telescope.builtin').git_status() end)
vim.keymap.set('n', '<leader>gp', function() require('telescope.builtin').git_bcommits() end)
vim.keymap.set('n', '<leader>wo', function() require('telescope.builtin').lsp_document_symbols() end)

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

--LSP management
vim.keymap.set('n', '<leader>lr', ':LspRestart<CR>', { silent = true })
vim.keymap.set('n', '<leader>li', ':LspInfo<CR>', { silent = true })
vim.keymap.set('n', '<leader>ls', ':LspStart<CR>', { silent = true })
vim.keymap.set('n', '<leader>lt', ':LspStop<CR>', { silent = true })

-- Statusbar
local fn = vim.fn
local api = vim.api
local lint_active = {}
local M = {}

M.trunc_width = setmetatable({
  git_status = 90,
  filename = 140,
}, {
  __index = function()
    return 80
  end,
})

M.is_truncated = function(_, width)
  local current_width = api.nvim_win_get_width(0)
  return current_width < width
end

M.modes = setmetatable({
  ["n"] = " N ",
  ["no"] = "N·P",
  ["v"] = "V",
  ["V"] = "V·L",
  [""] = "V·B", -- this is not ^V, but it's , they're different
  ["s"] = "S",
  ["S"] = "S·L",
  [""] = "S·B", -- same with this one, it's not ^S but it's 
  ["i"] = "I",
  ["ic"] = "I",
  ["R"] = "R",
  ["Rv"] = "V·R",
  ["c"] = "C",
  ["cv"] = "V·E",
  ["ce"] = "E",
  ["r"] = "P",
  ["rm"] = "RM",
  ["r?"] = "C",
  ["!"] = "S",
  ["t"] = "T",
}, {
  __index = function()
    return "U" -- handle edge cases
  end,
})

M.get_current_mode = function(self)
  local current_mode = api.nvim_get_mode().mode
  return string.format(" [%s] ", self.modes[current_mode]):upper()
end

M.get_git_status = function(self)
  -- use fallback because it doesn't set this variable on the initial `BufEnter`
  local signs = vim.b.gitsigns_status_dict
    or { head = "", added = 0, changed = 0, removed = 0 }
  local is_head_empty = signs.head ~= ""

  if self:is_truncated(self.trunc_width.git_status) then
    return is_head_empty and string.format(" [ %s] ", signs.head or "") or ""
  end
  -- stylua: ignore
  return is_head_empty
    and string.format(
      " +%s ~%s -%s |  %s ",
      signs.added,
      signs.changed,
      signs.removed,
      signs.head
    )
    or ""
end

M.get_filepath = function(self)
  local filepath = fn.fnamemodify(fn.expand "%", ":.:h")
  if
    filepath == ""
    or filepath == "."
    or self:is_truncated(self.trunc_width.filename)
  then
    return " "
  end
  return string.format(" %%<%s/", filepath)
end

M.get_filename = function()
  local filename = fn.expand "%:t"
  return filename == "" and "" or filename
end

M.get_filetype = function()
  local filetype = vim.bo.filetype
  -- stylua: ignore
  return filetype == ""
    and " No FT "
    or string.format("[ft: %s] ", filetype):lower()
end

M.get_fileformat = function()
  return string.format("[%s]", vim.o.fileformat):lower()
end

M.get_line_col = function()
  return "[%l:%c]"
end

M.lsp_progress = function()
  local lsp = vim.lsp.util.get_progress_messages()[1]
  if lsp then
    local name = lsp.name or ""
    local msg = lsp.message or ""
    local percentage = lsp.percentage or 0
    local title = lsp.title or ""
    return string.format(
      " %%<%s: %s %s (%s%%%%) ",
      name,
      title,
      msg,
      percentage
    )
  end
  return ""
end

M.get_lsp_diagnostic = function(self)
local result = {}
  local levels = {
    errors = "Error",
    warnings = "Warn"
  }

  for k, level in pairs(levels) do
    result[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  local errors = ""
  local warnings = ""

	return string.format(
      " :%s :%s ",
      result['errors'] or 0, result['warnings'] or 0
    )
end

M.set_active = function(self)
  return table.concat {
    "%#StatusLine#",
    self:get_lsp_diagnostic(),
    self:get_current_mode(),
    "%#StatusLine#",
		self:get_filename(),
    "%#StatusLineAccent#",
    "%#StatusLine#",
    "%=",
    self:lsp_progress(),
		self:get_git_status(),
		--self:get_filetype(),
  }
end

M.set_inactive = function()
  return "%#StatusLineNC#" .. "%= %F %="
end

M.set_explorer = function()
  return "%#StatusLineNC#"
end

Statusline = setmetatable(M, {
  __call = function(self, mode)
    return self["set_" .. mode](self)
  end,
})

-- set statusline
vim.cmd [[
  augroup Statusline
  au!
  au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline('active')
  au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline('inactive')
  au WinEnter,BufEnter,FileType neo-tree setlocal statusline=%!v:lua.Statusline('explorer')
  augroup END
]]

