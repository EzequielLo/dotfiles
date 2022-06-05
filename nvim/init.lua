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
  -- UI to select things (files, grep results, open buffers...)
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  -- Add indentation guides even on blank lines
  use 'lukas-reineke/indent-blankline.nvim'
  -- Highlight, edit, and navigate code using a fast incremental parsing library
  use 'nvim-treesitter/nvim-treesitter'
  -- Additional textobjects for treesitter
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  -- LSP
  use 'neovim/nvim-lspconfig' 
  use 'williamboman/nvim-lsp-installer'
  -- Autocompletion plugin
  use 'hrsh7th/nvim-cmp'   
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  -- Snippets plugin
  use 'L3MON4D3/LuaSnip'   
  -- Snippets vs code 
  use 'johnpapa/vscode-angular-snippets'
  use 'andys8/vscode-jest-snippets'
  -- Optional
  use 'alvan/vim-closetag'
  use 'tpope/vim-surround'
  use 'phaazon/hop.nvim'
	use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require("trouble").setup {}
  end
}
  -- "gc" to comment visual regions/lines
  use 'numToStr/Comment.nvim'   
  use 'editorconfig/editorconfig-vim'
  use 'mfussenegger/nvim-lint'
  use 'rust-lang/rust.vim'
  -- Git
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } }
  use 'sindrets/diffview.nvim'
  use 'TimUntersberger/neogit'	
  -- Tmux
  use 'christoomey/vim-tmux-navigator'
  -- Theme
  use "EzequielLo/custom_git.nvim"

end) 
vim.cmd[[
runtime lua/autopairs.vim
let g:closetag_filenames = '*.html,*.js,*.jsx,*.ts,*.tsx'
" Remap surround to lowercase s so it does not add an empty space
xmap s <Plug>VSurround
]]

vim.o.laststatus=3
--Set highlight on search
vim.o.hlsearch = false

--Make line numbers default
vim.wo.number = true

--Enable mouse mode
vim.o.mouse = 'a'

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.background = "dark"
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'
vim.o.showmode = false
vim.o.shiftwidth = 2
vim.o.tabstop = 2
--Set colorscheme
vim.o.termguicolors = true
vim.cmd [[
syntax enable
filetype plugin indent on
colorscheme custom_git
]]

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'
vim.cmd[[let $FZF_DEFAULT_COMMAND = 'rg --files --hidden']]

--Remap escape to leave terminal mode
vim.keymap.set('t', '<Esc>', [[<c-\><c-n>]])

--Disable numbers in terminal mode
local terminal_group = vim.api.nvim_create_augroup("Terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", { command = "set nonu", group = terminal_group})

-- StatusLine
local fn = vim.fn
local api = vim.api

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
  ["n"] = "N",
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
      " [+%s ~%s -%s] [ %s] ",
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

M.set_active = function(self)
  return table.concat {
    "%#StatusLine#",
    self:get_current_mode(),
    "%#StatusLineAccent#",
    self:get_line_col(),
    "%#StatusLine#",
    self:get_filename(),
    "%=",
    self:lsp_progress(),
    self:get_filetype(),
    self:get_git_status(),
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

vim.cmd[[
" tmux navigator
nnoremap <silent> <Leader><C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <Leader><C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <Leader><C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <Leader><C-l> :TmuxNavigateRight<cr>	
]]

-- Hop.
vim.keymap.set("n", "<Leader>p", "<CMD>HopWord<CR>", {noremap = true,silent = true,})

-- Lint
require('lint').linters_by_ft = {
  -- php = {'phpcs'}
  typescript = {'eslint'},
  javascript = {'eslint'},
  -- lua = {'luacheck'},
  -- markdown = {'markdownlint', 'proselint'},
}

vim.cmd([[
  augroup NvimLint
    au!
    au BufRead * lua require('lint').try_lint()
    au BufWritePost * lua require('lint').try_lint()
  augroup end
]])

--Enable Comment.nvim
require('Comment').setup()

--Remap space as leader key
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
--Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- usage
vim.api.nvim_set_keymap('n','<leader>w', ':w<cr>',{noremap = true, silent = true})
--Add move line shortcuts
vim.api.nvim_set_keymap('n', '<A-j>', ':m .+1<CR>==', { noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', ':m .-2<CR>==', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-j>', ':m \'>+1<CR>gv=gv', { noremap = true})
vim.api.nvim_set_keymap('v', '<A-k>', ':m \'<-2<CR>gv=gv', { noremap = true})

--Git
local neogit = require('neogit')
neogit.setup {
  disable_signs = true,
  disable_hint = true,
  disable_builtin_notifications = true,
  integrations = {
    diffview = true
  }
}

--shortcuts
vim.keymap.set('n', '<leader>gd', ':DiffviewOpen<CR>', { silent = true })
vim.keymap.set('n', '<leader>ng', ':Neogit<CR>', { silent = true })
-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

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

require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }

-- Telescope
require('telescope').setup {
	defaults = {
		layout_config = {prompt_position = "top"},
		prompt_prefix   = " ",
		selection_caret = "> ",
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
  },
}

-- Enable telescope fzf native
require('telescope').load_extension 'fzf'
--Add leader shortcuts
function TelescopeFiles()
  local telescope_opts = { previewer = false }
  local ok = pcall(require('telescope.builtin').git_files, telescope_opts)
  if not ok then
    require('telescope.builtin').find_files(telescope_opts)
  end
end

--Add leader shortcuts
vim.keymap.set('n', '<C-b>', require('telescope.builtin').buffers)
vim.keymap.set('n', '<C-p>', function()
  require('telescope.builtin').find_files { previewer = false }
end)
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').current_buffer_fuzzy_find)
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags)
vim.keymap.set('n', '<leader>st', require('telescope.builtin').tags)
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').grep_string)
vim.keymap.set('n', '<leader>sp', require('telescope.builtin').live_grep)
vim.keymap.set('n', '<leader>so', function()
  require('telescope.builtin').tags { only_current_buffer = true }
end)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles)

