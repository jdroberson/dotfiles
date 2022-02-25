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
(setq doom-font (font-spec :family "Iosevka Light" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-sourcerer)

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

(setq default-directory "~/")

;; Editor environment variable init
(custom-set-variables
 ;; Don't create lockfiles everywhere -- causes problems with webpack dev server and others
 '(create-lockfiles nil)
 ;; workaround for posframe issue that impacts lsp-ui *AND* company
 '(focus-follows-mouse 'auto-raise)
 '(mouse-autoselect-window nil))
 ;; we hate OSX window manager!

(setq ns-use-native-fullscreen nil)
(setq ns-pop-up-frames nil)
(set-frame-parameter nil 'menu-bar-lines 1)

;; Packages / Modes config
(use-package general)

(use-package company
  :custom
  (company-dabbrev-downcase nil)
  (company-dabbrev-ignore-case nil)
  (company-idle-delay 0.2)
  (company-tooltip-align-annotations t)
  :config
  (global-company-mode)
  :general
  (:keymaps
   'company-active-map
   "C-n" 'company-select-next
   "C-N" 'company-select-previous
   "C-p" 'company-select-previous
   "C-f" 'company-filter-candidates))

(use-package company-box
  :config
  (company-box-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode))

(defun disable-checkdoc ()
  (setq-local flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
(add-hook 'org-src-mode-hook 'disable-checkdoc)

(use-package ivy
  :config
  (ivy-mode 1)
  :custom
  (ivy-use-virtual-buffers t)
  (ivy-display-style 'fancy)
  (ivy-posframe-parameters '((alpha . 80))))

(use-package counsel
  :config
  (counsel-mode 1))

(use-package projectile
  :commands projectile-find-file projectile-switch-project projectile-switch-buffer
  :config
  (projectile-mode +1)
  :custom
  (project-completion-system 'ivy))

;;
;;
;; LSP Mode
;;
;;

(use-package lsp-mode
  :commands lsp lsp-deferred
  :custom
  (read-process-output-max (* 1024 1024))
  :general
  (:states 'normal
   "C-, x" 'lsp-execute-code-action
   "g d" 'lsp-find-definition
   "M-RET" 'lsp-execute-code-action))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-header t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 1)
  (lsp-ui-doc-use-childframe t)
  :general
  (:states 'normal
   :prefix "C-,"
   "h" 'lsp-ui-doc-hide
   "d" 'lsp-describe-thing-at-point
   "U" 'lsp-ui-doc-unfocus-frame
   "F" 'lsp-ui-doc-focus-frame
   "u" 'lsp-find-references
   "l" 'flycheck-list-errors
   "n" 'flycheck-next-error
   "p" 'flycheck-previous-error))

(use-package lsp-ivy
  :commands lsp-ivy-workspace-symbol)

;;
;;
;; JS / TS
;;
;;

(defun ts-setup ()
  (eldoc-mode +1)

  (setq flycheck-check-syntax-automatically '(mode-enabled save))
  (setq flycheck-javascript-eslint-executable "eslint_d")
  (setq flycheck-checker 'javascript-eslint)

  ;; (setq lsp-eslint-server-command '("node" "/Users/jesseroberson/dev/plugins/vscode-eslint/server/out/eslintServer.js" "--stdio"))
  ;; (setq lsp-eslint-validate ["javascript" "javascriptreact" "typescript" "typescriptreact"])

  ;; (add-hook 'after-save-hook #'eslint-fix nil t)
  (general-define-key
   :states 'normal
   :keymaps 'local
   :override t

   "s-F" #'eslint-fix nil t))

(use-package prettier
  :hook
  (typescript-mode . prettier-mode))


(use-package typescript-mode
  :mode "\\.tsx?$"
  :hook (typescript-mode . lsp)
  :hook (typescript-mode . eslintd-fix-mode)
  :config
  (ts-setup)
  :custom
  (typescript-indent-level 2))


;;
;;
;; Tree-Sitter
;;
;;

;; (use-package tree-sitter
;;   :hook
;;   (typescript-mode . tree-sitter-mode)
;;   (typescript-mode . tree-sitter-hl-mode))

;; (use-package tree-sitter-langs
;;   :after tree-sitter)
(use-package! tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
;;
;;
;; Go stuff
;;
;
;;

(defun setup-go-mode ()
  (general-define-key
   :states 'normal
   :keymaps 'local
   :prefix "g"
   :override t

   "f" 'godef-jump))

(use-package go-mode)
(use-package go-gopath)
(use-package gotest)


;;
;;
;; Editor Stuff
;;
;;

(use-package all-the-icons)
;; Modeline
(custom-set-variables
 '(doom-modeline-icon (display-graphic-p))
 '(doom-modeline-major-mode-icon t)
 '(doom-modeline-buffer-encoding nil)
 '(doom-modeline-workspace-name nil)
 '(doom-modeline-buffer-file-name-style 'file-name)
 '(doom-modeline-buffer-encoding nil))

;;
;;
;; Gherkin Stuff
;;
;;

(use-package feature-mode
  :mode (("\\.feature$" . feature-mode)))
