# mlog-mode

A major mode for editing [Mindustry](https://mindustrygame.github.io) logic (mlog) code.  
This package provides syntax highlighting for mlog.

## Requirements

- Emacs 24.3 or later
- string-inflection 1.1.0 or later

## Installation

### Using elpaca (use-package)

``` emacs-lisp
(use-package mlog-mode
  :ensure (mlog-mode :host github :repo "hey2022/mlog-mode"))
```

### Using straight.el (use-package)

``` emacs-lisp
(use-package mlog-mode
  :straight (mlog-mode :type git :host github :repo "hey2022/mlog-mode"))
```

### Using doomemacs

In `packages.el`

``` emacs-lisp
(package! mlog-mode
  :recipe (:host github :repo "hey2022/mlog-mode"))
```

In `config.el`

``` emacs-lisp
(use-package! mlog-mode)
```
