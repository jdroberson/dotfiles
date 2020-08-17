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

(use-package general)

(use-package company
  :config
  (setq company-dabbrev-downcase 0)
  (setq company-idle-delay 0.2)
  (setq company-tooltip-align-annotations t))
(use-package company-box
  :config
  (company-box-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode))

(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t))
(use-package counsel)


(setq ivy-posframe-parameters '((alpha . 80)))

;;
;;
;; JS / TS
;;
;;
(defun setup-web-mode ())
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (eldoc-mode)
  (tide-hl-identifier-mode +1)

  (setq tide-always-show-documentation t)
  (setq tide-completion-detailed t)
  (setq tide-completion-enable-autoimport-suggestions t)

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
  (setq flycheck-check-syntax-automatically '(save-mode-enabled))
  (flycheck-add-mode 'typescript-tslint 'web-mode)

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

(use-package prettier-js
  :defer t)

(use-package tide
  :defer t
  :after (typescript-mode web-mode company flycheck))

(use-package web-mode
  :mode (("\\.tsx$" . web-mode))
  :init
  (add-hook 'web-mode-hook 'company-mode)
  (add-hook 'web-mode-hook 'prettier-js-mode)
  (add-hook 'web-mode-hook (lambda ()
                             (when (and (not (eq buffer-file-name nil)) (string-equal "tsx" (file-name-extension buffer-file-name)))
                               (setup-tide-mode)))))

(use-package typescript-mode
  :mode (("\\.ts$" . typescript-mode))
  :init
  (add-hook 'typescript-mode-hook #'setup-tide-mode)
  (add-hook 'typescript-mode-hook 'company-mode)
  (add-hook 'typescript-mode-hook 'prettier-js-mode))

(add-hook 'js2-mode-hook 'prettier-js-mode)

(setq-default tide-tsserver-executable "~/go/src/github.com/couchbaselabs/project-avengers/cmd/cp-ui/node_modules/typescript/bin/tsserver")


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
(setq doom-modeline-icon t)


;;
;;
;; Gherkin Stuff
;;
;;

(use-package feature-mode
  :mode (("\\.feature$" . feature-mode)))
