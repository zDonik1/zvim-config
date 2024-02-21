local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			},
		},
		config = function()
			require("telescope").setup()
			require("telescope").load_extension("fzf")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>kf", builtin.find_files, {})
			vim.keymap.set("n", "<leader>ko", builtin.oldfiles, {})
			vim.keymap.set("n", "<leader>kg", builtin.git_files, {})
			vim.keymap.set("n", "<leader>kw", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>kb", builtin.buffers, {})
		end,
	},

	{
		"catppuccin/nvim",
		lazy = false,
		config = function()
			require("catppuccin").setup({
				-- transparent_background = true,
				show_end_of_buffer = true,
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"lewis6991/gitsigns.nvim",
		},
		build = function()
			vim.cmd("TSUpdate")
		end,
		opts = {
			auto_install = true,
			ensure_installed = { "javascript", "typescript", "c", "cpp", "lua", "vim", "vimdoc", "query" },
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
						["as"] = "@scope.outer",
						["ar"] = "@parameter.outer",
						["ir"] = "@parameter.inner",
					},
					selection_modes = {
						["@function.outer"] = "V",
						["@class.outer"] = "V",
					},
					include_surrounding_whitespace = true,
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
						["]o"] = "@loop.*",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
			vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f)
			vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F)
			vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t)
			vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T)

			local gs = require("gitsigns")
			local next_hunk_repeat, prev_hunk_repeat =
				ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
			vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
			vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-context",
		opts = {
			separator = "─",
		},
	},

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup()

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():append()
			end)
			vim.keymap.set("n", "<leader>h", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end)

			vim.keymap.set("n", "<C-r>", function()
				harpoon:list():select(1)
			end)
			vim.keymap.set("n", "<C-m>", function()
				harpoon:list():select(2)
			end)
			vim.keymap.set("n", "<C-f>", function()
				harpoon:list():select(3)
			end)
			vim.keymap.set("n", "<C-p>", function()
				harpoon:list():select(4)
			end)

			-- Toggle previous & next buffers stored within Harpoon list
			vim.keymap.set("n", "<C-u>", function()
				harpoon:list():prev()
			end)
			vim.keymap.set("n", "<C-i>", function()
				harpoon:list():next()
			end)
		end,
	},

	{
		"max397574/better-escape.nvim",
		opts = {
			mapping = { "jk" },
			timeout = vim.o.timeoutlen,
			keys = "<esc>",
		},
	},

	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup({
				toggler = {
					line = "<leader>cc",
					block = "<leader>bc",
				},
				opleader = {
					line = "<leader>c",
					block = "<leader>b",
				},
				extra = {
					above = "<leader>cO",
					below = "<leader>co",
					eol = "<leader>cA", -- add comment at the end of line
				},
			})
		end,
	},

	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
	},

	{
		"rbong/vim-flog",
		lazy = true,
		cmd = { "Flog", "Flogsplit", "Floggit" },
		dependencies = { "tpope/vim-fugitive" },
	},

	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		init = function()
			require("lsp-zero").on_attach(function(_, bufnr)
				local opts = { buffer = bufnr, remap = false }

				vim.keymap.set("n", "gd", function()
					vim.lsp.buf.definition()
				end, opts)
				vim.keymap.set("n", "K", function()
					vim.lsp.buf.hover()
				end, opts)
				vim.keymap.set("n", "<leader>vks", function()
					vim.lsp.buf.workspace_symbol()
				end, opts)
				vim.keymap.set("n", "<leader>vd", function()
					vim.diagnostic.open_float()
				end, opts)
				vim.keymap.set("n", "]d", function()
					vim.diagnostic.goto_next()
				end, opts)
				vim.keymap.set("n", "[d", function()
					vim.diagnostic.goto_prev()
				end, opts)
				vim.keymap.set({ "n", "v" }, "<leader>vca", function()
					vim.lsp.buf.code_action()
				end, opts)
				vim.keymap.set("n", "<leader>vrr", function()
					vim.lsp.buf.references()
				end, opts)
				vim.keymap.set("n", "<leader>vrn", function()
					vim.lsp.buf.rename()
				end, opts)
				vim.keymap.set("i", "<C-h>", function()
					vim.lsp.buf.signature_help()
				end, opts)
			end)
		end,
	},

	{ "neovim/nvim-lspconfig" },

	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = function()
			local cmp = require("cmp")
			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			cmp.setup({
				sources = {
					{ name = "path" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
					{ name = "luasnip", keyword_length = 2 },
					{ name = "buffer", keyword_length = 3 },
				},
				formatting = require("lsp-zero").cmp_format(),
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<Tab>"] = cmp.mapping(function(fallback)
						-- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
						if cmp.visible() then
							cmp.confirm({ select = true })
						else
							fallback()
						end
					end, { "i", "s", "c" }),
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	{ "L3MON4D3/LuaSnip" },

	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_lspconfig()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					-- "tsserver",
					-- "rust_analyzer",
					-- "clangd",
					-- "cmake",
					-- "denols",
					-- "gopls",
					-- "golangci_lint_ls",
					-- "pylsp",
					--                "csharp_ls",
				},
				handlers = {
					lsp_zero.default_setup,
					lua_ls = function()
						local lua_opts = lsp_zero.nvim_lua_ls()
						require("lspconfig").lua_ls.setup(lua_opts)
					end,
				},
			})
		end,
	},

	{
		"mhartington/formatter.nvim",
		config = function()
			require("formatter").setup({
				filetype = {
					lua = { require("formatter.filetypes.lua").stylua },
					cpp = { require("formatter.filetypes.cpp").clangformat },
					rust = { require("formatter.filetypes.rust").rustfmt },
					cs = { require("formatter.filetypes.cs").csharpier },
				},
			})
		end,
	},

	{
		"epwalsh/obsidian.nvim",
		version = "*", -- recommended, use latest release instead of latest commit
		lazy = true,
		ft = "markdown",
		cmd = "ObsidianQuickSwitch",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-telescope/telescope.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			disable_frontmatter = true,
			workspaces = {
				{
					name = "personal",
					path = "~/iCloudDrive/iCloud~md~obsidian/SecondBrain",
				},
			},
			daily_notes = {
				folder = "periodic_notes",
				template = "templates/daily_template.md",
			},
			templates = {
				subdir = "templates",
			},
			note_id_func = function(title)
				return title
			end,
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufReadPre",
		opts = {
			scope = { enabled = false },
		},
		config = function(_, opts)
			require("ibl").setup(opts)
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {
			current_line_blame = true,
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)
		end,
	},

	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup()
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
}

require("lazy").setup(plugins)
