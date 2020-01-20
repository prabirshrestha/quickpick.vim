# quickpick.vim
A UI for Vim to let the user pick an item from a list similar to [CtrlP](https://github.com/ctrlpvim/ctrlp.vim).

This repo is heavily based of [probe](https://github.com/torbiak/probe) without which quickpick.vim wouldn't be possible.
The api's are influenced by [VSCode QuickPick api](https://code.visualstudio.com/api/references/vscode-api#QuickPick).

![NPM Picker](https://user-images.githubusercontent.com/287744/50551057-55441700-0c30-11e9-8842-d79182cdcaf0.gif)

![Colorscheme Picker](https://user-images.githubusercontent.com/287744/72764564-9c83a980-3b9d-11ea-8135-3daf7bf380d9.gif)


# Pickers
quickpick.vim deliberately does not contain any sources as this allows the core to be very small and focus on providing the best and fast apis for other to use it.

*in alphabetical order*


| Source                        | Links                                                                                              |
|-------------------------------|----------------------------------------------------------------------------------------------------|
| Colorschemes                  | [quickpick-colorschemes.vim](https://github.com/prabirshrestha/quickpick-colorschemes.vim)         |
| Filetypes                     | [quickpick-filetypes.vim](https://github.com/prabirshrestha/quickpick-filetypes.vim)               |
| NPM                           | [quickpick-npm.vim](https://github.com/prabirshrestha/quickpick-npm.vim)                           |

Can't find what you are looking for? Write one instead an send a PR to be included here or search github topics tagged with `quickpickvim` at https://github.com/topics/quickpickvim.

# Roadmap

It is very much work in progress so features are currently limited. The goal is the provide the best apis and be the ultimiate picker UI for me that works on both vim8 and neovim and is very fast, non-blocking and allows me to replace [CtrlP](https://github.com/ctrlpvim/ctrlp.vim), [vim-fz](https://github.com/mattn/vim-fz) and [fzf](https://github.com/junegunn/fzf). Refer to https://github.com/prabirshrestha/quickpick.vim/issues/1 for more details.


# Why?
A picker should be able to scale from just a few list items (colorscheme, filetypes) to hundreds (files) and thousands (npm packages)
of items. We shouldn't be needing multiple UI plugins to handle this case. In order to be fast we need to do minimal work in the UI thread hence it doesn't support any sort of fuzzy search or even a simple string contains search. So, how can an end user using quickpick be productive? Well, how do you search the internet? Do you run a fuzzzy search after google returns a result? NO. You let google do the search and then the browser displays html text. If you don't see it in the first few results you change the query just by typing more characters and let google do its job again. We do the same in quickpick. Let the pickers do the heavy lifting of searching however they want. If the picker wants to using neovim remote plugins or vim job to start a new process, let it do. If your vim has python support pickers might even want to inline python code and use multi-threading without proess overhead, let it do. And if it still doesn't have those capabilities let it fallback to defsult vim script implementation. quickpick.vim is just the UI layer. It is up to the different pickers to implement their own algorithm or tricks to make it fast. Let the battle for the best picker sources begin.

[WIP] In the meantime feel free to read some of my thoughts at https://github.com/vim/vim/issues/3573#issuecomment-433730939
and make sure to give a thumbs up if you would like to official see vim support some kind of apis for picking item for a list.
