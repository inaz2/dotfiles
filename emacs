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
