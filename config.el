;; Splash screen
(setq initial-buffer-choice "~/.config/doom/start.org")

;; Set font
(add-to-list 'default-frame-alist '(font . "Iosevka Nerd Font 14"))

;; Line number
(add-hook 'prog-mode-hook (lambda ()
                            (global-display-line-numbers-mode t)
                            (setq display-line-numbers-type 'relative)))

;; Stop the screen shifting
(setq display-line-numbers-width-start t)

;; Set scroll margin to 8 lines
(setq scroll-margin 8)

;; Org directory
(setq org-directory "~/Nextcloud/org/")

;; Tab and indetation
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; Scrolling
(defun my-scroll-half-page-down-and-recenter ()
  "Scroll half page down and recenter cursor."
  (interactive)
  (evil-scroll-down (/ (window-body-height) 2))
  (recenter))

(defun my-scroll-half-page-up-and-recenter ()
  "Scroll half page up and recenter cursor."
  (interactive)
  (evil-scroll-up (/ (window-body-height) 2))
  (recenter))

;; Bind the functions to C-d and C-u in normal mode
(define-key evil-normal-state-map (kbd "C-d") 'my-scroll-half-page-down-and-recenter)
(define-key evil-normal-state-map (kbd "C-u") 'my-scroll-half-page-up-and-recenter)

;; Latex config
(setq org-format-latex-options '(:foreground default :background default :scale 2.0 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
                                 ("begin" "$1" "$" "$$" "\\(" "\\[")))

;; transparent background
(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 70))

;; cursor shape
(setq evil-insert-state-cursor 'box) ;; Changes the insert mode cursor to a block

;; Custom functions
(defun ms/org-agenda-open-todos ()
  "Opens the todos org file"
  (interactive)
  (find-file "~/Nextcloud/org/todos.org"))

;; Package configurations

(use-package! olivetti
  :hook ((org-agenda-mode . olivetti-mode)
         (org-agenda-mode . (lambda () (display-line-numbers-mode 0)))
         (org-mode . (lambda () (display-line-numbers-mode 0)))
         (org-mode . olivetti-mode))
  :config
  (setq olivetti-body-width 100))

(use-package! org
  :config (setq org-agenda-span 'week
                org-agenda-start-day "+0d"
                org-agenda-show-all-dates t ;; Show all dates in agenda
                org-agenda-start-on-weekday nil ;; Ensure custom start-day works
                org-agenda-window-setup 'current-window ;; Open agenda in the current window
                org-agenda-hide-tags-regexp ".*"
                org-agenda-skip-scheduled-if-done t
                org-agenda-skip-deadline-if-done t
                org-agenda-skip-timestamp-if-done t
                org-agenda-skip-scheduled-if-deadline-is-shown t
                org-agenda-skip-timestamp-if-deadline-is-shown t))

;; Use org-modern for better Org Mode visuals
(use-package! org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda)
         (org-mode . (lambda () (display-line-numbers-mode 0)))
         (org-mode . (lambda () (vi-tilde-fringe-mode 0))))

  :config
  ;; Customize org-modern settings
  (setq org-modern-star '("•" "◦" "▸")    ;; Customize bullet points
        org-modern-label-border 0.2)       ;; Add padding to labels
  ;; Adjust line spacing for better readability
  (setq line-spacing 0.2))

(use-package! sly
  :init (setq inferior-lisp-program "/usr/bin/sbcl")) ; Adjust to your SBCL path

(use-package! org-journal
  :config
  (setq org-journal-date-prefix "#+title: "
        org-journal-time-prefix "* "
        org-journal-date-format "%a, %m-%d-%Y"
        org-journal-file-format "%Y-%m-%d.org"))

(use-package! vterm
  :load-path "~/temp/emacs-libvterm/"
  :hook (vterm-mode . (lambda () (display-line-numbers-mode -1)))
  :config (setq vterm-shell "/bin/fish"))

(use-package! yasnippet
  :init
  :config
  (setq yasnippet-snippets-dir "~/.config/doom/snippets")
  (yas-global-mode))  ; Enable globally

;;; typescript.el --- typescript support
;;; Commentary:
;;; Code:

(use-package! flycheck
  :config
  (add-hook 'typescript-mode-hook 'flycheck-mode))

(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  (company-mode +1))

(use-package! company
  :config
  (setq company-idle-delay 0.1)  ; Quick completion popup
  (setq company-minimum-prefix-length 1)  ; Trigger completion after one character
  (setq company-show-numbers t)
  (setq company-tooltip-align-annotations t)
  (setq company-tooltip-flip-when-above t)
  (global-company-mode))

(use-package! company-quickhelp
  :init
  (company-quickhelp-mode 1)
  (use-package! pos-tip))

(use-package! web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.jsx\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-block-padding 2
        web-mode-comment-style 2

        web-mode-enable-css-colorization t
        web-mode-enable-auto-pairing t
        web-mode-enable-comment-keywords t
        web-mode-enable-current-element-highlight t
        )
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
		(setup-tide-mode))))
  (flycheck-add-mode 'typescript-tslint 'web-mode))

(use-package! typescript-mode
  :config
  (setq typescript-indent-level 2)
  (add-hook 'typescript-mode #'subword-mode))

(use-package! tide
  :init
  :after (typescript-mode company flycheck)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package! org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Nextcloud/org/")
  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode))

(use-package! mozc)

(provide 'typescript)
;;; typescript.el ends here

;; Keybindings
(map! :leader "t t" 'ms/org-agenda-open-todos)
;; Org Roam
(map! :leader "c n l" 'org-roam-buffer-toggle)
(map! :leader "c n f" 'org-roam-node-find)
(map! :leader "c n i" 'org-roam-node-insert)
;; Japanese input
(map! "M-t" 'mozc-handle-event)