-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
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

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

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
	 local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<leader>wl', function()
    vim.inspect(vim.lsp.buf.list_workspace_folders())
  end, opts)
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>so', require('telescope.builtin').lsp_document_symbols, opts)
  vim.api.nvim_create_user_command("Format", vim.lsp.buf.formatting, {})

  local rc = client.resolved_capabilities 
  if client.name == "angularls" then
    rc.rename = false
  end
	
	if client.resolved_capabilities.document_formatting then
		vim.cmd([[
			augroup formatting
				autocmd! * <buffer>
				autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
				autocmd BufWritePre <buffer> lua OrganizeImports(1000)
			augroup END
		]])
	end
	-- Set autocommands conditional on server_capabilities
	if client.resolved_capabilities.document_highlight then
		vim.cmd([[
			augroup lsp_document_highlight
				autocmd! * <buffer>
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup END
		]])
	end
end

lsp_installer.setup{}
local lspconfig = require('lspconfig')

lspconfig.angularls.setup{
	capabilities = capabilities,
	on_attach = on_attach,
}

lspconfig.html.setup{
	capabilities = capabilities,
	on_attach = on_attach,
}

lspconfig.emmet_ls.setup{
	capabilities = capabilities,
	filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'css', 'sass', 'scss', 'less' },
}

lspconfig.cssls.setup{
	capabilities = capabilities,
	on_attach = on_attach,
}

lspconfig.tsserver.setup{
	capabilities = capabilities,
	on_attach = on_attach,
}

lspconfig.rust_analyzer.setup{
	cmd = { "rustup", "run", "nightly", "rust-analyzer" },
	capabilities = capabilities,
	on_attach = on_attach,
}

lspconfig.jsonls.setup{
  capabilities = capabilities,
}

lspconfig.eslint.setup{
	capabilities = capabilities,
	on_attach = on_attach,
	   codeActionOnSave = {
        enable = true,
        mode = 'all',
      },
}

-- organize imports
-- https://github.com/neovim/nvim-lspconfig/issues/115#issuecomment-902680058
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

-- luasnip setup
local luasnip = require 'luasnip'
require("luasnip.loaders.from_vscode").lazy_load()
-- nvim-cmp setup
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
-- vim: ts=2 sts=2 sw=2 et
local vim = vim
local api = vim.api
local M = {}
function M.map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
function M.mapBuf(buf, mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, options)
end

-- Custom jump around Angular component parts
M.map("n", "<leader>tm", "<cmd>lua require('custom').jump_to_nearest_module()<cr>")
M.map("n", "<leader>ts", "<cmd>lua require('custom').jump_to_angular_component_part('ts')<cr>")
M.map("n", "<leader>th", "<cmd>lua require('custom').jump_to_angular_component_part('html')<cr>")
M.map("n", "<leader>tc", "<cmd>lua require('custom').jump_to_angular_component_part('css')<cr>")
M.map("n", "<leader>tt", "<cmd>lua require('custom').jump_to_angular_component_part('spec%.ts')<cr>")



