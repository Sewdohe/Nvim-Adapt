# Nvim Adapt

![](https://github.com/Sewdohe/Nvim-Adapt/blob/main/nvim-adapt-1.0.gif)

A plugin to adapt your vim background color to your systems preferred light/dark mode prefrence.

## Usage:

1. Add ```use({ "sewdohe/nvim-adapt" })``` to packer config
2. Run ```:PackerSync```
3. Place ```require("nvim-adapt")``` somewhere in your config
4. Reload Neovim

## Future Plans

- [ ] Fix performance issues (using around 6% of my i7 with this plugin on idle)
- [ ] Expose callback function to the user to configure what to do on theme change
- [ ] Cleanly exit the thread when closing Neovim (currently seg faults on close)