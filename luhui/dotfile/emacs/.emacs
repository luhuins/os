(setq cfg-load-path "/srv/code/git/linux-os/luhui/emacs-cfg/")
(load-file (concat cfg-load-path "/appearance.el"))
(load-file (concat cfg-load-path "/mail.el"))
(load-file (concat cfg-load-path "/paredit.el"))

(if (string-equal (getenv "USER") "luhuidev")
    (load-file (concat cfg-load-path "/gtags.el")))
