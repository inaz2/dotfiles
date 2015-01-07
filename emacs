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
  (cond
   ((and (= arg 1) (= (point) (line-end-position)))
    (if (eq last-command this-command)
        (setq forward-char-or-dabbrev-expand-repeat-count (1+ forward-char-or-dabbrev-expand-repeat-count))
      (setq forward-char-or-dabbrev-expand-repeat-count 1))
    (dabbrev-expand nil))
   (t
    (forward-char arg))))
(global-set-key "\C-f" 'forward-char-or-dabbrev-expand)

(defun backward-char-or-backward-kill-word (arg)
  (interactive "^p")
  (cond
   ((and (= arg 1) (= (point) (line-end-position)))
    (if (eq last-command 'forward-char-or-dabbrev-expand)
        (undo forward-char-or-dabbrev-expand-repeat-count)
      (backward-kill-word 1)))
   (t
    (backward-char arg))))
(global-set-key "\C-b" 'backward-char-or-backward-kill-word)
