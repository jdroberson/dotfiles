;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Jesse Roberson"
      user-mail-address "jessedanielroberson@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 12))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

(use-package general
  :config
  (general-define-key
   :states 'normal
   "TAB" 'switch-to-next-buffer
   "S-TAB" 'switch-to-prev-buffer
   "C-TAB" 'other-window))


(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (eldoc-mode)
  (tide-hl-identifier-mode +1)

  ;; Web Mode config
  (setq web-mode-enable-auto-quoting nil)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-attr-indent-offset 2)
  (setq web-mode-attr-value-indent-offset 2)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-css-colorization t)

  ;; Company stuff
  (set (make-local-variable 'company-backends)
       '((company-tide company-files :with company-yasnippet)
         (company-dabbrev-code company-dabbrev)))

  ;; Flycheck
  (flycheck-mode +1)
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))

  ;; Key bindings
  (general-define-key
   :states 'normal
   :keymaps 'local
   :prefix "C-,"
   "f" 'tide-fix
   "i" 'tide-organize-imports
   "u" 'tide-references
   "R" 'tide-restart-server
   "d" 'tide-documentation-at-point
   "F" 'tide-format

   ;; prefix `e` - Errors
   "e s" 'tide-error-at-point
   "e l" 'tide-project-errors
   "e i" 'tide-add-tslint-disable-next-line
   "e n" 'flycheck-next-error
   "e p" 'flycheck-previous-error

   ;; prefix `r` - Rename
   "r r" 'tide-rename-symbol
   "r f" 'tide-refactor
   "r F" 'tide-rename-file)

  (general-define-key
   :states 'normal
   :keymaps 'local
   :prefix "g"
   :override t

   "d" 'tide-jump-to-definition
   "D" 'tide-jump-to-implementation
   "b" 'tide-jump-back))

(setq company-tooltip-align-annotations t)

(use-package prettier-js
  :defer t)

(use-package tide
  :defer t)

(use-package web-mode
  :mode (("\\.tsx$" . web-mode))
  :init
  (add-hook 'web-mode-hook 'company-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook (lambda () (pcase (file-name-extension buffer-file-name)
                                        ("tsx" (setup-tide-mode))
                                        (_ (lambda ()))))))


(add-hook 'typescript-mode-hook #'setup-tide-mode)
(add-hook 'typescript-mode-hook 'company-mode)
(add-hook 'typescript-mode-hook 'prettier-js-mode)
(add-hook 'js2-mode-hook 'prettier-js-mode)

(setq-default tide-tsserver-executable "/usr/local/bin/tsserver")

;; Old web mode hook stuff
;; (add-to-list 'auto-mode-alist '("\\.tsx\\''" . web-mode))
;; (add-hook 'web-mode-hook
;;          '(lambda ()
;;            (when (string-equal "tsx" (file-name-extension buffer-file-name))
;;              (setup-tide-mode))))

;; Go stuff

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(defun setup-go-mode ()
  (setq 'go-packages-function 'go-packages-go-list)
  (general-define-key
   :states 'normal
   :keymaps 'local
   :prefix "g"
   :override t

   "f" 'godef-jump))

(use-package go-mode
  :config
  (add-hook 'before-save-hook #'gofmt-before-save)
  (add-hook 'go-mode-hook 'flycheck-mode)
  (add-hook 'go-mode-hook 'dumb-jump-mode)
  (add-hook 'go-mode-hook #'setup-go-mode)
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks))

(use-package company-go
  :config
  (add-hook 'go-mode-hook 'company-mode)
  (add-to-list 'company-backends 'company-go))

(use-package go-eldoc
  :diminish eldoc-mode
  :config (add-hook 'go-mode-hook 'go-eldoc-setup))

(use-package go-gopath)
(use-package gotest)
