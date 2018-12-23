# quickpick.vim
A UI for Vim to let the user pick an item from a list similar to [CtrlP](https://github.com/ctrlpvim/ctrlp.vim).

This repo is heavily based of [probe](https://github.com/torbiak/probe) without which quickpick.vim wouldn't be possible.
The api's are influenced by [VSCode QuickPick api](https://code.visualstudio.com/api/references/vscode-api#QuickPick).

# Sources
quickpick.vim deliberately does not contain any sources. Please use one of the following sources or create your own.

| Source                        | Links                                                                                              |
|-------------------------------|----------------------------------------------------------------------------------------------------|
| Colorscheme                   | [quickpick-colorscheme.vim](https://github.com/prabirshrestha/quickpick-colorscheme.vim)           |

# Pickers


# Why?
A picker should be able to scale from just a few list items (colorscheme, filetypes) to hundreds (files) and thousands (npm packages)
of items. We shouldn't be needing multiple plugins to handle this case.

[WIP] In the meantime feel free to read some of my thoughts at https://github.com/vim/vim/issues/3573#issuecomment-433730939
and make sure to give a thumbs up if you would like to official see vim support some kind of apis for picking item for a list.
