# dotfiles

Config for Arch Linux / Awesome WM / Neovim.

## Structure

```
dotfiles/
├── .config/          # Symlinked to ~/.config — all app configs live here
│   ├── nvim/         # Neovim config (kickstart-based)
│   ├── lazygit/      # LazyGit config (uses nvr for editor integration)
│   ├── kitty/        # Kitty terminal
│   ├── awesome/      # Awesome WM
│   └── ...
├── zsh/              # Zsh config — loaded via ZDOTDIR in ~/.zshenv
│   └── .zshrc
├── bin/              # Custom scripts, symlinked to ~/.local/bin
│   ├── nvr           # Python wrapper: fixes nvr on Python 3.14 (uses 3.13 libs)
│   └── nvim-lazygit-edit  # Opens a file from LazyGit in the parent nvim instance
├── .zshenv           # Symlinked to ~/.zshenv — sets ZDOTDIR
├── .xinitrc          # Symlinked to ~/.xinitrc — X session startup
└── setup.sh          # Symlink setup script (run once on a new machine)
```

## Fresh machine setup

### 1. Clone

```sh
git clone <repo-url> ~/dotfiles
```

### 2. Run setup script

```sh
bash ~/dotfiles/setup.sh
```

This creates all symlinks. It is safe to re-run.

### 3. Install packages (Arch)

```sh
# Core
sudo pacman -S neovim lazygit kitty awesome

# Neovim dependencies
sudo pacman -S ripgrep fd nodejs npm python-pynvim neovim-remote

# nvr Python 3.14 workaround: the AUR package compiles against Python 3.13.
# The bin/nvr wrapper handles this automatically, but the package must still
# be installed for its library files:
yay -S neovim-remote

# Shell
sudo pacman -S zsh
chsh -s /bin/zsh
```

### 4. Open Neovim

```sh
nvim
```

Lazy.nvim installs all plugins automatically on first launch.

## Notes

### nvr (neovim-remote)

The AUR `neovim-remote` package compiles against Python 3.13. When Arch upgrades
Python to a newer version, the system `/usr/bin/nvr` breaks. The `bin/nvr` wrapper
in this repo fixes this by pointing directly at the 3.13 site-packages:

```python
#!/usr/bin/python3
import sys
sys.path.insert(0, '/usr/lib/python3.13/site-packages')
from nvr.nvr import main
sys.exit(main())
```

If this breaks after a Python upgrade, update the path in `bin/nvr` to match
the installed Python version that `neovim-remote` was compiled against
(`pacman -Ql neovim-remote | grep site-packages`).

### LazyGit → Neovim integration

LazyGit runs as a floating window inside Neovim (via `kdheepak/lazygit.nvim`).
Pressing `e` on a file uses `bin/nvim-lazygit-edit`, which:

1. Writes the filename to a temp file
2. Sends `<C-\><C-n>:lua LazygitEditFile(...)<CR>` to the parent nvim via nvr
3. The `LazygitEditFile` Lua function (defined in `nvim/lua/custom/plugins/lazygit.lua`)
   closes the LazyGit float and opens the file in the underlying window
