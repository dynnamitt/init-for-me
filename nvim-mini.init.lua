vim.g.mapleader = " "		-- sets leader key

-- sensible defaults by mini.basics 
-- Others see: https://www.youtube.com/watch?v=I5kT2c2XX38
vim.opt.winborder = 'rounded'
vim.opt.expandtab = false				-- expand tab 
vim.opt.smartindent = true
vim.opt.showcmd = true
vim.opt.cmdheight = 2
vim.opt.showmode = true
vim.opt.scrolloff = 8					-- scroll page when cursor is 8 lines from top/bottom
vim.opt.sidescrolloff = 8			


local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		-- Uncomment next line to use 'stable' branch
		-- '--branch', 'stable',
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

vim.cmd [[
	colorscheme minicyan
	set path+=**
	filetype plugin on
	set wildmenu
]]


local mini_files = require('mini.files')

mini_files.setup({})

vim.keymap.set('n', '<leader>ff', function()
  if mini_files.close() then
    return
  end

  mini_files.open()
end, {desc='Files popup'})

local miniclue = require('mini.clue')
miniclue.setup({ triggers = {
	-- Leader triggers
	{ mode = 'n', keys = '<Leader>' }, { mode = 'x', keys = '<Leader>' },
	
	-- Built-in completion
	{ mode = 'i', keys = '<C-x>' },

	-- `g` key
	{ mode = 'n', keys = 'g' }, { mode = 'x', keys = 'g' },

	-- Marks
	{ mode = 'n', keys = "'" }, { mode = 'n', keys = '`' }, { mode = 'x',
	keys = "'" }, { mode = 'x', keys = '`' },

	-- Registers
	{ mode = 'n', keys = '"' }, { mode = 'x', keys = '"' }, { mode = 'i',
	keys = '<C-r>' }, { mode = 'c', keys = '<C-r>' },

	-- Window commands
	{ mode = 'n', keys = '<C-w>' },

	-- `z` key
	{ mode = 'n', keys = 'z' }, { mode = 'x', keys = 'z' },
},

	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping
		-- groups
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(), miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(), miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(), 
	},
})

require('mini.icons').setup({})
require('mini.basics').setup({extra_ui = true,win_borders='dotted'})
require('mini.extra').setup({})
require('mini.completion').setup({})
require('mini.indentscope').setup()

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
    todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
    note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

local mini_keymap = require('mini.keymap')
local map_combo = mini_keymap.map_combo

-- Support most common modes. This can also contain 't', but would
-- only mean to press `<Esc>` inside terminal.
local mode = { 'i', 'c', 'x', 's' }
map_combo(mode, 'jk', '<BS><BS><Esc>')

-- To not have to worry about the order of keys, also map "kj"
map_combo(mode, 'kj', '<BS><BS><Esc>')

-- Escape into Normal mode from Terminal mode
map_combo('t', 'jk', '<BS><BS><C-\\><C-n>')
map_combo('t', 'kj', '<BS><BS><C-\\><C-n>')

local notify_many_keys = function(key)
  local lhs = string.rep(key, 5)
  local action = function() vim.notify('🤨🤨🤨🤨🤨 Too many ' .. key) end
  mini_keymap.map_combo({ 'n', 'x' }, lhs, action)
end
notify_many_keys('h')
notify_many_keys('j')
notify_many_keys('k')
notify_many_keys('l')

vim.api.nvim_set_keymap('n', '<leader>r', ':source $MYVIMRC<CR>', {desc='reload $MYVIMRC'})

--
-- -- Tab bindings 
-- map("n", "<leader>tt", ":tabnew<CR>",{desc='Tab - new'})			-- space+tt creates new tab
-- map("n", "<leader>tx", ":tabclose<CR>")			-- space+tx closes current tab
-- map("n", "<leader>tj", ":tabprevious<CR>")		-- space+tj moves to previous tab
-- map("n", "<leader>tk", ":tabnext<CR>")			-- space+tk moves to next tab
--

