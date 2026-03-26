{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.sysopts.editor = lib.mkOption {
    type = lib.types.str;
    default = "${pkgs.neovim}/bin/nvim";
    readOnly = true;
    description = "Default text editor";
  };

  config = {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      globals.mapleader = " ";

      extraConfigLua = ''
        vim.g.maplocalleader = " "

        vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

        vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight" })
      '';

      opts = {
        number = true;
        relativenumber = false;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        clipboard = "unnamedplus";
        termguicolors = true;
        cursorline = true;
        scrolloff = 8;
        wrap = false;
        updatetime = 300;
        timeoutlen = 500;

        ignorecase = true;
        smartcase = true;
        incsearch = true;
        hlsearch = false;
      };

      keymaps = [
        {
          mode = "i";
          key = "<C-h>";
          action = "<Left>";
        }
        {
          mode = "i";
          key = "<C-j>";
          action = "<Down>";
        }
        {
          mode = "i";
          key = "<C-k>";
          action = "<Up>";
        }
        {
          mode = "i";
          key = "<C-l>";
          action = "<Right>";
        }

        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Move to left window";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Move to bottom window";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Move to top window";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Move to right window";
        }

        {
          mode = "n";
          key = "<leader>bn";
          action = "<cmd>bnext<CR>";
          options.desc = "Next buffer";
        }
        {
          mode = "n";
          key = "<leader>bp";
          action = "<cmd>bprev<CR>";
          options.desc = "Previous buffer";
        }
        {
          mode = "n";
          key = "<leader>bd";
          action = "<cmd>bdelete<CR>";
          options.desc = "Delete buffer";
        }

        {
          mode = "n";
          key = "<A-j>";
          action = "<cmd>m .+1<CR>== ";
        }
        {
          mode = "n";
          key = "<A-k>";
          action = "<cmd>m .-2<CR>== ";
        }
        {
          mode = "v";
          key = "<A-j>";
          action = ":m '>+1<CR>gv=gv";
        }
        {
          mode = "v";
          key = "<A-k>";
          action = ":m '<-2<CR>gv=gv";
        }

        {
          mode = "v";
          key = "<";
          action = "<gv";
        }
        {
          mode = "v";
          key = ">";
          action = ">gv";
        }
      ];

      plugins = {
        treesitter = {
          enable = true;
          settings = {
            highlight = {
              enable = true;
              additional_vim_regex_highlighting = false;
            };
            indent = {
              enable = true;
            };
            ensure_installed = [
              "nix"
              "rust"
              "c"
              "cpp"
              "lua"
              "vim"
              "vimdoc"
              "query"
            ];
          };
        };

        lsp = {
          enable = true;
          servers = {
            clangd.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            nil_ls.enable = true;
            nixd.enable = true;
          };

          onAttach = '' 
            if client.supports_method("textDocument/formatting") then
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ bufnr = bufnr })
                end,
              })
            end
          '';

          keymaps.lspBuf = {
            "gd" = "definition";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "<leader>f" = "format";
          };
        };

        none-ls = {
          enable = true;
          sources.formatting = {
            nixpkgs_fmt.enable = true;
            clang_format.enable = true;
          };
        };

        cmp = {
          enable = true;
          settings = {
            autoEnableSources = true;
            sources = [
              { name = "nvim_lsp"; }
              { name = "path"; }
              {
                name = "buffer";
                keyword_length = 3;
              }
            ];
            mapping = {
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.abort()";
            };
            snippet.expand = "luasnip";
          };
        };

        luasnip.enable = true;

        comment.enable = true;
        todo-comments.enable = true;
        indent-blankline.enable = true;

        telescope = {
          enable = true;
          extensions = {
            fzf-native.enable = true;
          };
          keymaps = {
            "<leader>ff" = "find_files";
            "<leader>fh" = "help_tags";
            "<leader>fg" = "live_grep";
            "<leader>fr" = "oldfiles"; # for real
            "<leader>fb" = "buffers";
          };
          settings = {
            defaults = {
              mappings = {
                i = {
                  "<C-u>" = false;
                  "<C-d>" = false;
                };
              };
            };
          };
        };

        lualine = {
          enable = true;
          settings = {
            sections = {
              lualine_a = [ "mode" ];
              lualine_b = [
                "branch"
                "diff"
                "diagnostics"
              ];
              lualine_c = [ "filename" ];
              lualine_x = [
                "encoding"
                "fileformat"
                "filetype"
              ];
              lualine_y = [ "progress" ];
              lualine_z = [ "location" ];
            };
          };
        };
        web-devicons.enable = true;
      };
      stylix.override = {
        base01 = "e1d6a9"; # Only way I found to make the panel with the line number to blend wit hthe bg
      };
    };
  };
}
