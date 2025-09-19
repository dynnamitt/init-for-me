vim.g.mapleader = " " -- sets leader key

vim.opt.mouse = "a"

-- sensible defaults by mini.basics
-- Others see: https://www.youtube.com/watch?v=I5kT2c2XX38
vim.opt.winborder = 'rounded'
vim.opt.expandtab = false -- expand tab
vim.opt.smartindent = true
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.showmode = true
vim.opt.scrolloff = 8 -- scroll page when cursor is 8 lines from top/bottom
vim.opt.sidescrolloff = 8
vim.opt.relativenumber = true
vim.opt.wrap = false -- Don't wrap lines

vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_sizestyle = "H"
vim.g.netrw_liststyle = 3


vim.opt.tabstop = 4        -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4     -- Number of spaces to use for each step of ( auto)indent
vim.opt.softtabstop = 4    -- Number of spaces that a <Tab> counts for while editing
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart autoindenting when starting a new line
vim.opt.autoindent = true  -- Copy indent from current line when starting new line


vim.opt.swapfile = false
vim.opt.clipboard = 'unnamed'


vim.keymap.set('n', '<leader>m', ':update<CR>:source $MYVIMRC<CR>', { desc = '$MYVIMRC reload' })
vim.keymap.set('n', '<leader>w', ':lua vim.lsp.buf.format()<CR>:update<CR>', { desc = 'format & update' })
vim.keymap.set('n', '<leader>q', ':quit<CR>', { desc = 'quit' })

local function gh_cache_packadd(repo, branch, dest)
    local gh_pre_ = os.getenv('GH_PRE')
    local gh_pre = gh_pre_ ~= nil and gh_pre_ or 'https://github.com'
    local url = gh_pre .. '/' .. repo .. '/archive/' .. branch .. '.tar.gz'

    if vim.uv.fs_stat(dest) then
        vim.cmd('echo "' .. dest .. ' exist, abort fetch" | redraw')
        return true
    else
        local debug = "Fetch tar from " .. url .. " > " .. dest
        vim.cmd('echo "' .. debug .. '" | redraw')
    end

    -- Ensure destination directory exists
    vim.fn.mkdir(dest, 'p')

    local tar_ = vim.fn.has('mac') == 1 and 'gtar' or 'tar'
    local fetch_cmd = 'curl -sL ' .. url .. ' | ' .. tar_ .. ' -xzvf - --strip-component=1 -C ' .. dest
    local result = vim.fn.system(fetch_cmd)
    local exit_code = vim.v.shell_error
    if exit_code ~= 0 then
        local error_msg = "Failed to fetch " .. url .. ": " .. (result or "Unknown error")
        vim.cmd('echoerr "' .. error_msg:gsub('"', '\\"') .. '"')
        vim.fn.rmdir(dest)
        return false
    else
        local packname_ = vim.fs.basename(dest)
        vim.cmd("packadd " .. packname_ .. " | helptags ALL")
        vim.cmd('echo "Installed `' .. packname_ .. '`" | redraw')
        return true
    end
end

local my_packs_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/"

-- my packs -----------------
gh_cache_packadd("nvim-mini/mini.nvim", "main", my_packs_path .. 'mini.nvim')
gh_cache_packadd("neovim/nvim-lspconfig", "v2.4.0", my_packs_path .. "nvim.lspconfig")
gh_cache_packadd("nvim-treesitter/nvim-treesitter", "master", my_packs_path .. "nvim.treesitter")
gh_cache_packadd("kndndrj/nvim-dbee", "v0.1.9", my_packs_path .. "nvim-dbee")
gh_cache_packadd("folke/noice.nvim", "main", my_packs_path .. "noice.nvim")
gh_cache_packadd("MunifTanjim/nui.nvim", "main", my_packs_path .. "nui.nvim")

-- now I can use below
--
--
--

vim.cmd [[
	set path+=**
    set completeopt+=noselect
    colorscheme minicyan
	filetype plugin on
]]
-- noice ---------------------------------------------------
require("noice").setup()

-- treesitter ----------------------------------------------
local ts_dynlibs = vim.fn.stdpath("data") .. "/ts-libs"
vim.fn.mkdir(ts_dynlibs, 'p')
vim.opt.runtimepath:prepend(ts_dynlibs)
-- Override for ALL parsers
local parser_configs = require 'nvim-treesitter.parsers'.get_parser_configs()
for lang, config in pairs(parser_configs) do
    config.install_info.path = ts_dynlibs
end

-- Also set default for future parsers
require 'nvim-treesitter.configs'.setup {
    parser_install_dir = ts_dynlibs,
    -- your other config...
    highlight = { enable = true },
    additional_vim_regex_highlighting = false,
    fold = { enable = true },
}
-- Enable folding
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false -- Start with folds open

-- LSP / Language Server Protocol ------------------------------
vim.lsp.enable({
    "emmylua_ls",
    "rust_analyzer",
    "lemminx",
    "bashls",
    "ts_ls",
}
)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end
    ,
})
vim.keymap.set({ 'n', 'v' }, '<leader>l', "", { desc = 'LSP' }) -- Group KEYMAP(s)
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = 'LSP Format' })
vim.keymap.set('v', '<leader>lf', function()
    vim.lsp.buf.format({ range = true })
end, { desc = 'LSP Format selection' })

-- mini.pick ---------------------------------------------------
require('mini.pick').setup()
vim.keymap.set('n', '<leader>f', ':Pick files<CR>', { desc = 'files' })
vim.keymap.set('n', '<leader>h', ':Pick help<CR>', { desc = 'help' })
vim.keymap.set('n', '<leader>t', ':Pick treesitter<CR>', { desc = 'treesitter' })
vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>', { desc = 'buffers' })
vim.keymap.set('n', '<leader>r', ':Pick registers<CR>', { desc = 'registers' })
vim.keymap.set('n', '<leader>d', ':Pick diagnostic<CR>', { desc = 'diagnostic' })


-- mini.clue ---------------------------------------------------
local miniclue = require('mini.clue')
miniclue.setup({
    triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' }, { mode = 'x', keys = '<Leader>' },
        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- `g` key
        { mode = 'n', keys = 'g' }, { mode = 'x', keys = 'g' },

        -- Marks
        { mode = 'n', keys = "'" }, { mode = 'n', keys = '`' }, {
        mode = 'x',
        keys = "'"
    }, { mode = 'x', keys = '`' },

        -- Registers
        { mode = 'n', keys = '"' }, { mode = 'x', keys = '"' }, {
        mode = 'i',
        keys = '<C-r>'
    }, { mode = 'c', keys = '<C-r>' },

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

require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.basics').setup({ extra_ui = true, win_borders = 'dotted' })
require('mini.extra').setup()
require('mini.completion').setup()
require('mini.indentscope').setup()

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
        todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
        note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },

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


--
-- -- Tab bindings
-- map("n", "<leader>tt", ":tabnew<CR>",{desc='Tab - new'})			-- space+tt creates new tab
-- map("n", "<leader>tx", ":tabclose<CR>")			-- space+tx closes current tab
-- map("n", "<leader>tj", ":tabprevious<CR>")		-- space+tj moves to previous tab
-- map("n", "<leader>tk", ":tabnext<CR>")			-- space+tk moves to next tab
--
