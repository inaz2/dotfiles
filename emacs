(if window-system
    (progn
      (setq visible-bell t)
      (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1))
  (progn
    (setq visible-bell nil)
    (menu-bar-mode -1)
    (set-face-foreground 'mode-line "gold")
    (set-face-background 'mode-line "black")))

(setq inhibit-startup-screen t)
(global-font-lock-mode 1)
(transient-mark-mode 1)
(setq-default show-trailing-whitespace t)

(setq display-time-24hr-format t)
(display-time)
(line-number-mode 1)
(column-number-mode 1)

(setq c-default-style '((java-mode . "java")
			(awk-mode . "awk")
			(other . "stroustrup")))
(setq-default indent-tabs-mode nil)

;; let "C-x C-b" open in the current window
(global-set-key (kbd "\C-x\C-b") 'buffer-menu)

;; intelligent C-f/C-b
(defun forward-char-or-dabbrev-expand (arg)
  (interactive "^p")
  (if (and (= arg 1) (= (point) (line-end-position)))
      (dabbrev-expand nil)
    (forward-char arg)))
(global-set-key "\C-f" 'forward-char-or-dabbrev-expand)

(defun backward-char-or-backward-kill-word (arg)
  (interactive "^p")
  (if (and (= arg 1) (= (point) (line-end-position)))
      (backward-kill-word 1)
    (backward-char arg)))
(global-set-key "\C-b" 'backward-char-or-backward-kill-word)

;; flymake
(require 'flymake)

(global-set-key "\M-n" 'flymake-goto-next-error)
(global-set-key "\M-p" 'flymake-goto-prev-error)

(defun display-error-message ()
  (message (get-char-property (point) 'help-echo)))
(defadvice flymake-goto-prev-error (after flymake-goto-prev-error-display-message)
  (display-error-message))
(defadvice flymake-goto-next-error (after flymake-goto-next-error-display-message)
  (display-error-message))
(ad-activate 'flymake-goto-prev-error 'flymake-goto-prev-error-display-message)
(ad-activate 'flymake-goto-next-error 'flymake-goto-next-error-display-message)

(defun flymake-gcc-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
	 (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "gcc" (list "-Wall" "-Wextra" "-fsyntax-only" local-file))))

(defun flymake-g++-init ()
  (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
	 (local-file  (file-relative-name
                       temp-file
                       (file-name-directory buffer-file-name))))
    (list "g++" (list "-std=gnu++11" "-Wall" "-Wextra" "-fsyntax-only" local-file))))

(push '("\\.\\(?:c\\|h\\)\\'" flymake-gcc-init) flymake-allowed-file-name-masks)
(push '("\\.\\(?:cc\\|cpp\\|hpp\\)\\'" flymake-g++-init) flymake-allowed-file-name-masks)
