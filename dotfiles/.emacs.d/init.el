; Package manager
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(setq package-enable-at-startup nil)
(package-initialize)

; Turn off startup message, no labels on toolbar buttons
(menu-bar-mode -1)
(setq
  inhibit-startup-message t
  tool-bar-style 'image)

; Set backup file location
(setq
  backup-by-copying t
  backup-directory-alist '(("." . "~/.emacs.d/saves"))
  delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

; Load recent items menu
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 25)

; Spellcheck
(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))
(dolist (hook '(change-log-mode-hook log-edit-mode-hook))
  (add-hook hook (lambda () (flyspell-mode -1))))

; Wrap lines in emacs window
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(put 'narrow-to-region 'disabled nil)

; Ignore case in tab completion
(setq read-file-name-completion-ignore-case 1)

; org-babel languages
(org-babel-do-load-languages
   'org-babel-load-languages
    '((python . t)))

;; Default to python3
(defcustom python-shell-interpreter "python3"
  "Default Python interpreter for shell."
  :type 'string
  :group 'python)
