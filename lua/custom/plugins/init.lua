-- Custom plugins for kickstarter config
--
-- This file contains custom plugin configurations to extend the functionality of Neovim.
-- Each plugin is configured using the Lazy plugin manager syntax.
--
-- General structure of a plugin specification:
-- {
--   'author/plugin-name',  -- Plugin identifier (usually GitHub repo)
--   -- Optional keys:
--   event = 'Event',       -- When to load the plugin
--   cmd = { 'Command' },   -- Load when these commands are used
--   ft = 'filetype',       -- Load for specific filetypes
--   keys = { {...} },      -- Load when these keys are pressed
--   dependencies = {...},  -- Other plugins this plugin depends on
--   config = function()    -- Function to run after the plugin is loaded
--     -- Plugin setup goes here
--   end,
--   opts = {...}           -- Table of options to pass to the plugin's setup function
-- }

return {
  -- Window Management
  {
    'mrjones2014/smart-splits.nvim',
    event = 'VimEnter', -- Load the plugin when Vim starts
    config = function()
      -- Smart Splits allows for easy management of Neovim splits (windows)
      local smart_splits = require 'smart-splits'

      -- Key mappings for resizing splits
      -- <A-key> means Alt+key
      local resize_mappings = {
        ['<A-h>'] = smart_splits.resize_left,
        ['<A-j>'] = smart_splits.resize_down,
        ['<A-k>'] = smart_splits.resize_up,
        ['<A-l>'] = smart_splits.resize_right,
      }

      -- Key mappings for moving between splits
      -- <C-key> means Ctrl+key
      local move_mappings = {
        ['<C-h>'] = smart_splits.move_cursor_left,
        ['<C-j>'] = smart_splits.move_cursor_down,
        ['<C-k>'] = smart_splits.move_cursor_up,
        ['<C-l>'] = smart_splits.move_cursor_right,
      }

      -- Set key mappings
      -- vim.keymap.set is used to create key mappings in Neovim
      -- 'n' means these mappings work in normal mode
      for key, func in pairs(resize_mappings) do
        vim.keymap.set('n', key, func, { desc = 'Resize split: ' .. key })
      end

      for key, func in pairs(move_mappings) do
        vim.keymap.set('n', key, func, { desc = 'Move to split: ' .. key })
      end
    end,
  },

  -- File Navigation
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        columns = { 'icon' },
        keymaps = {
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<M-h>'] = 'actions.select_split',
        },
        view_options = {
          show_hidden = true,
        },
      }

      -- Open parent directory in current window
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

      -- Open parent directory in floating window
      vim.keymap.set('n', '<space>-', require('oil').toggle_float)
    end,
  },
  -- Note Taking
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- Use the latest release
    lazy = true, -- Don't load immediately
    ft = 'markdown', -- Load for markdown files
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
      'epwalsh/pomo.nvim',
    },
    keys = {
      -- Define keymaps specific to Obsidian
      {
        '<leader>of',
        function()
          return require('obsidian').util.gf_passthrough()
        end,
        expr = true,
        desc = 'Obsidian follow link',
      },
      {
        '<leader>od',
        function()
          return require('obsidian').util.toggle_checkbox()
        end,
        desc = 'Obsidian toggle checkbox',
      },
    },
    opts = {
      -- Obsidian.nvim configuration options
      workspaces = {
        {
          name = 'Slipbox',
          path = '~/obsidian/Slipbox',
        },
      },
      completion = {
        nvim_cmp = true, -- Use nvim-cmp for completion
        min_chars = 2,
      },
      new_notes_location = 'current_dir',
      prepend_note_id = true,
      daily_notes = {
        folder = '5. Dailies',
        date_format = '%Y-%m-%d',
        alias_format = '%B %-d, %Y',
        default_tags = { 'daily-notes' },
      },
      -- Function to generate frontmatter for new notes
      note_frontmatter_func = function(note)
        local out = { id = note.id, aliases = note.aliases, tags = note.tags, area = '', project = '' }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      templates = {
        subdir = 'Templates',
        date_format = '%Y-%m-%d-%a',
        time_format = '%H:%M',
        tags = '',
      },
    },
  },

  -- Time Management
  {
    'epwalsh/pomo.nvim',
    version = '*', -- Use the latest release
    lazy = true, -- Don't load immediately
    cmd = { 'TimerStart', 'TimerRepeat' }, -- Load when these commands are used
    dependencies = {
      'rcarriga/nvim-notify', -- Used for notifications
    },
    opts = {
      -- Pomo.nvim configuration options
      notifiers = {
        {
          name = 'Default',
          opts = {
            sticky = true,
            title_icon = '󱎫',
            text_icon = '󰄉',
          },
        },
        {
          name = 'System',
          opts = { sound = true }, -- Use system notifications with sound
        },
      },
    },
  },

  -- Git Integration
  {
    'kdheepak/lazygit.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    -- Remove the cmd field as we want to load it immediately for Telescope integration
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
    config = function()
      -- Load the lazygit extension for telescope
      require('telescope').load_extension 'lazygit'

      -- Set up an autocmd to track git repos for any opened buffer
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*',
        callback = function()
          require('lazygit.utils').project_root_dir()
        end,
      })

      -- Optional: Add a keymap to trigger LazyGit via Telescope
      vim.keymap.set('n', '<leader>tl', function()
        require('telescope').extensions.lazygit.lazygit()
      end, { desc = 'Telescope LazyGit' })
    end,
  },

  -- Cellular Automaton
  {
    'Eandrju/cellular-automaton.nvim',
  },
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'RchrdAriza/nvim-web-devicons' },
    config = function()
      local alpha = require 'alpha'
      local dashboard = require 'alpha.themes.dashboard'
      local builtin = require 'telescope.builtin'

      -- Setting the Timezone to PST
      os.setlocale 'en_US.UTF-8' -- Needed for %p to work correctly
      os.execute "TZ='America/Los_Angeles' export TZ" -- Set PST Time Zone

      -- Getting formatted time in 12-hour format (PST)
      local time = os.date '%I:%M %p'
      local date = os.date '%a %d %b'
      -- local v = vim.version()
      -- local version = ' v' .. v.major .. '.' .. v.minor .. '.' .. v.patch

      dashboard.section.header.val = {
        '⠀⠀⠀⠀⠀⠀ ⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣾⣿⣿⣿⣶⣶⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣶⣿⣿⣿⣿⣶⣶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣶⣶⣿⣿⣿⣷⣶⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⢿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⠿⠛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠛⠿⢿⣿⣿⣿⡇⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⡟⠁⠀⠀⠀⠈⢻⣿⣿⣿⠀⠀⠀⠀⠀⠀⢸⣿⣿⠏⣠⣤⡄⣠⣤⡌⢿⣿⣿⣿⣿⡿⢁⣤⣄⢀⣤⣄⠹⣿⣿⡇⠀⠀⠀⠀⠀⢺⣿⣿⡿⠋⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠛⠛⠛⠛⠛⠛⢛⣿⣮⣿⣿⣿⠀⠀⠀⠀⠀⠀⢈⣿⣿⡟⠀⠀⠀⠀⠀⠀⠸⣿⣿⠀⢿⣿⣿⣿⣿⡟⢸⣿⣿⣿⣿⡇⠸⣿⣿⣿⣿⡿⠀⣿⣿⠇⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⠋⠁⠠⢴⣾⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣧⡀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⢀⣼⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⢻⣿⣆⠀⠙⠿⠟⠋⢀⣾⣿⣿⣿⣿⣷⡀⠈⠻⡿⠋⠁⣰⣿⡟⠀⠀⠀⠀⠀⠀⠀⢿⣿⣷⣄⠀⠀⠀⢀⣰⣿⣿⣿⣿⣿⣿⣷⣶⣦⣤⣄⣼⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣶⣿⣿⣿⣿⠟⠉⠻⣿⣿⣿⣿⣶⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣶⣶⣶⣾⣿⣿⡿⠋⠙⢿⣿⣿⣷⣶⣶⣶⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣷⣾⣿⣿⣿⡟⢻⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣠⣷⡀⢹⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢁⣴⣧⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢀⣼⣆⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
        '⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠋⠛⠋⠛⠙⠛⠙⠛⠙⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠙⠛⠙⠛⠛⠋⠛⠋⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠙⠛⠛⠋⠛⠋⠛⠋⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀',
      }

      dashboard.section.buttons.val = {
        dashboard.button('f', '󰮗   Find file', ':lua require("telescope.builtin").find_files()<CR>'),
        dashboard.button('r', '   Recent', ':lua require("telescope.builtin").oldfiles()<CR>'),
        dashboard.button('R', '󱘞   Ripgrep', ':lua require("telescope.builtin").live_grep()<CR>'),
        dashboard.button('h', '   Search Help', ':lua require("telescope.builtin").help_tags()<CR>'),
        dashboard.button('q', '󰗼   Quit', ':qa<CR>'),
      }

      function centerText(text, width)
        local totalPadding = width - #text
        local leftPadding = math.floor(totalPadding / 2)
        local rightPadding = totalPadding - leftPadding
        return string.rep(' ', leftPadding) .. text .. string.rep(' ', rightPadding)
      end

      dashboard.section.footer.val = {
        centerText('ah shit, here we go again', 50),
        ' ',
        -- centerText("NvimOnMy_Way❤️", 50),
        -- " ",
        centerText(date, 50),
        centerText(time, 50),
        -- centerText(version, 50),
      }

      -- Send config to alpha
      alpha.setup(dashboard.opts)

      -- Disable folding on alpha buffer
      vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
    end,
  },

  -- Using lazy.nvim recipe
  {

    'kawre/leetcode.nvim',
    cmd = 'Leet',
    build = ':TSUpdate html',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'nvim-lua/plenary.nvim', -- required by telescope
      'MunifTanjim/nui.nvim',

      -- optional
      'nvim-treesitter/nvim-treesitter',
      'rcarriga/nvim-notify',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      -- configuration goes here
      lang = 'typescript',
    },
    -- Note that this should be within the curly braces of this table
    -- for it to be in the correct scope.
  },

  {
    'TobinPalmer/pastify.nvim',
    cmd = { 'Pastify', 'PastifyAfter' },
    event = { 'BufReadPost' }, -- Load after the buffer is read, I like to be able to paste right away
    keys = {
      { noremap = true, mode = 'x', '<leader>p', '<cmd>PastifyAfter<CR>' },
      { noremap = true, mode = 'n', '<leader>p', '<cmd>PastifyAfter<CR>' },
      { noremap = true, mode = 'n', '<leader>P', '<cmd>Pastify<CR>' },
    },
    config = function()
      require('pastify').setup {
        opts = {
          absolute_path = false, -- use absolute or relative path to the working directory
          apikey = '', -- Api key, required for online saving
          local_path = '/assets/imgs/', -- The path to put local files in, ex ~/Projects/<name>/assets/images/<imgname>.png
          save = 'local', -- Either 'local' or 'online' or 'local_file'
          filename = function()
            return vim.fn.expand '%:t:r' .. '_' .. os.date '%Y-%m-%d_%H-%M-%S'
          end,
          default_ft = 'markdown', -- Default filetype to use
        },
        ft = { -- Custom snippets for different filetypes, will replace $IMG$ with the image url
          html = '<img src="$IMG$" alt="">',
          markdown = '![]($IMG$)',
          tex = [[\includegraphics[width=\linewidth]{$IMG$}]],
          css = 'background-image: url("$IMG$");',
          js = 'const img = new Image(); img.src = "$IMG$";',
          xml = '<image src="$IMG$" />',
          php = '<?php echo "<img src="$IMG$" alt="">"; ?>',
          python = '# $IMG$',
          java = '// $IMG$',
          c = '// $IMG$',
          cpp = '// $IMG$',
          swift = '// $IMG$',
          kotlin = '// $IMG$',
          go = '// $IMG$',
          typescript = '// $IMG$',
          ruby = '# $IMG$',
          vhdl = '-- $IMG$',
          verilog = '// $IMG$',
          systemverilog = '// $IMG$',
          lua = '-- $IMG$',
        },
      }
    end,
  },

  -- AI Assistance
  {
    'frankroeder/parrot.nvim',
    tag = 'v0.3.7',
    event = 'VimEnter',
    dependencies = {
      'ibhagwan/fzf-lua',
      'nvim-lua/plenary.nvim',
      'rcarriga/nvim-notify',
    },
    config = function()
      local parrot = require 'parrot'
      parrot.setup {
        providers = {
          openai = { api_key = os.getenv 'OPENAI_API_KEY' },
          anthropic = { api_key = os.getenv 'ANTHROPIC_API_KEY' },
          gemini = { api_key = os.getenv 'GEMINI_API_KEY' },
          -- Add other providers as needed
        },
        cmd_prefix = 'PptM',
        hooks = {
          Complete = function(prt, params)
            local template = [[
          I have the following code from {{filename}}:

          ```{{filetype}}
          {{selection}}
          ```
          Please finish the code above carefully and logically.
          Respond ONLY with the snippet of code that should be inserted, without any additional formatting or explanations.
          ]]
            local agent = prt.get_command_agent()
            prt.Prompt(params, prt.ui.Target.append, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          CompleteFullContext = function(prt, params)
            local template = [[
          I have the following code from {{filename}} and other related files:

          ```{{filetype}}
          {{multifilecontent}}
          ```

          Please look at the following section specifically:
          ```{{filetype}}
          {{selection}}
          ```
          Please finish the code above carefully and logically.
          Respond ONLY with the snippet of code that should be inserted, without any additional formatting or explanations.
          ]]
            local agent = prt.get_command_agent()
            prt.Prompt(params, prt.ui.Target.append, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          Explain = function(prt, params)
            local template = [[
          Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
          Break down the code's functionality, purpose, and key components.
          The goal is to help the reader understand what the code does and how it works.

          ```{{filetype}}
          {{selection}}
          ```

          Use the markdown format with codeblocks and inline code.
          Explanation of the code above:
          ]]
            local agent = prt.get_chat_agent()
            prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          FixBugs = function(prt, params)
            local template = [[
          You are an expert in {{filetype}}.
          Fix bugs in the below code from {{filename}} carefully and logically:
          Your task is to analyze the provided {{filetype}} code snippet, identify
          any bugs or errors present, and provide a corrected version of the code
          that resolves these issues. Explain the problems you found in the
          original code and how your fixes address them. The corrected code should
          be functional, efficient, and adhere to best practices in
          {{filetype}} programming.

          ```{{filetype}}
          {{selection}}
          ```

          Fixed code:
          ]]
            local agent = prt.get_command_agent()
            prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          Optimize = function(prt, params)
            local template = [[
          You are an expert in {{filetype}}.
          Your task is to analyze the provided {{filetype}} code snippet and
          suggest improvements to optimize its performance. Identify areas
          where the code can be made more efficient, faster, or less
          resource-intensive. Provide specific suggestions for optimization,
          along with explanations of how these changes can enhance the code's
          performance. The optimized code should maintain the same functionality
          as the original code while demonstrating improved efficiency.

          ```{{filetype}}
          {{selection}}
          ```

          Optimized code:
          ]]
            local agent = prt.get_command_agent()
            prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          UnitTests = function(prt, params)
            local template = [[
          I have the following code from {{filename}}:

          ```{{filetype}}
          {{selection}}
          ```

          Please respond by writing table driven unit tests for the code above.
          ]]
            local agent = prt.get_command_agent()
            prt.Prompt(params, prt.ui.Target.enew, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          Debug = function(prt, params)
            local template = [[
          I want you to act as {{filetype}} expert.
          Review the following code, carefully examine it, and report potential
          bugs and edge cases alongside solutions to resolve them.
          Keep your explanation short and to the point:

          ```{{filetype}}
          {{selection}}
          ```
          ]]
            local agent = prt.get_chat_agent()
            prt.Prompt(params, prt.ui.Target.enew, nil, agent.model, template, agent.system_prompt, agent.provider)
          end,
          CommitMsg = function(prt, params)
            local futils = require 'parrot.file_utils'
            if futils.find_git_root() == '' then
              prt.logger.warning 'Not in a git repository'
              return
            else
              local template = [[
            I want you to act as a commit message generator. I will provide you
            with information about the task and the prefix for the task code, and
            I would like you to generate an appropriate commit message using the
            conventional commit format. Do not write any explanations or other
            words, just reply with the commit message.
            Start with a short headline as summary but then list the individual
            changes in more detail.

            Here are the changes that should be considered by this message:
            ]] .. vim.fn.system 'git diff --no-color --no-ext-diff --staged'
              local agent = prt.get_command_agent()
              prt.Prompt(params, prt.ui.Target.append, nil, agent.model, template, agent.system_prompt, agent.provider)
            end
          end,
        },
        -- Add other configuration options here if needed
      }

      -- Key mapping function
      local function map(mode, lhs, rhs, opts)
        local options = { noremap = true, silent = true, nowait = true }
        if opts then
          options = vim.tbl_extend('force', options, opts)
        end
        vim.keymap.set(mode, lhs, rhs, options)
      end

      -- Prefix for Parrot commands
      local prt_prefix = '<Leader>m'
      -- Chat and general commands
      map('n', prt_prefix .. 'c', '<cmd>PptMChatNew<cr>', { desc = 'New Chat' })
      map('n', prt_prefix .. 't', '<cmd>PptMChatToggle<cr>', { desc = 'Toggle Chat Window' })
      map('n', prt_prefix .. 'f', '<cmd>PptMChatFinder<cr>', { desc = 'Chat Finder' })
      map('n', prt_prefix .. 'r', '<cmd>PptMChatRespond<cr>', { desc = 'Chat Respond' })
      map('n', prt_prefix .. 'd', '<cmd>PptMChatDelete<cr>', { desc = 'Delete Chat' })
      map('n', prt_prefix .. 'p', '<cmd>PptMProvider<cr>', { desc = 'Switch Provider' })
      map('n', prt_prefix .. 'a', '<cmd>PptMAgent<cr>', { desc = 'Switch Agent' })
      map('n', prt_prefix .. 'i', '<cmd>PptMInfo<cr>', { desc = 'Plugin Info' })
      map('n', prt_prefix .. 'x', '<cmd>PptMContext<cr>', { desc = 'Edit Context' })
      map('n', prt_prefix .. 'q', '<cmd>PptMAsk<cr>', { desc = 'Ask Question' })
      map('n', prt_prefix .. 's', '<cmd>PptMStop<cr>', { desc = 'Stop Response' })

      -- Code operations (visual mode only)
      local code_ops = {
        ['l'] = { cmd = 'Complete', desc = 'Complete Code' },
        ['f'] = { cmd = 'CompleteFullContext', desc = 'Complete with Full Context' },
        ['e'] = { cmd = 'Explain', desc = 'Explain Code' },
        ['b'] = { cmd = 'FixBugs', desc = 'Fix Bugs' },
        ['o'] = { cmd = 'Optimize', desc = 'Optimize Code' },
        ['u'] = { cmd = 'UnitTests', desc = 'Generate Unit Tests' },
        ['g'] = { cmd = 'Debug', desc = 'Debug Code' },
      }

      for key, op in pairs(code_ops) do
        map('v', prt_prefix .. key, ":<C-u>'<,'>PptM" .. op.cmd .. '<cr>', { desc = op.desc })
      end

      -- Visual mode specific commands
      map('v', prt_prefix .. 'c', ":<C-u>'<,'>PptMChatNew<cr>", { desc = 'New Chat with Selection' })
      map('v', prt_prefix .. 't', ":<C-u>'<,'>PptMChatToggle<cr>", { desc = 'Chat Toggle with Selection' })
      map('v', prt_prefix .. 'p', ":<C-u>'<,'>PptMChatPaste<cr>", { desc = 'Paste to Chat' })

      -- Special commands
      map('n', prt_prefix .. 'm', '<cmd>PptMCommitMsg<cr>', { desc = 'Generate Commit Message' })
    end,
  },

  -- Noice
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
}
