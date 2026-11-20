# LazyVim transition profile

This profile is a first migration pass for [the existing Neovim config](../nvim).
It uses LazyVim's regular `lua/config/` and `lua/plugins/` layout. Your current
`nvim/` and its dotfile install targets can still be used as before.

## Try it

From the dotfile repository root:

```sh
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$config_home"
ln -sT "$PWD/nvim-lazyvim" "$config_home/nvim-lazyvim"
NVIM_APPNAME=nvim-lazyvim nvim
```

The symlink command is for GNU/Linux and fails if the destination already exists.
Starting plain `nvim` continues to use your regular profile. The preview has its
own XDG data, state, and cache directories. First launch needs network access
for plugins and Mason packages. LazyVim requires Neovim 0.11.2 or later with
LuaJIT. See the [full requirements](https://www.lazyvim.org/) for parser tools
and optional dependencies.

Run `:Lazy` and `:Mason` to check installation. Try the profile in a real
C/C++ project and check `:LspInfo` for clangd's root and attachment. The profile
disables format on save by default. `<leader>cf` formats on demand.

## Customize LazyVim

| To change | Edit |
| --- | --- |
| Neovim options, clipboard, or format-on-save default | [lua/config/options.lua](lua/config/options.lua) |
| Custom shortcuts, plugin keymaps, or user commands | [lua/config/keymaps.lua](lua/config/keymaps.lua) |
| Actions on events such as entering Insert mode or changing the theme | [lua/config/autocmds.lua](lua/config/autocmds.lua) |
| Plugin settings and dependencies | The owning file under [lua/plugins/](lua/plugins) |
| Built-in extras such as Telescope, Mini Files, or DAP | Explicit imports in [lua/config/lazy.lua](lua/config/lazy.lua), or `:LazyExtras` for additional extras |

Plugin specs live directly in `lua/plugins/`. The former `editor.lua` mixed
appearance, pickers, and Git, while `editing.lua` mixed text operations,
appearance, and formatting. Use these entry points instead:

| Area | Plugin files |
| --- | --- |
| Theme, dashboard, and statusline | `appearance.lua`. Use `mini.lua` for indentation guides, `bufferline.lua` for buffer tabs, `dropbar.lua` for breadcrumbs, and `noice.lua` for messages and the command line. |
| Search and navigation | `telescope.lua` for pickers and grep, `mini.lua` for Mini Files and Mini Pick, `project.lua` for directory detection, and `flash.lua` for jumps. |
| Text editing and formatting | `mini.lua` for alignment, surrounds, comments, line splitting/joining, and trailing spaces. Use `formatting.lua` for Conform and `guess-indent.lua` for indentation detection. |
| Completion, language servers, and syntax | `completion.lua`, `lsp.lua`, and `treesitter.lua`. Use `nvim-ufo.lua` for folding. |
| Git, terminals, and other tools | Files named after their plugin, such as `gitsigns.lua`, `diffview.lua`, `neogit.lua`, `tig-explorer.lua`, and `codex.lua`. |

To tune a plugin, edit its `opts`. For example, change
`opts.windows.width_preview` in `mini.lua` to resize the Mini Files preview.
The profile defines its custom mappings in `lua/config/keymaps.lua`, including
Telescope picker keys and Vuffers sidebar keys. Plugin specs read their
mappings from this file during startup. The `LazyVimKeymaps` event applies
general mappings after the defaults. LazyVim and the plugins supply those
defaults.

Which-key discovers mappings from their descriptions and uses group labels
defined in `lua/config/keymaps.lua`. Press Space and pause to browse leader shortcuts,
or press Space twice for the Menu group. Use `:WhichKey` or LazyVim's
`<leader>?` buffer-local view for other mappings. General mappings are registered
with `which-key.add()`. Lazy-loaded shortcuts use plugin `keys`, and
picker-local bindings use the picker's own mapping table.
For a new plugin, add a Lua file that returns a spec with its repository name.
LazyVim imports those specs through lazy.nvim and merges them with upstream
specs. A local spec with `enabled = false` disables a plugin. Restart Neovim
after changes and use `:Lazy` to inspect the resolved plugins. For keymaps,
`:verbose nmap {lhs}` shows the current Normal-mode binding and its source.
See [LazyVim general settings](https://www.lazyvim.org/configuration/general)
and [plugin overrides](https://www.lazyvim.org/configuration/plugins).

The original startup list in [nvim/core/lazy.lua](../nvim/core/lazy.lua) is the
baseline for enabled legacy workflows. Archived alternatives, commented-out
specs, and disabled plugins stay in the original profile unless explicitly
selected. LazyVim also supplies its own default plugins and dependencies.

## What carried over

| Existing workflow | Transition profile |
| --- | --- |
| Material Darker and editor preferences | Material Darker, Space leader, wrapping, mouse disabled, 600 ms key timeout, and selected window and display options. |
| Telescope | LazyVim's `<leader>ff` finds files from the project root and `<leader>fF` finds files in the CWD. `<leader>fr` opens recent files and `<leader>[` shows buffers. `//` and `//w` use Telescope with ripgrep through egrepify. `<C-p>` toggles the picker preview. |
| File explorer and Git | `<leader><space>f` opens Mini Files. `:DiffviewOpen` and `:DiffviewFileHistory` are available on demand. LazyVim provides Gitsigns. |
| Working directory | `<leader>sP` changes the current window's directory to the file's parent. LazyVim's root detection considers LSP roots, `.root`, and `.git`. Individual LSP servers use their own upstream root rules. |
| LSP | Mason manages the same eight server selections. Lua diagnostics overrides are carried over and inline diagnostic virtual text is disabled. Use LazyVim's LSP maps, including `gd`, `gr`, `gI`, and `<leader>cr`. |
| UI and completion | Snacks provides the dashboard. LazyVim manages Lualine, Bufferline, Which-key, Noice, Flash, and Trouble. Blink uses Neovim's native snippets with `friendly-snippets` and includes Codeium suggestions in the completion menu. |
| Clipboard | When `copyq` is available, copying to `+` or `*` adds the text to CopyQ history and sets the system clipboard. Ordinary yanks use Neovim's unnamed register. Without CopyQ, LazyVim uses `unnamedplus` locally and leaves the clipboard option empty over SSH for OSC 52. See [LazyVim's options](https://www.lazyvim.org/configuration/general#options). |

## Migration notes

- Telescope has egrepify, cder, and undo. Use Neovim's `:scriptnames` for the
  sourced-script list because the legacy picker repository could not be cloned.
  The grep shortcuts
  `//`, `//f`, `//w` and `//c` cover project/window and current-file
  searches. Legacy project detection can change the window's local directory.
- The profile uses the legacy per-window Lualine layout and
  Bufferline appearance. Insert mode restores the legacy color column,
  whitespace display, and scroll margins for editable buffers.
- Aerial, Dropbar, Vuffers, Edgy, UFO, Yanky, Neogit, Tig, Codex and DAP
  are included. Tig and Codex require their respective CLI executables.
  DAP adapters still need project-specific configuration.
- Manual C/C++ formatting is routed through Conform and needs
  `clang-format`. GuessIndent complements built-in EditorConfig.
- LazyVim keeps overlapping keys and prefixes. See the comments in
  `lua/config/keymaps.lua`. Mini Comment uses `<leader>c/`, and Mini Surround
  uses `<leader>c[` and `<leader>c]` to find surrounds. The old
  `:Telescope luasnip` picker depends on LuaSnip. Snippets are available in
  Blink's completion menu. If needed, authorize Codeium via `:Codeium Auth`.
- The legacy binary/BOM defaults, shared ShaDa, and shared LSP log remain
  specific to the original profile. These affect on-disk bytes or cross-profile
  state. Treesitter and built-in filetype handling cover the syntax setup
  without loading the legacy Polyglot bundle.

The existing `nvim/init.lua` sources `config.vim`, which the Makefile generates
and the repository does not track. The installed file only sets the theme
variable. The transition profile selects the theme in its plugin spec and can
bootstrap directly from the files in this directory.

See [LazyVim configuration](https://www.lazyvim.org/configuration/general) and
[plugin overrides](https://www.lazyvim.org/configuration/plugins).

## Legacy plugin compatibility audit

The startup list in [core/lazy.lua](../nvim/core/lazy.lua) determines which
legacy specs were active. Some files in [nvim/config](../nvim/config) are
archived alternatives or snippets. The transition's resolved plugin list was
checked in an isolated Neovim 0.11.7 session. The rows below describe migration
paths. The notes below identify behavior changes and integration checks that still need a real project.

### Shared plugins and behavior

| Legacy config | What can carry over |
| --- | --- |
| `theme.lua` | Material Darker is active. Its plugin-specific highlight list can be translated to the plugins in use. Sonokai, Gruvbox Material, and OneDark can be installed as optional themes. Apply any custom highlights from `profile.lua` on `ColorScheme`. |
| `lualine.lua`, `lsp-status.lua` | The port restores the per-window layout, macro indicator, tab labels, relative filename and search count alongside LazyVim's LSP and Trouble integrations. |
| `bufferline.lua` | The profile restores appearance, numbers, sorting, and offsets and uses LazyVim's buffer deletion commands. The old mouse and close actions ran `bdelete!`, which can discard unsaved changes. |
| `flash.lua`, `gitsigns.lua`, `trouble.lua`, `noice.lua` | The lowercase Flash labels, blame format, Trouble focus/reference settings, and Noice presets are merged through `opts`. The Noice `cmp.entry.get_documentation` override is specific to the old completion engine. Keep LazyVim's mappings and comment the former mappings when porting. |
| `mini.lua` | All eleven active modules are configured together in `lua/plugins/mini.lua`. Mini Files handles directory buffers and has an 80-column preview. Mini Bufremove backs Tig's `:Bclose`. Mini Comment and Mini Surround use the shortcuts documented in `lua/config/keymaps.lua`. |
| `auto-pairs.lua`, `vim-startify.lua`, `nvim-lastplace.lua`, `hlsearch.lua` | LazyVim already provides Mini Pairs, the chosen Snacks dashboard, last-location restoration, and a clear-search mapping. The legacy AutoPairs back-insert shortcut and automatic search-highlight clearing are distinct behaviors. |
| `editorconfig.lua`, `guess-indent.lua`, `vim-clang-format.lua` | The old EditorConfig plugin spec was disabled and the profile called built-in EditorConfig. GuessIndent can run alongside built-in EditorConfig with a deliberate order. LazyVim uses Conform for formatting. Manual C/C++ formatting uses Conform with clang-format. |
| `nvim-cmp.lua` | Blink, native snippets, `friendly-snippets`, and Codeium are already configured per your decision. The old mappings for Tab, Shift-Tab, Ctrl-P and Enter belong to the completion configuration. Tabnine was installed as a dependency but commented out as a source. |
| `vim-tmux-clipboard.lua`, `yanky.lua` | CopyQ is active for explicit clipboard registers when installed. Yanky adds a ring and a Telescope history picker with custom copy/paste actions. Those can be ported with its extra. Treat tmux clipboard integration as a separate choice because it may change where copied text goes. |

### Plugins that need adaptation or a choice

| Legacy config | Compatibility finding |
| --- | --- |
| `nvim-treesitter.lua`, `vim-polyglot.lua` | The legacy v0.10.0 pin, `nvim-treesitter.configs` setup, `:TSUpdateSync`, and the highlight toggle in `profile.lua` target the old API. The transition extends LazyVim's parser list to cover the legacy languages. On Neovim 0.11.7, LazyVim selects a compatible Treesitter commit. An unconditional upgrade to the latest upstream revision could break this compatibility. The old incremental selection keys still need a separate port. Polyglot overlaps with syntax/filetype support. |
| `telescope.lua` | The profile merges layout changes and adds egrepify, cder, and undo. Neovim's `:scriptnames` supplies the sourced-script list. Review the custom selection actions and path escaping. The old LuaSnip picker needs its engine. `project.nvim` automatically changes window CWD, while LazyVim's project root is used by root-aware pickers. The extensions can be ported independently of that choice. |
| `core/lspconfig.lua`, `core/which-key.lua` | The eight server selections and Lua diagnostics preferences are already ported. Translate any desired root policy and attachment behavior into server options or LSP autocmds. The old loader also forces INFO logging and links to a shared log. The old Which-key config registers mappings and autocmds together. Move free keys by mode and compare prefixes before adding them. |
| `symbol-list.lua`, `dropbar.lua` | The active outline was Aerial. Its symbol filters, layout, and Neovim 0.11 version pin carry over. The backend and parser combinations still need a project-level check. Dropbar supplies a separate breadcrumb winbar and can coexist with the outline. |
| `nvim-ufo.lua` | UFO changes the folding provider and overrides `zR`, `zM`, `zr`, and `zm`, plus adds `zp` to peek. The port uses UFO and selects its provider using the current LSP and Treesitter APIs. LazyVim's Treesitter fold expression is disabled. |
| `edgy.lua`, `stickybuf.lua`, `scope.lua`, `close-buffers.lua`, `vuffers.lua` | These alter window placement, window pinning, tab-local buffer lists, buffer deletion, or buffer navigation. Edgy has a LazyVim extra. Vuffers can add a sidebar alongside Bufferline if you want both. Stickybuf's callbacks read the current buffer and contain a Startify exception, so revise and test them with the dashboard and sidebars. Test Scope alongside buffer pickers and session restore. |
| `tig-explorer.lua`, `codex.lua`, `nvim-dap.lua`, `neogit.lua`, `diffview.lua` | Diffview is already ported. Tig needs the external `tig` command and its `:Bclose` adapter uses Mini Bufremove. Codex needs its CLI and mode-specific mappings. DAP can use the LazyVim extra, with adapters configured separately. Neogit is a separate Git UI and can coexist with Diffview and Gitsigns. |

### Standalone and inactive specs

- **Candidates for a direct spec port:** `alternate-toggler.lua`,
  `bufresize.lua`, `maximizer.lua`, `jumppack.lua`, `nvim-bqf.lua`,
  `vim-doge.lua`, and `vim-startuptime.lua`. Their setup is relatively
  independent. Verify their triggers and mappings in LazyVim. DoGe has a
  separate build step.
- **Inactive alternatives and snippets:** `ChatGPT.lua`, `ccls.lua`,
  `coc.lua`, `coc-clangd.lua`, `codecompanion.lua`, `copilot.lua`,
  `edit-list.lua`, `fold-preview.lua`, `fzf.lua`, `hop.lua`,
  `indent-o-matic.lua`, `minuet.lua`, `nvim-ide.lua`, `nvim-origami.lua`,
  `nvim-scrollbar.lua`, `nvim-tree.lua`, `sidebar.lua`, `tabnine-nvim.lua`,
  `toggleterm.lua`, `vim-better-whitespace.lua`, `vim-commentary.lua`,
  `vim-easymotion.lua`, `vim-matchup.lua`, and `whatthejump.lua`.
  Review separately if you want them available as opt-ins. Files such as
  `nvim-tree.lua` and `coc-clangd.lua` include setup code and need adaptation
  before importing them as lazy.nvim specs.

Most workflows can be carried over, but full parity requires rebuilding the
integrations around the current plugin APIs and deciding which competing
features to enable. The transition uses the legacy window-CWD workflow, GuessIndent, and UFO. Test those alongside your project-specific LSP and session workflows.

See [LazyVim Treesitter](https://www.lazyvim.org/plugins/treesitter),
[Aerial](https://www.lazyvim.org/extras/editor/aerial), and
[plugin spec merge rules](https://www.lazyvim.org/configuration/plugins).
