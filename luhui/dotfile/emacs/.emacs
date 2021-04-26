(setq cfg-load-path "/srv/code/git/linux-os/luhui/emacs-cfg/")
(load-file (concat cfg-load-path "/appearance.el"))
(load-file (concat cfg-load-path "/mail.el"))
(load-file (concat cfg-load-path "/paredit.el"))

(defun dev-setup ()
  (load-file (concat cfg-load-path "/gtags.el")))
(if (string-equal (getenv "USER") "luhuidev")
    (dev-setup))

(defun web-setup ()
  (load-file (concat cfg-load-path "/w3m.el")))
(if (string-equal (getenv "USER") "luhuiweb")
    (web-setup))
