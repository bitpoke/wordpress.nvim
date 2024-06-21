# WordPress.nvim

Neovim plugin for WordPress and WooCommerce development.

## Features

-   Configures tabs and indentation according to [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards/)
-   Configuration for [Intelephense](https://intelephense.com/) LSP server
-   Configuration for `phpcs` and `phpcbf` for [none-ls](https://github.com/nvimtools/none-ls.nvim)

## Requirements

1.  [Intelephense](https://intelephense.com/)
2.  [PHP_CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer) with [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards)

    **NOTE**: If you are using `Mason`, you need to disable it for `phpcs` and install `phpcs` globally with support for WordPress Coding Standards.

    ```lua
    require("mason-null-ls").setup {
        automatic_installation = {
            exclude = { "phpcs", "phpcbf" }
        }
    }
    ```

    ```sh
    composer global require "wp-coding-standards/wpcs"
    ```

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "bitpoke/wordpress.nvim",
}
```

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "bitpoke/wordpress.nvim",
}
```

## Configuration

Where you configure your LSP and none-ls servers, add the following lines

```lua
local wp = require('wordpress')
local lspconfig = require('lspconfig')
local null_ls = require('null-ls')

-- setup intelephense for PHP, WordPress and WooCommerce development
lspconfig.intelephense.setup(wp.intelephense)

null_ls.setup({
    ...,
    sources = {
        ...,
        null_ls.builtins.diagnostics.phpcs.with(wp.null_ls_phpcs),
        null_ls.builtins.formatting.phpcbf.with(wp.null_ls_phpcs),
    },
})
```

## Known Issues

#### Calling `vim.lsp.buf.format()` formats using both `phpcbf` and `intelephense` tools.

`vim.lsp.buf.format()` uses all available formatters for the current file type. To avoid this, you can use the following command to format the current buffer:

```lua
vim.lsp.buf.format({ filter = require('wordpress').null_ls_formatter })
```
