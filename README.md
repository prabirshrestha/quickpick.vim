# quickpick.vim
A UI for Vim to let the user pick an item from a list similar to [CtrlP](https://github.com/ctrlpvim/ctrlp.vim).

This repo is heavily based of [probe](https://github.com/torbiak/probe) without which quickpick.vim wouldn't be possible.
The api's are influenced by [VSCode QuickPick api](https://code.visualstudio.com/api/references/vscode-api#QuickPick).

It is very much work in progress so features are currently limited.

# Pickers
quickpick.vim deliberately does not contain any sources. Please use one of the following sources or create your own and send a pull request to be added here.

*in alphabetical order*


| Source                        | Links                                                                                              |
|-------------------------------|----------------------------------------------------------------------------------------------------|
| Colorscheme                   | [quickpick-colorscheme.vim](https://github.com/prabirshrestha/quickpick-colorscheme.vim)           |


# Why?
A picker should be able to scale from just a few list items (colorscheme, filetypes) to hundreds (files) and thousands (npm packages)
of items. We shouldn't be needing multiple UI plugins to handle this case. In order to be fast we need to do minimal work in the UI thread hence it doesn't support any sort of fuzzy search or even a simple string contains search. So, how can an end user using quickpick be productive? Well, how do you search the internet? Do you run a fuzzzy search after google returns a result? NO. You let google do the search and then the browser displays html text. If you don't see it in the first few results you change the query just by typing more characters and let google do its job again. We do the same in quickpick. Let the pickers do the heavy lifting of searching however they want. If the picker wants to using neovim remote plugins or vim job to start a new process, let it do. If your vim has python support pickers might even want to inline python code and use multi-threading without proess overhead, let it do. And if it still doesn't have those capabilities let it fallback to defsult vim script implementation. quickpick.vim is just the UI layer. It is up to the different pickers to implement their own algorithm or tricks to make it fast. Let the battle for the best picker sources begin.

[WIP] In the meantime feel free to read some of my thoughts at https://github.com/vim/vim/issues/3573#issuecomment-433730939
and make sure to give a thumbs up if you would like to official see vim support some kind of apis for picking item for a list.
