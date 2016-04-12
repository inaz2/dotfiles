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

(setq display-time-24hr-format t)
(display-time)
(line-number-mode 1)
(column-number-mode 1)

;(setq-default show-trailing-whitespace t)
(global-whitespace-mode t)
(setq whitespace-style '(face trailing tabs empty))

(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "stroustrup")))
(setq-default indent-tabs-mode nil)

(setq diff-switches "-u")
(custom-set-faces
 '(diff-header ((t (:foreground "cyan"))) 'now)
 '(diff-file-header ((t (:foreground "cyan" :bold t))) 'now)
 '(diff-added ((t (:foreground "green"))) 'now)
 '(diff-removed ((t (:foreground "red"))) 'now)
 '(diff-context ((t (:foreground "white"))) 'now))

(ffap-bindings)

;; disable additional highlights in shell-mode
(setq shell-font-lock-keywords nil)

;; global vc-git-grep
(defun git-grep (regexp)
  (interactive "sSearch for: ")
  (vc-git-grep regexp "*" (vc-git-root default-directory)))

;; let "C-x C-b" open in the current window
(global-set-key (kbd "\C-x\C-b") 'buffer-menu)

;; let "C-x C-d" dired current directory
(defun dired-here ()
  (interactive)
  (dired "."))
(global-set-key (kbd "\C-x\C-d") 'dired-here)

;; filter-region
(defun filter-region ()
  (interactive)
  (let ((current-prefix-arg '(4)))
       (call-interactively 'shell-command-on-region)))
(global-set-key (kbd "\C-x|") 'filter-region)

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

;; flymake
(require 'flymake)

(defvar flymake-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-n") 'flymake-goto-next-error)
    (define-key map (kbd "M-p") 'flymake-goto-prev-error)
    map))
(add-to-list 'minor-mode-map-alist (cons 'flymake-mode flymake-mode-map))

(custom-set-variables
 '(help-at-pt-timer-delay 0.9)
 '(help-at-pt-display-when-idle '(flymake-overlay)))

(defun flymake-simple-generic-init (cmd &optional opts)
  (let* ((temp-file  (flymake-init-create-temp-buffer-copy
                      'flymake-create-temp-inplace))
         (local-file (file-relative-name
                      temp-file
                      (file-name-directory buffer-file-name))))
    (list cmd (append opts (list local-file)))))

(defun flymake-simple-make-or-generic-init (cmd &optional opts)
  (if (file-exists-p "Makefile")
      (flymake-simple-make-init)
    (flymake-simple-generic-init cmd opts)))

(defun flymake-c-init ()
  (flymake-simple-make-or-generic-init
   "gcc" '("-Wall" "-Wextra" "-fsyntax-only")))
(defun flymake-cc-init ()
  (flymake-simple-make-or-generic-init
   "g++" '("-Wall" "-Wextra" "-fsyntax-only")))

(add-to-list 'flymake-allowed-file-name-masks '("\\.c\\'" flymake-c-init))
(add-to-list 'flymake-allowed-file-name-masks '("\\.\\(?:cc\\|cpp\\)\\'" flymake-cc-init))
