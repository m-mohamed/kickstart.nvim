-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  -- Smart Splits
  {
    'mrjones2014/smart-splits.nvim',
    opts = {},
    config = function()
      local smart_splits = require 'smart-splits'

      -- Key mappings for resizing splits
      local resize_mappings = {
        ['<A-h>'] = smart_splits.resize_left,
        ['<A-j>'] = smart_splits.resize_down,
        ['<A-k>'] = smart_splits.resize_up,
        ['<A-l>'] = smart_splits.resize_right,
      }

      -- Key mappings for moving between splits
      local move_mappings = {
        ['<C-h>'] = smart_splits.move_cursor_left,
        ['<C-j>'] = smart_splits.move_cursor_down,
        ['<C-k>'] = smart_splits.move_cursor_up,
        ['<C-l>'] = smart_splits.move_cursor_right,
      }

      -- Set key mappings
      for key, func in pairs(resize_mappings) do
        vim.keymap.set('n', key, func)
      end

      for key, func in pairs(move_mappings) do
        vim.keymap.set('n', key, func)
      end
    end,
  },

  -- Obsidian configuration
  {
    'epwalsh/obsidian.nvim',
    opts = {
      version = '*', -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = 'markdown',
      dependencies = {
        'nvim-lua/plenary.nvim', -- Required
        'hrsh7th/nvim-cmp',
        'nvim-telescope/telescope.nvim',
        'nvim-treesitter',
        'epwalsh/pomo.nvim',
      },
      workspaces = {
        {
          name = 'Slipbox',
          path = '~/obsidian/Slipbox',
        },
      },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      new_notes_location = 'current_dir',
      prepend_note_id = true,
      daily_notes = {
        folder = '5. Dailies',
        date_format = '%Y-%m-%d',
        alias_format = '%B %-d, %Y',
        default_tags = { 'daily-notes' },
        template = nil, -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      },
      mappings = {
        ['<leader>of'] = {
          action = function()
            return require('obsidian').util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ['<leader>od'] = {
          action = function()
            return require('obsidian').util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
      },
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
    config = function(_, opts)
      require('obsidian').setup(opts)
    end,
  },

  -- Pomo configuration
  {
    'epwalsh/pomo.nvim',
    opts = {
      version = '*', -- Recommended, use latest release instead of latest commit
      lazy = true,
      cmd = { 'TimerStart', 'TimerRepeat' },
      dependencies = {
        'rcarriga/nvim-notify', -- Optional, but highly recommended if you want to use the "Default" timer
      },
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
          opts = { sound = true }, -- Available on MacOS and Windows natively and on Linux via the libnotify-bin package
        },
      },
    },
    config = function(_, opts)
      require('pomo').setup(opts)
    end,
  },

  -- Parrot
  {
    'frankroeder/parrot.nvim',
    tag = 'v0.3.7',
    dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim', 'rcarriga/nvim-notify' },
    config = function()
      require('parrot').setup {
        -- Providers must be explicitly added to make them available.
        providers = {
          openai = {
            api_key = os.getenv 'OPENAI_API_KEY',
          },
          anthropic = {
            api_key = os.getenv 'ANTHROPIC_API_KEY',
          },
          gemini = {
            api_key = os.getenv 'GEMINI_API_KEY',
          },
        },
      }
    end,
  },
  -- Oil
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        columns = { 'icon' },
        keymaps = {
          ['<C-h>'] = false,
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

  -- LazyGit
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
    config = function()
      require('telescope').load_extension 'lazygit'
    end,
  },
}
