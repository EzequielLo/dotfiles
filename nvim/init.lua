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
  -- Core
  use 'tpope/vim-repeat'
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'editorconfig/editorconfig-vim'
  use 'mfussenegger/nvim-lint'
  use "windwp/nvim-autopairs"
  use 'windwp/nvim-ts-autotag'
  use "mbbill/undotree"
  -- Dap
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  use 'theHamsta/nvim-dap-virtual-text'
  -- Git
  use { 'lewis6991/gitsigns.nvim', requires = 'nvim-lua/plenary.nvim'}
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  -- Theme
  use 'EzequielLo/onedark.nvim'
end)

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
vim.o.background = "dark"
vim.o.termguicolors = true
vim.g.tokyonight_style = "storm"
vim.cmd [[
syntax enable
colorscheme custom_theme
autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll
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

require("nvim-autopairs").setup {}

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

local neogit = require('neogit')

neogit.setup {
  integrations = {
    diffview = true
  },
}

require("diffview").setup{}

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
  autotag = {
    enable = true,
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

-- Debugging
local ok, dap = pcall(require, "dap")
if not ok then return end

require("nvim-dap-virtual-text").setup()
require("dapui").setup({
    layouts = {
        {
            elements = {
                "console",
            },
            size = 7,
            position = "bottom",
        },
        {
            elements = {
                -- Elements can be strings or table with id and size keys.
                { id = "scopes", size = 0.25 },
                "breakpoints",
                "stacks",
                "watches",
            },
            size = 40,
            position = "left",
        }
    },
})

local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open(1)
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

local home = os.getenv('HOME')
local dap = require('dap')
dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {home .. '/microsoft-sucks/vscode-node-debug2/out/src/nodeDebug.js'},
}

dap.configurations.javascript = {
    {
        name = 'Launch',
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = vim.loop.cwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
    },
    {
        -- For this to work you need to make sure the node process
        -- is started with the `--inspect` flag.
        name = 'Attach to process',
        type = 'node2',
        request = 'attach',
        processId = require('dap.utils').pick_process,
    },
}

dap.configurations.typescript = {
    {
        name = "ts-node (Node2 with ts-node)",
        type = "node2",
        request = "launch",
        cwd = vim.loop.cwd(),
        runtimeArgs = { "-r", "ts-node/register" },
        runtimeExecutable = "node",
        args = {"--inspect", "${file}"},
        sourceMaps = true,
        skipFiles = { "<node_internals>/**", "node_modules/**" },
    }
}

--Diagnostic settings
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  update_in_insert = true,
}

local signs = { Error = "➜" , Warn = "➜" , Hint = "➜" , Info = "➜"   }
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


local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)

  if client.server_capabilities.document_formatting then
 		vim.cmd([[
 			augroup formatting
 				autocmd! * <buffer>
 				autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
 				autocmd BufWritePre <buffer> lua OrganizeImports(1000)
 			augroup END
 		]])
 	end

-- 	-- Set autocommands conditional on server_capabilities
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
vim.keymap.set('n', '<leader>ng', ':Neogit kind=split<CR>', { silent = true });
vim.keymap.set('n', '<leader>nc', ':Neogit commit<CR>', { silent = true });

--vim.keymap.set("n","<C-t>",":Telescope file_browser<CR>",{ noremap = true })
vim.keymap.set('n', '<leader>.', TelescopeFiles)
vim.keymap.set('n','<leader>f',function()require('telescope.builtin').current_buffer_fuzzy_find() end)
vim.keymap.set('n', '<leader>?', function() require('telescope.builtin').oldfiles() end)
vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').grep_string() end)
vim.keymap.set('n', '<leader>sp', function() require('telescope.builtin').live_grep() end)
vim.keymap.set('n', '<leader>gc', function() require('telescope.builtin').git_commits() end)
vim.keymap.set('n', '<leader>gb', function() require('telescope.builtin').git_branches() end)
vim.keymap.set('n', '<leader>gs', function() require('telescope.builtin').git_status() end)
vim.keymap.set('n', '<leader>gp', function() require('telescope.builtin').git_bcommits() end)
vim.keymap.set('n', '<leader>wo', function() require('telescope.builtin').lsp_document_symbols() end)

--LSP management
vim.keymap.set('n', '<leader>lr', ':LspRestart<CR>', { silent = true })
vim.keymap.set('n', '<leader>li', ':LspInfo<CR>', { silent = true })
vim.keymap.set('n', '<leader>ls', ':LspStart<CR>', { silent = true })
vim.keymap.set('n', '<leader>lt', ':LspStop<CR>', { silent = true })

-- Dap
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>")
vim.keymap.set("n", "<F3>", ":lua require'dap'.step_over()<CR>")
vim.keymap.set("n", "<F2>", ":lua require'dap'.step_into()<CR>")
vim.keymap.set("n", "<F12>", ":lua require'dap'.step_out()<CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
vim.keymap.set("n", "<leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>")
vim.keymap.set("n", "<leader>dc", ":lua require'dap'.repl.run_to_cursor()<CR>")

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
    return is_head_empty and string.format(" [%s] ", signs.head or "") or ""
  end
  -- stylua: ignore
  return is_head_empty
    and string.format(
      " +%s ~%s -%s | %s ",
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
      " e:%s w:%s ",
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


